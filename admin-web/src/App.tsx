import { Navigate, Route, Routes } from 'react-router-dom'
import { AdminLayout, RequireAuth } from './components/AdminLayout'
import { LoginPage } from './pages/LoginPage'
import { SubmissionsPage } from './pages/SubmissionsPage'
import { SubmissionDetailPage } from './pages/SubmissionDetailPage'
import { PoemsPage } from './pages/PoemsPage'
import { CategoriesPage } from './pages/CategoriesPage'

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAuth />}>
        <Route element={<AdminLayout />}>
          <Route index element={<Navigate to="/submissions" replace />} />
          <Route path="/submissions" element={<SubmissionsPage />} />
          <Route path="/submissions/:id" element={<SubmissionDetailPage />} />
          <Route path="/poems" element={<PoemsPage />} />
          <Route path="/categories" element={<CategoriesPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/submissions" replace />} />
    </Routes>
  )
}
