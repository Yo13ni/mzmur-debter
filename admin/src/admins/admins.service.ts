import {
  ConflictException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { DatabaseService } from '../database/database.service';
import { CreateAdminDto } from './dto/create-admin.dto';

export type AdminRow = {
  id: string;
  email: string;
  password_hash: string;
  name: string;
  role: string;
  created_at: Date;
};

@Injectable()
export class AdminsService {
  constructor(private readonly db: DatabaseService) {}

  async list(callerId: string) {
    await this.requireSuperAdmin(callerId);
    const { rows } = await this.db.query<AdminRow>(
      `SELECT id, email, name, role, created_at
       FROM admins
       ORDER BY role ASC, created_at ASC`,
    );
    return rows.map(this.map);
  }

  async create(dto: CreateAdminDto, callerId: string) {
    await this.requireSuperAdmin(callerId);

    const passwordHash = await bcrypt.hash(dto.password, 12);
    try {
      const { rows } = await this.db.query<AdminRow>(
        `INSERT INTO admins (email, name, password_hash, role)
         VALUES ($1, $2, $3, 'admin')
         RETURNING id, email, name, role, created_at`,
        [dto.email.toLowerCase().trim(), dto.name.trim(), passwordHash],
      );
      return this.map(rows[0]);
    } catch (err: unknown) {
      if (this.isUniqueViolation(err)) {
        throw new ConflictException('An admin with that email already exists');
      }
      throw err;
    }
  }

  private async requireSuperAdmin(callerId: string): Promise<void> {
    const { rows } = await this.db.query<{ role: string }>(
      'SELECT role FROM admins WHERE id = $1',
      [callerId],
    );
    if (rows[0]?.role !== 'super_admin') {
      throw new ForbiddenException(
        'Only the initial admin can add new admin accounts',
      );
    }
  }

  private map(row: AdminRow) {
    return {
      id: row.id,
      email: row.email,
      name: row.name,
      role: row.role,
      createdAt: row.created_at,
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
}