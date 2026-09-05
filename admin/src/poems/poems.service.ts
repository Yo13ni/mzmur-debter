import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreatePoemDto, UpdatePoemDto } from './dto/poem.dto';

export type PoemRow = {
  id: string;
  title: string;
  content: string;
  category_id: string;
  category_name: string;
  approved_by: string | null;
  approved_at: Date | null;
  created_at: Date;
  updated_at: Date;
};

@Injectable()
export class PoemsService {
  constructor(private readonly db: DatabaseService) {}

  async findAll(filters: { categoryId?: string; q?: string }) {
    const params: unknown[] = [];
    const where: string[] = [];

    if (filters.categoryId) {
      params.push(filters.categoryId);
      where.push(`p.category_id = $${params.length}`);
    }

    if (filters.q?.trim()) {
      params.push(`%${filters.q.trim()}%`);
      where.push(
        `(p.title ILIKE $${params.length} OR p.content ILIKE $${params.length})`,
      );
    }

    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const { rows } = await this.db.query<PoemRow>(
      `SELECT p.id, p.title, p.content, p.category_id, c.name AS category_name,
              p.approved_by, p.approved_at, p.created_at, p.updated_at
       FROM poems p
       JOIN categories c ON c.id = p.category_id
       ${whereSql}
       ORDER BY p.created_at DESC`,
      params,
    );

    return rows.map(this.map);
  }

  async findOne(id: string) {
    const { rows } = await this.db.query<PoemRow>(
      `SELECT p.id, p.title, p.content, p.category_id, c.name AS category_name,
              p.approved_by, p.approved_at, p.created_at, p.updated_at
       FROM poems p
       JOIN categories c ON c.id = p.category_id
       WHERE p.id = $1`,
      [id],
    );
    if (!rows[0]) throw new NotFoundException('Poem not found');
    return this.map(rows[0]);
  }

  async create(dto: CreatePoemDto, adminId: string) {
    await this.ensureCategory(dto.categoryId);

    const { rows } = await this.db.query<PoemRow>(
      `WITH inserted AS (
         INSERT INTO poems (title, content, category_id, approved_by, approved_at)
         VALUES ($1, $2, $3, $4, NOW())
         RETURNING *
       )
       SELECT i.id, i.title, i.content, i.category_id, c.name AS category_name,
              i.approved_by, i.approved_at, i.created_at, i.updated_at
       FROM inserted i
       JOIN categories c ON c.id = i.category_id`,
      [dto.title.trim(), dto.content.trim(), dto.categoryId, adminId],
    );

    return this.map(rows[0]);
  }

  async update(id: string, dto: UpdatePoemDto) {
    await this.findOne(id);
    if (dto.categoryId) await this.ensureCategory(dto.categoryId);

    const { rows } = await this.db.query<PoemRow>(
      `WITH updated AS (
         UPDATE poems
         SET title = COALESCE($2, title),
             content = COALESCE($3, content),
             category_id = COALESCE($4, category_id),
             updated_at = NOW()
         WHERE id = $1
         RETURNING *
       )
       SELECT u.id, u.title, u.content, u.category_id, c.name AS category_name,
              u.approved_by, u.approved_at, u.created_at, u.updated_at
       FROM updated u
       JOIN categories c ON c.id = u.category_id`,
      [
        id,
        dto.title?.trim() ?? null,
        dto.content?.trim() ?? null,
        dto.categoryId ?? null,
      ],
    );

    return this.map(rows[0]);
  }

  async remove(id: string) {
    await this.findOne(id);
    await this.db.query('DELETE FROM poems WHERE id = $1', [id]);
    return { deleted: true };
  }

  private async ensureCategory(categoryId: string) {
    const { rows } = await this.db.query(
      'SELECT id FROM categories WHERE id = $1',
      [categoryId],
    );
    if (!rows[0]) throw new NotFoundException('Category not found');
  }

  private map(row: PoemRow) {
    return {
      id: row.id,
      title: row.title,
      content: row.content,
      categoryId: row.category_id,
      categoryName: row.category_name,
      approvedBy: row.approved_by,
      approvedAt: row.approved_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
