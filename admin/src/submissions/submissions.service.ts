import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import {
  ApproveSubmissionDto,
  CreateSubmissionDto,
  RejectSubmissionDto,
} from './dto/submission.dto';

export type SubmissionRow = {
  id: string;
  title: string;
  content: string;
  category_id: string;
  category_name: string;
  submitter_name: string | null;
  status: string;
  admin_note: string | null;
  reviewed_by: string | null;
  reviewed_at: Date | null;
  published_poem_id: string | null;
  created_at: Date;
  updated_at: Date;
};

@Injectable()
export class SubmissionsService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: CreateSubmissionDto) {
    await this.ensureCategory(dto.categoryId);

    const { rows } = await this.db.query<SubmissionRow>(
      `WITH inserted AS (
         INSERT INTO submissions (title, content, category_id, submitter_name, status)
         VALUES ($1, $2, $3, $4, 'PENDING')
         RETURNING *
       )
       SELECT i.id, i.title, i.content, i.category_id, c.name AS category_name,
              i.submitter_name, i.status, i.admin_note, i.reviewed_by,
              i.reviewed_at, i.published_poem_id, i.created_at, i.updated_at
       FROM inserted i
       JOIN categories c ON c.id = i.category_id`,
      [
        dto.title.trim(),
        dto.content.trim(),
        dto.categoryId,
        dto.submitterName?.trim() || null,
      ],
    );

    return this.map(rows[0]);
  }

  async findAll(status?: string) {
    const params: unknown[] = [];
    let where = '';

    if (status) {
      params.push(status.toUpperCase());
      where = `WHERE s.status = $1`;
    }

    const { rows } = await this.db.query<SubmissionRow>(
      `SELECT s.id, s.title, s.content, s.category_id, c.name AS category_name,
              s.submitter_name, s.status, s.admin_note, s.reviewed_by,
              s.reviewed_at, s.published_poem_id, s.created_at, s.updated_at
       FROM submissions s
       JOIN categories c ON c.id = s.category_id
       ${where}
       ORDER BY s.created_at DESC`,
      params,
    );

    return rows.map(this.map);
  }

  async findOne(id: string) {
    const { rows } = await this.db.query<SubmissionRow>(
      `SELECT s.id, s.title, s.content, s.category_id, c.name AS category_name,
              s.submitter_name, s.status, s.admin_note, s.reviewed_by,
              s.reviewed_at, s.published_poem_id, s.created_at, s.updated_at
       FROM submissions s
       JOIN categories c ON c.id = s.category_id
       WHERE s.id = $1`,
      [id],
    );
    if (!rows[0]) throw new NotFoundException('Submission not found');
    return this.map(rows[0]);
  }

  async approve(id: string, adminId: string, dto: ApproveSubmissionDto) {
    const client = await this.db.getClient();

    try {
      await client.query('BEGIN');

      const { rows: subRows } = await client.query<{
        id: string;
        title: string;
        content: string;
        category_id: string;
        status: string;
      }>(
        `SELECT id, title, content, category_id, status
         FROM submissions
         WHERE id = $1
         FOR UPDATE`,
        [id],
      );

      const submission = subRows[0];
      if (!submission) {
        throw new NotFoundException('Submission not found');
      }
      if (submission.status !== 'PENDING' && submission.status !== 'NEEDS_CHANGES') {
        throw new BadRequestException(
          `Cannot approve submission with status ${submission.status}`,
        );
      }

      const title = dto.title?.trim() || submission.title;
      const content = dto.content?.trim() || submission.content;
      const categoryId = dto.categoryId || submission.category_id;

      const { rows: catRows } = await client.query(
        'SELECT id FROM categories WHERE id = $1',
        [categoryId],
      );
      if (!catRows[0]) throw new NotFoundException('Category not found');

      const { rows: poemRows } = await client.query<{ id: string }>(
        `INSERT INTO poems (title, content, category_id, approved_by, approved_at)
         VALUES ($1, $2, $3, $4, NOW())
         RETURNING id`,
        [title, content, categoryId, adminId],
      );

      const poemId = poemRows[0].id;

      const { rows: updated } = await client.query<SubmissionRow>(
        `WITH updated AS (
           UPDATE submissions
           SET status = 'APPROVED',
               title = $2,
               content = $3,
               category_id = $4,
               reviewed_by = $5,
               reviewed_at = NOW(),
               published_poem_id = $6,
               admin_note = NULL,
               updated_at = NOW()
           WHERE id = $1
           RETURNING *
         )
         SELECT u.id, u.title, u.content, u.category_id, c.name AS category_name,
                u.submitter_name, u.status, u.admin_note, u.reviewed_by,
                u.reviewed_at, u.published_poem_id, u.created_at, u.updated_at
         FROM updated u
         JOIN categories c ON c.id = u.category_id`,
        [id, title, content, categoryId, adminId, poemId],
      );

      await client.query('COMMIT');
      return this.map(updated[0]);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async reject(id: string, adminId: string, dto: RejectSubmissionDto) {
    const status = dto.status ?? 'REJECTED';

    const { rows: existing } = await this.db.query<{ status: string }>(
      'SELECT status FROM submissions WHERE id = $1',
      [id],
    );
    if (!existing[0]) throw new NotFoundException('Submission not found');
    if (existing[0].status !== 'PENDING' && existing[0].status !== 'NEEDS_CHANGES') {
      throw new BadRequestException(
        `Cannot reject submission with status ${existing[0].status}`,
      );
    }

    const { rows } = await this.db.query<SubmissionRow>(
      `WITH updated AS (
         UPDATE submissions
         SET status = $2,
             admin_note = $3,
             reviewed_by = $4,
             reviewed_at = NOW(),
             updated_at = NOW()
         WHERE id = $1
         RETURNING *
       )
       SELECT u.id, u.title, u.content, u.category_id, c.name AS category_name,
              u.submitter_name, u.status, u.admin_note, u.reviewed_by,
              u.reviewed_at, u.published_poem_id, u.created_at, u.updated_at
       FROM updated u
       JOIN categories c ON c.id = u.category_id`,
      [id, status, dto.adminNote?.trim() || null, adminId],
    );

    return this.map(rows[0]);
  }

  private async ensureCategory(categoryId: string) {
    const { rows } = await this.db.query(
      'SELECT id FROM categories WHERE id = $1',
      [categoryId],
    );
    if (!rows[0]) throw new NotFoundException('Category not found');
  }

  private map(row: SubmissionRow) {
    return {
      id: row.id,
      title: row.title,
      content: row.content,
      categoryId: row.category_id,
      categoryName: row.category_name,
      submitterName: row.submitter_name,
      status: row.status,
      adminNote: row.admin_note,
      reviewedBy: row.reviewed_by,
      reviewedAt: row.reviewed_at,
      publishedPoemId: row.published_poem_id,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
