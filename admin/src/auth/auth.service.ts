import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { DatabaseService } from '../database/database.service';
import { LoginDto } from './dto/login.dto';

type AdminRow = {
  id: string;
  email: string;
  password_hash: string;
  name: string;
  role: string;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly db: DatabaseService,
    private readonly jwt: JwtService,
  ) {}

  async login(dto: LoginDto) {
    const { rows } = await this.db.query<AdminRow>(
      `SELECT id, email, password_hash, name, role
       FROM admins
       WHERE email = $1`,
      [dto.email.toLowerCase().trim()],
    );

    const admin = rows[0];
    if (!admin) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const ok = await bcrypt.compare(dto.password, admin.password_hash);
    if (!ok) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const accessToken = await this.jwt.signAsync({
      sub: admin.id,
      email: admin.email,
    });

    return {
      accessToken,
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name,
        role: admin.role,
      },
    };
  }
}
