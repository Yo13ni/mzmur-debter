import { useCallback, useEffect, useState, type FormEvent } from 'react'
import { api, ApiError } from '../api/client'
import type { Admin } from '../api/types'
import { useAuth } from '../auth/AuthContext'
import { EmptyState, ErrorBanner, PageHeader } from '../components/ui'

export function AdminsPage() {
  const { admin: current } = useAuth()
  const isSuper = current?.role === 'super_admin'

  const [admins, setAdmins] = useState<Admin[]>([])
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [busy, setBusy] = useState(false)

  const load = useCallback(async () => {
    if (!isSuper) return
    setLoading(true)
    setError('')
    try {
      setAdmins(await api.listAdmins())
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Failed to load admins')
    } finally {
      setLoading(false)
    }
  }, [isSuper])

  useEffect(() => {
    let cancelled = false
    void load().finally(() => {
      if (cancelled) setError('')
    })
    return () => {
      cancelled = true
    }
  }, [load])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setBusy(true)
    setError('')
    try {
      await api.createAdmin({ name: name.trim(), email: email.trim(), password })
      setName('')
      setEmail('')
      setPassword('')
      await load()
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Create admin failed')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div>
      <PageHeader
        title="Admins"
        subtitle="Accounts that can manage poems, categories and submissions."
      />

      {error ? <ErrorBanner message={error} /> : null}

      {isSuper ? (
        <form
          onSubmit={onSubmit}
          className="mb-6 grid gap-3 rounded-lg border border-line bg-panel p-4 sm:grid-cols-[1fr_1.2fr_1fr_auto]"
        >
          <input
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Full name"
            className="rounded-md border border-line px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
          />
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Email"
            className="rounded-md border border-line px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
          />
          <input
            type="password"
            required
            minLength={6}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Temporary password (min 6 chars)"
            className="rounded-md border border-line px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
          />
          <button
            type="submit"
            disabled={busy}
            className="rounded-md bg-forest px-3 py-2 text-sm font-semibold text-white hover:bg-forest-dark disabled:opacity-60"
          >
            {busy ? 'Adding…' : 'Add admin'}
          </button>
        </form>
      ) : (
        <p className="mb-6 rounded-md border border-line bg-panel px-4 py-3 text-sm text-ink-muted">
          Only the initial admin can add or view other admin accounts.
        </p>
      )}

      {loading ? (
        <p className="text-sm text-ink-muted">Loading…</p>
      ) : admins.length === 0 ? (
        <EmptyState message="No admin accounts yet." />
      ) : (
        <div className="overflow-hidden rounded-lg border border-line bg-panel">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-line bg-paper text-ink-muted">
              <tr>
                <th className="px-4 py-3 font-medium">Name</th>
                <th className="px-4 py-3 font-medium">Email</th>
                <th className="px-4 py-3 font-medium">Role</th>
                <th className="px-4 py-3 font-medium">Created</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {admins.map((admin) => (
                <tr key={admin.id}>
                  <td className="px-4 py-3 font-medium">
                    {admin.name}
                    {admin.id === current?.id ? (
                      <span className="ml-2 text-xs text-ink-muted">(you)</span>
                    ) : null}
                  </td>
                  <td className="px-4 py-3 text-ink-muted">{admin.email}</td>
                  <td className="px-4 py-3">
                    <span
                      className={`inline-flex rounded px-2 py-0.5 text-xs font-semibold tracking-wide ${
                        admin.role === 'super_admin'
                          ? 'bg-violet-100 text-violet-900'
                          : 'bg-slate-100 text-slate-800'
                      }`}
                    >
                      {admin.role}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-ink-muted">
                    {admin.createdAt
                      ? new Date(admin.createdAt).toLocaleDateString()
                      : '—'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}