import { useEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { api, ApiError } from '../api/client'
import type { Category, Submission, SubmissionStatus } from '../api/types'
import { ErrorBanner, PageHeader, StatusBadge } from '../components/ui'

export function SubmissionDetailPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [submission, setSubmission] = useState<Submission | null>(null)
  const [categories, setCategories] = useState<Category[]>([])
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [categoryId, setCategoryId] = useState('')
  const [adminNote, setAdminNote] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) return
    let cancelled = false
    async function load() {
      setLoading(true)
      setError('')
      try {
        const [sub, cats] = await Promise.all([
          api.getSubmission(id!),
          api.listCategories(),
        ])
        if (cancelled) return
        setSubmission(sub)
        setCategories(cats)
        setTitle(sub.title)
        setContent(sub.content)
        setCategoryId(sub.categoryId)
        setAdminNote(sub.adminNote ?? '')
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
  }, [id])

  const canReview =
    submission?.status === 'PENDING' || submission?.status === 'NEEDS_CHANGES'

  async function onApprove(e: FormEvent) {
    e.preventDefault()
    if (!id || !canReview) return
    setBusy(true)
    setError('')
    try {
      await api.approveSubmission(id, { title, content, categoryId })
      navigate('/submissions')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Approve failed')
    } finally {
      setBusy(false)
    }
  }

  async function onReject(status: 'REJECTED' | 'NEEDS_CHANGES') {
    if (!id || !canReview) return
    setBusy(true)
    setError('')
    try {
      await api.rejectSubmission(id, {
        adminNote: adminNote.trim() || undefined,
        status,
      })
      navigate('/submissions')
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Reject failed')
    } finally {
      setBusy(false)
    }
  }

  if (loading) {
    return <p className="text-sm text-ink-muted">Loading…</p>
  }

  if (!submission) {
    return (
      <div>
        <ErrorBanner message={error || 'Submission not found'} />
        <Link to="/submissions" className="text-sm text-forest underline">
          Back to queue
        </Link>
      </div>
    )
  }

  return (
    <div>
      <PageHeader
        title="Review submission"
        subtitle="Edit before publish, or send back with a note."
        actions={
          <Link
            to="/submissions"
            className="rounded-md border border-line bg-panel px-3 py-1.5 text-sm hover:bg-paper"
          >
            Back
          </Link>
        }
      />

      {error ? <ErrorBanner message={error} /> : null}

      <div className="mb-4 flex flex-wrap items-center gap-3 text-sm text-ink-muted">
        <StatusBadge status={submission.status as SubmissionStatus} />
        <span>{submission.categoryName}</span>
        {submission.submitterName ? (
          <span>from {submission.submitterName}</span>
        ) : null}
        <span>{new Date(submission.createdAt).toLocaleString()}</span>
      </div>

      <form onSubmit={onApprove} className="space-y-4">
        <label className="block text-sm">
          <span className="mb-1.5 block font-medium">Title</span>
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={!canReview}
            required
            className="w-full rounded-md border border-line bg-panel px-3 py-2 font-ethiopic outline-none ring-forest focus:ring-2 disabled:opacity-70"
          />
        </label>

        <label className="block text-sm">
          <span className="mb-1.5 block font-medium">Category</span>
          <select
            value={categoryId}
            onChange={(e) => setCategoryId(e.target.value)}
            disabled={!canReview}
            className="w-full rounded-md border border-line bg-panel px-3 py-2 outline-none ring-forest focus:ring-2 disabled:opacity-70"
          >
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </label>

        <label className="block text-sm">
          <span className="mb-1.5 block font-medium">Content</span>
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            disabled={!canReview}
            required
            rows={14}
            className="w-full rounded-md border border-line bg-panel px-3 py-2 font-ethiopic leading-relaxed outline-none ring-forest focus:ring-2 disabled:opacity-70"
          />
        </label>

        {canReview ? (
          <>
            <label className="block text-sm">
              <span className="mb-1.5 block font-medium">
                Admin note (for reject / needs changes)
              </span>
              <textarea
                value={adminNote}
                onChange={(e) => setAdminNote(e.target.value)}
                rows={3}
                className="w-full rounded-md border border-line bg-panel px-3 py-2 outline-none ring-forest focus:ring-2"
                placeholder="Optional feedback to the submitter"
              />
            </label>

            <div className="flex flex-wrap gap-2 pt-2">
              <button
                type="submit"
                disabled={busy}
                className="rounded-md bg-forest px-4 py-2 text-sm font-semibold text-white hover:bg-forest-dark disabled:opacity-60"
              >
                Approve & publish
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => void onReject('NEEDS_CHANGES')}
                className="rounded-md border border-line bg-panel px-4 py-2 text-sm font-medium hover:bg-paper disabled:opacity-60"
              >
                Needs changes
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => void onReject('REJECTED')}
                className="rounded-md bg-rose px-4 py-2 text-sm font-semibold text-white hover:bg-rose/90 disabled:opacity-60"
              >
                Reject
              </button>
            </div>
          </>
        ) : (
          <p className="rounded-md border border-line bg-paper px-4 py-3 text-sm text-ink-muted">
            This submission is already {submission.status.toLowerCase()}.
            {submission.adminNote ? ` Note: ${submission.adminNote}` : ''}
          </p>
        )}
      </form>
    </div>
  )
}
