import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { CurrentAdmin } from '../common/decorators/current-admin.decorator';
import { AdminAuthGuard } from '../common/guards/admin-auth.guard';
import { AdminsService } from './admins.service';
import { CreateAdminDto } from './dto/create-admin.dto';

@UseGuards(AdminAuthGuard)
@Controller('admin')
export class AdminsController {
  constructor(private readonly adminsService: AdminsService) {}

  @Get('admins')
  list(@CurrentAdmin() caller: { sub: string }) {
    return this.adminsService.list(caller.sub);
  }

  @Post('admins')
  create(@Body() dto: CreateAdminDto, @CurrentAdmin() caller: { sub: string }) {
    return this.adminsService.create(dto, caller.sub);
  }
}