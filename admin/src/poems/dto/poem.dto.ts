import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreatePoemDto {
  @IsString()
  @MinLength(1)
  title!: string;

  @IsString()
  @MinLength(1)
  content!: string;

  @IsUUID()
  categoryId!: string;
}

export class UpdatePoemDto {
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
