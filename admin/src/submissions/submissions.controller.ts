import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentAdmin } from '../common/decorators/current-admin.decorator';
import {
  AdminAuthGuard,
  AdminJwtPayload,
} from '../common/guards/admin-auth.guard';
import {
  ApproveSubmissionDto,
  CreateSubmissionDto,
  RejectSubmissionDto,
} from './dto/submission.dto';
import { SubmissionsService } from './submissions.service';

@Controller()
export class SubmissionsController {
  constructor(private readonly submissionsService: SubmissionsService) {}

  /** Public: Flutter "Write" becomes a verification request */
  @Post('submissions')
  create(@Body() dto: CreateSubmissionDto) {
    return this.submissionsService.create(dto);
  }

  @UseGuards(AdminAuthGuard)
  @Get('admin/submissions')
  findAll(@Query('status') status?: string) {
    return this.submissionsService.findAll(status);
  }

  @UseGuards(AdminAuthGuard)
  @Get('admin/submissions/:id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.submissionsService.findOne(id);
  }

  @UseGuards(AdminAuthGuard)
  @Patch('admin/submissions/:id/approve')
  approve(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ApproveSubmissionDto,
    @CurrentAdmin() admin: AdminJwtPayload,
  ) {
    return this.submissionsService.approve(id, admin.sub, dto);
  }

  @UseGuards(AdminAuthGuard)
  @Patch('admin/submissions/:id/reject')
  reject(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RejectSubmissionDto,
    @CurrentAdmin() admin: AdminJwtPayload,
  ) {
    return this.submissionsService.reject(id, admin.sub, dto);
  }
}
