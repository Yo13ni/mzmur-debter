import { NavLink, Outlet, Navigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

const nav = [
  { to: '/submissions', label: 'Submissions' },
  { to: '/poems', label: 'Poems' },
  { to: '/categories', label: 'Categories' },
]

export function RequireAuth() {
  const { isAuthenticated } = useAuth()
  if (!isAuthenticated) return <Navigate to="/login" replace />
  return <Outlet />
}

export function AdminLayout() {
  const { admin, logout } = useAuth()

  return (
    <div className="min-h-svh lg:grid lg:grid-cols-[240px_1fr]">
      <aside className="border-b border-line bg-ink text-white lg:border-b-0 lg:border-r lg:border-line/20">
        <div className="px-5 py-6">
          <p className="font-ethiopic text-xl font-semibold tracking-wide">
            መዝሙር ደብተር
          </p>
          <p className="mt-1 text-sm text-white/65">Admin console</p>
        </div>
        <nav className="flex gap-1 overflow-x-auto px-3 pb-4 lg:flex-col lg:pb-6">
          {nav.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                [
                  'rounded-md px-3 py-2 text-sm font-medium whitespace-nowrap transition-colors',
                  isActive
                    ? 'bg-white/15 text-white'
                    : 'text-white/70 hover:bg-white/10 hover:text-white',
                ].join(' ')
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="hidden border-t border-white/10 px-5 py-4 lg:block">
          <p className="truncate text-sm font-medium">{admin?.name}</p>
          <p className="truncate text-xs text-white/55">{admin?.email}</p>
          <button
            type="button"
            onClick={logout}
            className="mt-3 text-sm text-white/70 underline-offset-2 hover:text-white hover:underline"
          >
            Sign out
          </button>
        </div>
      </aside>

      <div className="flex min-w-0 flex-col">
        <header className="flex items-center justify-between border-b border-line bg-panel/80 px-4 py-3 backdrop-blur lg:hidden">
          <div>
            <p className="text-sm font-medium">{admin?.name}</p>
            <p className="text-xs text-ink-muted">{admin?.email}</p>
          </div>
          <button
            type="button"
            onClick={logout}
            className="rounded-md border border-line px-3 py-1.5 text-sm hover:bg-paper"
          >
            Sign out
          </button>
        </header>
        <main className="flex-1 px-4 py-6 sm:px-6 lg:px-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
