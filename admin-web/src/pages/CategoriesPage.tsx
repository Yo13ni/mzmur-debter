import { useEffect, useState, type FormEvent } from 'react'
import { api, ApiError } from '../api/client'
import type { Category } from '../api/types'
import { EmptyState, ErrorBanner, PageHeader } from '../components/ui'

export function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([])
  const [name, setName] = useState('')
  const [sortOrder, setSortOrder] = useState(0)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)

  async function load() {
    setLoading(true)
    setError('')
    try {
      setCategories(await api.listCategories())
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : 'Failed to load categories',
      )
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void load()
  }, [])

  function startEdit(cat: Category) {
    setEditingId(cat.id)
    setName(cat.name)
    setSortOrder(cat.sortOrder)
  }

  function resetForm() {
    setEditingId(null)
    setName('')
    setSortOrder(0)
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setBusy(true)
    setError('')
    try {
      if (editingId) {
        await api.updateCategory(editingId, { name, sortOrder })
      } else {
        await api.createCategory({ name, sortOrder })
      }
      resetForm()
      await load()
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Save failed')
    } finally {
      setBusy(false)
    }
  }

  async function onDelete(id: string) {
    if (!confirm('Delete this category? Poems using it may block delete.')) {
      return
    }
    setBusy(true)
    setError('')
    try {
      await api.deleteCategory(id)
      if (editingId === id) resetForm()
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
        title="Categories"
        subtitle="Liturgical categories used by poems and submissions."
      />

      {error ? <ErrorBanner message={error} /> : null}

      <form
        onSubmit={onSubmit}
        className="mb-6 grid gap-3 rounded-lg border border-line bg-panel p-4 sm:grid-cols-[1fr_120px_auto_auto]"
      >
        <input
          required
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Category name"
          className="rounded-md border border-line px-3 py-2 font-ethiopic text-sm outline-none ring-forest focus:ring-2"
        />
        <input
          type="number"
          min={0}
          value={sortOrder}
          onChange={(e) => setSortOrder(Number(e.target.value))}
          className="rounded-md border border-line px-3 py-2 text-sm outline-none ring-forest focus:ring-2"
          title="Sort order"
        />
        <button
          type="submit"
          disabled={busy}
          className="rounded-md bg-forest px-3 py-2 text-sm font-semibold text-white hover:bg-forest-dark disabled:opacity-60"
        >
          {editingId ? 'Update' : 'Add'}
        </button>
        {editingId ? (
          <button
            type="button"
            onClick={resetForm}
            className="rounded-md border border-line px-3 py-2 text-sm hover:bg-paper"
          >
            Cancel
          </button>
        ) : (
          <span />
        )}
      </form>

      {loading ? (
        <p className="text-sm text-ink-muted">Loading…</p>
      ) : categories.length === 0 ? (
        <EmptyState message="No categories yet." />
      ) : (
        <div className="overflow-hidden rounded-lg border border-line bg-panel">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-line bg-paper text-ink-muted">
              <tr>
                <th className="px-4 py-3 font-medium">Name</th>
                <th className="px-4 py-3 font-medium">Order</th>
                <th className="px-4 py-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {categories.map((cat) => (
                <tr key={cat.id}>
                  <td className="px-4 py-3 font-ethiopic font-medium">
                    {cat.name}
                  </td>
                  <td className="px-4 py-3 text-ink-muted">{cat.sortOrder}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <button
                        type="button"
                        onClick={() => startEdit(cat)}
                        className="rounded-md border border-line px-2.5 py-1 text-xs hover:bg-paper"
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        disabled={busy}
                        onClick={() => void onDelete(cat.id)}
                        className="rounded-md border border-rose/30 px-2.5 py-1 text-xs text-rose hover:bg-rose/5 disabled:opacity-60"
                      >
                        Delete
                      </button>
                    </div>
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
