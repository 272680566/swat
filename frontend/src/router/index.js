import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Home from '../views/Home.vue'
import Dashboard from '../views/Dashboard.vue'
import Issues from '../views/Issues.vue'
import IssueDetail from '../views/IssueDetail.vue'
import CreateIssue from '../views/CreateIssue.vue'
import Statistics from '../views/Statistics.vue'
import UserManagement from '../views/UserManagement.vue'
import SiteManagement from '../views/SiteManagement.vue'
import VersionManagement from '../views/VersionManagement.vue'
import CategoryManagement from '../views/CategoryManagement.vue'
import RlManagement from '../views/RlManagement.vue'

const routes = [
  {
    path: '/',
    name: 'Login',
    component: Login
  },
  {
    path: '/home',
    component: Home,
    redirect: '/home/dashboard',
    children: [
      { path: 'dashboard', name: 'dashboard', component: Dashboard },
      { path: 'issues', name: 'issues', component: Issues },
      { path: 'issues/:id', name: 'issueDetail', component: IssueDetail },
      { path: 'create', name: 'create', component: CreateIssue },
      { path: 'statistics', name: 'statistics', component: Statistics },
      { path: 'users', name: 'users', component: UserManagement },
      { path: 'sites', name: 'sites', component: SiteManagement },
      { path: 'versions', name: 'versions', component: VersionManagement },
      { path: 'categories', name: 'categories', component: CategoryManagement },
      { path: 'rls', name: 'rls', component: RlManagement }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
