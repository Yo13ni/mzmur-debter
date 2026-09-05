import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api, ApiError } from '../api/client'
import type { Submission, SubmissionStatus } from '../api/types'
import { EmptyState, ErrorBanner, PageHeader, StatusBadge } from '../components/ui'

const filters: Array<{ value: string; label: string }> = [
  { value: 'PENDING', label: 'Pending' },
  { value: 'NEEDS_CHANGES', label: 'Needs changes' },
  { value: 'APPROVED', label: 'Approved' },
  { value: 'REJECTED', label: 'Rejected' },
  { value: '', label: 'All' },
]

function formatDate(value: string) {
  return new Date(value).toLocaleString()
}

export function SubmissionsPage() {
  const [status, setStatus] = useState('PENDING')
  const [items, setItems] = useState<Submission[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false
    async function load() {
      setLoading(true)
      setError('')
      try {
        const data = await api.listSubmissions(status || undefined)
        if (!cancelled) setItems(data)
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof ApiError ? err.message : 'Failed to load')
        }
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    void load()
    return () => {
      cancelled = true
    }
  }, [status])

  return (
    <div>
      <PageHeader
        title="Submissions"
        subtitle="Review write requests from the app, then approve or reject."
      />

      <div className="mb-4 flex flex-wrap gap-2">
        {filters.map((f) => (
          <button
            key={f.label}
            type="button"
            onClick={() => setStatus(f.value)}
            className={[
              'rounded-md border px-3 py-1.5 text-sm font-medium transition',
              status === f.value
                ? 'border-forest bg-forest text-white'
                : 'border-line bg-panel text-ink hover:bg-paper',
            ].join(' ')}
          >
            {f.label}
          </button>
        ))}
      </div>

      {error ? <ErrorBanner message={error} /> : null}

      {loading ? (
        <p className="text-sm text-ink-muted">Loading…</p>
      ) : items.length === 0 ? (
        <EmptyState message="No submissions in this filter." />
      ) : (
        <div className="overflow-hidden rounded-lg border border-line bg-panel">
          <ul className="divide-y divide-line">
            {items.map((item) => (
              <li key={item.id}>
                <Link
                  to={`/submissions/${item.id}`}
                  className="flex flex-col gap-2 px-4 py-4 transition hover:bg-paper sm:flex-row sm:items-center sm:justify-between"
                >
                  <div className="min-w-0">
                    <p className="font-ethiopic truncate font-medium text-ink">
                      {item.title}
                    </p>
                    <p className="mt-1 text-sm text-ink-muted">
                      {item.categoryName}
                      {item.submitterName ? ` · ${item.submitterName}` : ''}
                      {' · '}
                      {formatDate(item.createdAt)}
                    </p>
                  </div>
                  <StatusBadge status={item.status as SubmissionStatus} />
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
