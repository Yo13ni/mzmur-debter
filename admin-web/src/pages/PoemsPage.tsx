import { useEffect, useState, type FormEvent } from 'react'
import { api, ApiError } from '../api/client'
import type { Category, Poem } from '../api/types'
import { EmptyState, ErrorBanner, PageHeader } from '../components/ui'

const emptyForm = { title: '', content: '', categoryId: '' }

export function PoemsPage() {
  const [poems, setPoems] = useState<Poem[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [q, setQ] = useState('')
  const [categoryId, setCategoryId] = useState('')
  const [form, setForm] = useState(emptyForm)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [showForm, setShowForm] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)

  async function load(search = q, cat = categoryId) {
    setLoading(true)
    setError('')
    try {
      const [poemRows, cats] = await Promise.all([
        api.listPoems({
          q: search.trim() || undefined,
          categoryId: cat || undefined,
        }),
        api.listCategories(),
      ])
      setPoems(poemRows)
      setCategories(cats)
      if (!form.categoryId && cats[0]) {
        setForm((f) => ({ ...f, categoryId: cats[0].id }))
      }
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Failed to load poems')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void load()
    // initial load only
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  function startCreate() {
    setEditingId(null)
    setForm({
      title: '',
      content: '',
      categoryId: categories[0]?.id ?? '',
    })
    setShowForm(true)
  }

  function startEdit(poem: Poem) {
    setEditingId(poem.id)
    setForm({
      title: poem.title,
      content: poem.content,
      categoryId: poem.categoryId,
    })
    setShowForm(true)
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setBusy(true)
    setError('')
    try {
      if (editingId) {
        await api.updatePoem(editingId, form)
      } else {
        await api.createPoem(form)
      }
      setShowForm(false)
      setEditingId(null)
      await load()
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Save failed')
    } finally {
      setBusy(false)
    }
  }

  async function onDelete(id: string) {
    if (!confirm('Delete this poem?')) return
    setBusy(true)
    setError('')
    try {
      await api.deletePoem(id)
      await load()
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Delete failed')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div>
      <PageHeader
        title="Poems"
        subtitle="Published hymns shown in the app."
        actions={
          <button
            type="button"
            onClick={startCreate}
            className="rounded-md bg-forest px-3 py-1.5 text-sm font-semibold text-white hover:bg-forest-dark"
          >
            New poem
          </button>
        }
      />

      <div className="mb-4 flex flex-col gap-2 sm:flex-row">
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Search title or content"
          className="flex-1 rounded-md border border-line bg-panel px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
        />
        <select
          value={categoryId}
          onChange={(e) => setCategoryId(e.target.value)}
          className="rounded-md border border-line bg-panel px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
        >
          <option value="">All categories</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
        <button
          type="button"
          onClick={() => void load()}
          className="rounded-md border border-line bg-panel px-3 py-2 text-sm font-medium hover:bg-paper"
        >
          Search
        </button>
      </div>

      {error ? <ErrorBanner message={error} /> : null}

      {showForm ? (
        <form
          onSubmit={onSubmit}
          className="mb-6 space-y-3 rounded-lg border border-line bg-panel p-4"
        >
          <h2 className="text-sm font-semibold">
            {editingId ? 'Edit poem' : 'Create poem'}
          </h2>
          <input
            required
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            placeholder="Title"
            className="w-full rounded-md border border-line px-3 py-2 font-ethiopic text-sm outline-none ring-forest focus:ring-2"
          />
          <select
            required
            value={form.categoryId}
            onChange={(e) => setForm({ ...form, categoryId: e.target.value })}
            className="w-full rounded-md border border-line px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
          >
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          <textarea
            required
            rows={8}
            value={form.content}
            onChange={(e) => setForm({ ...form, content: e.target.value })}
            placeholder="Content"
            className="w-full rounded-md border border-line px-3 py-2 font-ethiopic text-sm leading-relaxed outline-none ring-forest focus:ring-2"
          />
          <div className="flex gap-2">
            <button
              type="submit"
              disabled={busy}
              className="rounded-md bg-forest px-3 py-1.5 text-sm font-semibold text-white hover:bg-forest-dark disabled:opacity-60"
            >
              Save
            </button>
            <button
              type="button"
              onClick={() => setShowForm(false)}
              className="rounded-md border border-line px-3 py-1.5 text-sm hover:bg-paper"
            >
              Cancel
            </button>
          </div>
        </form>
      ) : null}

      {loading ? (
        <p className="text-sm text-ink-muted">Loading…</p>
      ) : poems.length === 0 ? (
        <EmptyState message="No poems found." />
      ) : (
        <div className="overflow-hidden rounded-lg border border-line bg-panel">
          <ul className="divide-y divide-line">
            {poems.map((poem) => (
              <li
                key={poem.id}
                className="flex flex-col gap-3 px-4 py-4 sm:flex-row sm:items-start sm:justify-between"
              >
                <div className="min-w-0">
                  <p className="font-ethiopic font-medium">{poem.title}</p>
                  <p className="mt-1 text-sm text-ink-muted">
                    {poem.categoryName} ·{' '}
                    {new Date(poem.createdAt).toLocaleDateString()}
                  </p>
                  <p className="mt-2 line-clamp-2 text-sm text-ink-muted font-ethiopic">
                    {poem.content}
                  </p>
                </div>
                <div className="flex shrink-0 gap-2">
                  <button
                    type="button"
                    onClick={() => startEdit(poem)}
                    className="rounded-md border border-line px-3 py-1.5 text-sm hover:bg-paper"
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() => void onDelete(poem.id)}
                    className="rounded-md border border-rose/30 px-3 py-1.5 text-sm text-rose hover:bg-rose/5 disabled:opacity-60"
                  >
                    Delete
                  </button>
                </div>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
