import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AdminAuthGuard } from '../common/guards/admin-auth.guard';
import { CurrentAdmin } from '../common/decorators/current-admin.decorator';
import { AdminJwtPayload } from '../common/guards/admin-auth.guard';
import { CreatePoemDto, UpdatePoemDto } from './dto/poem.dto';
import { PoemsService } from './poems.service';

@Controller()
export class PoemsController {
  constructor(private readonly poemsService: PoemsService) {}

  @Get('poems')
  findAll(
    @Query('categoryId') categoryId?: string,
    @Query('q') q?: string,
  ) {
    return this.poemsService.findAll({ categoryId, q });
  }

  @Get('poems/:id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.poemsService.findOne(id);
  }

  @UseGuards(AdminAuthGuard)
  @Post('admin/poems')
  create(
    @Body() dto: CreatePoemDto,
    @CurrentAdmin() admin: AdminJwtPayload,
  ) {
    return this.poemsService.create(dto, admin.sub);
  }

  @UseGuards(AdminAuthGuard)
  @Patch('admin/poems/:id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePoemDto,
  ) {
    return this.poemsService.update(id, dto);
  }

  @UseGuards(AdminAuthGuard)
  @Delete('admin/poems/:id')
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.poemsService.remove(id);
  }
}
