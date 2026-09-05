import {
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';

export class CreateSubmissionDto {
  @IsString()
  @MinLength(1)
  title!: string;

  @IsString()
  @MinLength(1)
  content!: string;

  @IsUUID()
  categoryId!: string;

  @IsOptional()
  @IsString()
  submitterName?: string;
}

export class ApproveSubmissionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  title?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  content?: string;

  @IsOptional()
  @IsUUID()
  categoryId?: string;
}

export class RejectSubmissionDto {
  @IsOptional()
  @IsString()
  adminNote?: string;

  @IsOptional()
  @IsIn(['REJECTED', 'NEEDS_CHANGES'])
  status?: 'REJECTED' | 'NEEDS_CHANGES';
}
