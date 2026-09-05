import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateCategoryDto, UpdateCategoryDto } from './dto/category.dto';

export type CategoryRow = {
  id: string;
  name: string;
  sort_order: number;
  created_at: Date;
  updated_at: Date;
};

@Injectable()
export class CategoriesService {
  constructor(private readonly db: DatabaseService) {}

  async findAll() {
    const { rows } = await this.db.query<CategoryRow>(
      `SELECT id, name, sort_order, created_at, updated_at
       FROM categories
       ORDER BY sort_order ASC, name ASC`,
    );
    return rows.map(this.map);
  }

  async findOne(id: string) {
    const { rows } = await this.db.query<CategoryRow>(
      `SELECT id, name, sort_order, created_at, updated_at
       FROM categories WHERE id = $1`,
      [id],
    );
    if (!rows[0]) throw new NotFoundException('Category not found');
    return this.map(rows[0]);
  }

  async create(dto: CreateCategoryDto) {
    try {
      const { rows } = await this.db.query<CategoryRow>(
        `INSERT INTO categories (name, sort_order)
         VALUES ($1, $2)
         RETURNING id, name, sort_order, created_at, updated_at`,
        [dto.name.trim(), dto.sortOrder ?? 0],
      );
      return this.map(rows[0]);
    } catch (err: unknown) {
      if (this.isUniqueViolation(err)) {
        throw new ConflictException('Category name already exists');
      }
      throw err;
    }
  }

  async update(id: string, dto: UpdateCategoryDto) {
    await this.findOne(id);
    try {
      const { rows } = await this.db.query<CategoryRow>(
        `UPDATE categories
         SET name = COALESCE($2, name),
             sort_order = COALESCE($3, sort_order),
             updated_at = NOW()
         WHERE id = $1
         RETURNING id, name, sort_order, created_at, updated_at`,
        [id, dto.name?.trim() ?? null, dto.sortOrder ?? null],
      );
      return this.map(rows[0]);
    } catch (err: unknown) {
      if (this.isUniqueViolation(err)) {
        throw new ConflictException('Category name already exists');
      }
      throw err;
    }
  }

  async remove(id: string) {
    await this.findOne(id);
    try {
      await this.db.query('DELETE FROM categories WHERE id = $1', [id]);
      return { deleted: true };
    } catch (err: unknown) {
      if (this.isForeignKeyViolation(err)) {
        throw new ConflictException(
          'Category is in use by poems or submissions',
        );
      }
      throw err;
    }
  }

  private map(row: CategoryRow) {
    return {
      id: row.id,
      name: row.name,
      sortOrder: row.sort_order,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  private isUniqueViolation(err: unknown): boolean {
    return (
      typeof err === 'object' &&
      err !== null &&
      'code' in err &&
      (err as { code: string }).code === '23505'
    );
  }

  private isForeignKeyViolation(err: unknown): boolean {
    return (
      typeof err === 'object' &&
      err !== null &&
      'code' in err &&
      (err as { code: string }).code === '23503'
    );
  }
}
