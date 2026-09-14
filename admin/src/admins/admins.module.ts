import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AdminsController } from './admins.controller';
import { AdminsService } from './admins.service';

@Module({
  imports: [AuthModule],
  controllers: [AdminsController],
  providers: [AdminsService],
})
export class AdminsModule {}