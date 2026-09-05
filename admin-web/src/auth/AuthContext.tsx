import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { api, setToken, getToken } from '../api/client'
import type { Admin } from '../api/types'

type AuthState = {
  token: string | null
  admin: Admin | null
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  isAuthenticated: boolean
}

const AuthContext = createContext<AuthState | null>(null)

const ADMIN_KEY = 'mzmur_admin_user'

function loadAdmin(): Admin | null {
  try {
    const raw = localStorage.getItem(ADMIN_KEY)
    return raw ? (JSON.parse(raw) as Admin) : null
  } catch {
    return null
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setTokenState] = useState<string | null>(() => getToken())
  const [admin, setAdmin] = useState<Admin | null>(() => loadAdmin())

  const login = useCallback(async (email: string, password: string) => {
    const res = await api.login(email, password)
    setToken(res.accessToken)
    localStorage.setItem(ADMIN_KEY, JSON.stringify(res.admin))
    setTokenState(res.accessToken)
    setAdmin(res.admin)
  }, [])

  const logout = useCallback(() => {
    setToken(null)
    localStorage.removeItem(ADMIN_KEY)
    setTokenState(null)
    setAdmin(null)
  }, [])

  const value = useMemo(
    () => ({
      token,
      admin,
      login,
      logout,
      isAuthenticated: Boolean(token),
    }),
    [token, admin, login, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
