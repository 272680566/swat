<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="sidebar-header">
        <h2>SWAT 问题管理</h2>
      </div>
      <nav class="sidebar-nav">
        <router-link to="/home/dashboard" class="nav-item">
          <span class="nav-icon">&#x2302;</span> 首页概览
        </router-link>
        <router-link to="/home/issues" class="nav-item">
          <span class="nav-icon">&#x1F4CB;</span> 问题列表
        </router-link>
        <router-link to="/home/create" class="nav-item">
          <span class="nav-icon">&#x2795;</span> 创建问题
        </router-link>
        <router-link to="/home/statistics" class="nav-item">
          <span class="nav-icon">&#x1F4CA;</span> 问题统计
        </router-link>
        <router-link to="/home/users" class="nav-item">
          <span class="nav-icon">&#x1F465;</span> 用户管理
        </router-link>

        <div class="submenu-group" :class="{ open: openMenu === 'config' }">
          <div class="nav-item submenu-toggle" @click="openMenu = openMenu === 'config' ? '' : 'config'">
            <span class="nav-icon">&#x2699;</span> 配置管理
            <span class="arrow">{{ openMenu === 'config' ? '&#x25B4;' : '&#x25BE;' }}</span>
          </div>
          <div class="submenu-items">
            <router-link to="/home/sites" class="nav-item sub-item">
              局点管理
            </router-link>
            <router-link to="/home/versions" class="nav-item sub-item">
              版本管理
            </router-link>
            <router-link to="/home/categories" class="nav-item sub-item">
              分类管理
            </router-link>
            <router-link to="/home/rls" class="nav-item sub-item">
              RL管理
            </router-link>
          </div>
        </div>
      </nav>
    </aside>

    <div class="main-area">
      <header class="topbar">
        <div class="breadcrumb">{{ pageTitle }}</div>
        <div class="user-area">
          <span class="user-name">{{ username }}</span>
          <button @click="logout" class="btn-logout">退出</button>
        </div>
      </header>

      <main class="content">
        <keep-alive include="IssuesView">
          <router-view />
        </keep-alive>
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HomeView',
  data() {
    return {
      username: 'admin',
      openMenu: ''
    }
  },
  computed: {
    pageTitle() {
      const titles = {
        dashboard: '首页概览',
        issues: '问题列表',
        create: '创建问题',
        statistics: '问题统计',
        users: '用户管理',
        sites: '局点管理',
        versions: '版本管理',
        categories: '分类管理',
        rls: 'RL管理'
      }
      return titles[this.$route.name] || '首页'
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'sites' || to.name === 'versions' || to.name === 'categories' || to.name === 'rls') {
        this.openMenu = 'config'
      }
    }
  },
  methods: {
    logout() {
      this.$router.push('/')
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background: #f0f2f5;
}

.layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 220px;
  background: #001529;
  color: #fff;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.sidebar-header {
  padding: 20px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}

.sidebar-header h2 {
  font-size: 18px;
  color: #fff;
  white-space: nowrap;
}

.sidebar-nav {
  flex: 1;
  padding: 8px 0;
  overflow-y: auto;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 12px 24px;
  color: rgba(255,255,255,0.65);
  text-decoration: none;
  font-size: 14px;
  transition: all 0.2s;
  border-left: 3px solid transparent;
  cursor: pointer;
}

.nav-item:hover {
  color: #fff;
  background: rgba(255,255,255,0.08);
}

.nav-item.router-link-active {
  color: #fff;
  background: #1890ff;
  border-left-color: #69c0ff;
}

.nav-icon {
  margin-right: 10px;
  font-size: 16px;
}

.submenu-toggle {
  justify-content: flex-start;
}

.submenu-toggle .arrow {
  margin-left: auto;
  font-size: 12px;
  transition: transform 0.2s;
}

.submenu-items {
  overflow: hidden;
  max-height: 0;
  transition: max-height 0.3s ease;
}

.submenu-group.open .submenu-items {
  max-height: 200px;
}

.sub-item {
  padding: 10px 24px 10px 56px;
  font-size: 13px;
}

.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.topbar {
  height: 56px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  flex-shrink: 0;
}

.breadcrumb {
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

.user-area {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-name {
  color: #666;
  font-size: 14px;
}

.btn-logout {
  padding: 6px 16px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #666;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-logout:hover {
  color: #ff4d4f;
  border-color: #ff4d4f;
}

.content {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
}
</style>
