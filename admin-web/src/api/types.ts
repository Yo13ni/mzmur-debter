export type Admin = {
  id: string
  email: string
  name: string
}

export type LoginResponse = {
  accessToken: string
  admin: Admin
}

export type Category = {
  id: string
  name: string
  sortOrder: number
  createdAt: string
  updatedAt: string
}

export type SubmissionStatus =
  | 'PENDING'
  | 'APPROVED'
  | 'REJECTED'
  | 'NEEDS_CHANGES'

export type Submission = {
  id: string
  title: string
  content: string
  categoryId: string
  categoryName: string
  submitterName: string | null
  status: SubmissionStatus
  adminNote: string | null
  reviewedBy: string | null
  reviewedAt: string | null
  publishedPoemId: string | null
  createdAt: string
  updatedAt: string
}

export type Poem = {
  id: string
  title: string
  content: string
  categoryId: string
  categoryName: string
  approvedBy: string | null
  approvedAt: string | null
  createdAt: string
  updatedAt: string
}

export type ApprovePayload = {
  title?: string
  content?: string
  categoryId?: string
}

export type RejectPayload = {
  adminNote?: string
  status?: 'REJECTED' | 'NEEDS_CHANGES'
}
