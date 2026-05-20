import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
})

export function login(username, password) {
  return api.post('/user/login', { username, password })
}

export function register(username, password, email) {
  return api.post('/user/register', { username, password, email })
}

// Site APIs
export function fetchSites(keyword) {
  return api.get('/sites', { params: { keyword } })
}

export function fetchSite(id) {
  return api.get(`/sites/${id}`)
}

export function createSite(data) {
  return api.post('/sites', data)
}

export function updateSite(id, data) {
  return api.put(`/sites/${id}`, data)
}

export function deleteSite(id) {
  return api.delete(`/sites/${id}`)
}

export function checkSiteName(name) {
  return api.get('/sites/check-name', { params: { name } })
}

// Version APIs
export function fetchVersions() {
  return api.get('/versions')
}

export function fetchVersion(id) {
  return api.get(`/versions/${id}`)
}

export function createVersion(data) {
  return api.post('/versions', data)
}

export function updateVersion(id, data) {
  return api.put(`/versions/${id}`, data)
}

export function deleteVersion(id) {
  return api.delete(`/versions/${id}`)
}

export function checkVersionCode(code) {
  return api.get('/versions/check-code', { params: { code } })
}

// Issue APIs
export function fetchIssues(keyword, status, page, pageSize) {
  return api.get('/issues', { params: { keyword, status, page, pageSize } })
}

export function fetchIssue(id) {
  return api.get(`/issues/${id}`)
}

export function createIssue(data) {
  return api.post('/issues', data)
}

export function updateIssue(id, data) {
  return api.put(`/issues/${id}`, data)
}

export function deleteIssue(id) {
  return api.delete(`/issues/${id}`)
}

// Issue Category APIs
export function fetchCategoryTree() {
  return api.get('/issue-categories/tree')
}

export function fetchCategories() {
  return api.get('/issue-categories')
}

export function createCategory(data) {
  return api.post('/issue-categories', data)
}

export function updateCategory(id, data) {
  return api.put(`/issue-categories/${id}`, data)
}

export function deleteCategory(id) {
  return api.delete(`/issue-categories/${id}`)
}

// RL APIs
export function fetchRls() { return api.get('/rls') }
export function createRl(data) { return api.post('/rls', data) }
export function updateRl(id, data) { return api.put(`/rls/${id}`, data) }
export function deleteRl(id) { return api.delete(`/rls/${id}`) }
