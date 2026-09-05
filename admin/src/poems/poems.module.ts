import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { PoemsController } from './poems.controller';
import { PoemsService } from './poems.service';

@Module({
  imports: [AuthModule],
  controllers: [PoemsController],
  providers: [PoemsService],
  exports: [PoemsService],
})
export class PoemsModule {}
