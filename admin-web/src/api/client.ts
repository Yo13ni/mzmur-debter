import type {
  ApprovePayload,
  Category,
  LoginResponse,
  Poem,
  RejectPayload,
  Submission,
} from './types'

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? '/api'

const TOKEN_KEY = 'mzmur_admin_token'

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function setToken(token: string | null) {
  if (token) localStorage.setItem(TOKEN_KEY, token)
  else localStorage.removeItem(TOKEN_KEY)
}

export class ApiError extends Error {
  status: number

  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {},
  auth = true,
): Promise<T> {
  const headers = new Headers(options.headers)
  if (!headers.has('Content-Type') && options.body) {
    headers.set('Content-Type', 'application/json')
  }
  if (auth) {
    const token = getToken()
    if (token) headers.set('Authorization', `Bearer ${token}`)
  }

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers })

  if (res.status === 401 && auth) {
    setToken(null)
    localStorage.removeItem('mzmur_admin_user')
    if (!window.location.pathname.startsWith('/login')) {
      window.location.assign('/login')
    }
  }

  if (!res.ok) {
    let message = res.statusText || 'Request failed'
    try {
      const data = (await res.json()) as { message?: string | string[] }
      if (Array.isArray(data.message)) message = data.message.join(', ')
      else if (data.message) message = data.message
    } catch {
      /* ignore */
    }
    throw new ApiError(res.status, message)
  }

  if (res.status === 204) return undefined as T
  return (await res.json()) as T
}

export const api = {
  login(email: string, password: string) {
    return request<LoginResponse>(
      '/auth/login',
      { method: 'POST', body: JSON.stringify({ email, password }) },
      false,
    )
  },

  listSubmissions(status?: string) {
    const q = status ? `?status=${encodeURIComponent(status)}` : ''
    return request<Submission[]>(`/admin/submissions${q}`)
  },

  getSubmission(id: string) {
    return request<Submission>(`/admin/submissions/${id}`)
  },

  approveSubmission(id: string, body: ApprovePayload = {}) {
    return request<Submission>(`/admin/submissions/${id}/approve`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    })
  },

  rejectSubmission(id: string, body: RejectPayload = {}) {
    return request<Submission>(`/admin/submissions/${id}/reject`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    })
  },

  listCategories() {
    return request<Category[]>('/categories', {}, false)
  },

  createCategory(body: { name: string; sortOrder?: number }) {
    return request<Category>('/admin/categories', {
      method: 'POST',
      body: JSON.stringify(body),
    })
  },

  updateCategory(id: string, body: { name?: string; sortOrder?: number }) {
    return request<Category>(`/admin/categories/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    })
  },

  deleteCategory(id: string) {
    return request<{ deleted: boolean }>(`/admin/categories/${id}`, {
      method: 'DELETE',
    })
  },

  listPoems(params?: { categoryId?: string; q?: string }) {
    const search = new URLSearchParams()
    if (params?.categoryId) search.set('categoryId', params.categoryId)
    if (params?.q) search.set('q', params.q)
    const q = search.toString()
    return request<Poem[]>(`/poems${q ? `?${q}` : ''}`, {}, false)
  },

  createPoem(body: { title: string; content: string; categoryId: string }) {
    return request<Poem>('/admin/poems', {
      method: 'POST',
      body: JSON.stringify(body),
    })
  },

  updatePoem(
    id: string,
    body: { title?: string; content?: string; categoryId?: string },
  ) {
    return request<Poem>(`/admin/poems/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    })
  },

  deletePoem(id: string) {
    return request<{ deleted: boolean }>(`/admin/poems/${id}`, {
      method: 'DELETE',
    })
  },
}
