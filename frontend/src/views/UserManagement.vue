<template>
  <div class="panel">
    <div class="panel-header">
      <h3>用户管理</h3>
      <button class="btn-add" @click="openAdd">&#x2795; 新增用户</button>
    </div>

    <table class="table">
      <thead>
        <tr>
          <th>用户名</th><th>邮箱</th><th>角色</th><th>状态</th><th>创建时间</th><th>操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.username }}</td>
          <td>{{ user.email }}</td>
          <td><span :class="'role-tag role-' + user.role">{{ user.role }}</span></td>
          <td>
            <span :class="user.active ? 'status-on' : 'status-off'">
              {{ user.active ? '启用' : '禁用' }}
            </span>
          </td>
          <td>{{ user.createdAt }}</td>
          <td>
            <button class="btn-edit" @click="toggleStatus(user)">
              {{ user.active ? '禁用' : '启用' }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>新增用户</h3>
        <form @submit.prevent="addUser">
          <div class="form-group">
            <label>用户名</label>
            <input v-model="newUser.username" type="text" placeholder="请输入用户名" />
          </div>
          <div class="form-group">
            <label>邮箱</label>
            <input v-model="newUser.email" type="email" placeholder="请输入邮箱" />
          </div>
          <div class="form-group">
            <label>角色</label>
            <select v-model="newUser.role">
              <option value="admin">管理员</option>
              <option value="developer">开发者</option>
              <option value="viewer">观察者</option>
            </select>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn-submit">确认添加</button>
            <button type="button" class="btn-cancel" @click="showModal = false">取消</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserManagementView',
  data() {
    return {
      showModal: false,
      newUser: { username: '', email: '', role: 'developer' },
      users: [
        { id: 1, username: 'admin', email: 'admin@swat.com', role: 'admin', active: true, createdAt: '2026-01-15' },
        { id: 2, username: 'zhangsan', email: 'zhangsan@swat.com', role: 'developer', active: true, createdAt: '2026-02-10' },
        { id: 3, username: 'lisi', email: 'lisi@swat.com', role: 'developer', active: false, createdAt: '2026-03-05' },
        { id: 4, username: 'wangwu', email: 'wangwu@swat.com', role: 'viewer', active: true, createdAt: '2026-04-20' }
      ]
    }
  },
  methods: {
    openAdd() { this.showModal = true },
    toggleStatus(user) { user.active = !user.active },
    addUser() {
      if (!this.newUser.username || !this.newUser.email) return
      this.users.push({
        id: Date.now(),
        ...this.newUser,
        active: true,
        createdAt: new Date().toISOString().slice(0, 10)
      })
      this.newUser = { username: '', email: '', role: 'developer' }
      this.showModal = false
    }
  }
}
</script>

<style scoped>
.panel {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.panel-header h3 { font-size: 16px; color: #333; }

.btn-add {
  padding: 8px 16px;
  background: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
}

.btn-add:hover { opacity: 0.85; }

.table { width: 100%; border-collapse: collapse; }

.table th, .table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }

.role-tag { padding: 2px 8px; border-radius: 3px; font-size: 12px; }
.role-admin { color: #fff; background: #1890ff; }
.role-developer { color: #1890ff; background: #e6f7ff; border: 1px solid #91d5ff; }
.role-viewer { color: #666; background: #fafafa; border: 1px solid #d9d9d9; }

.status-on { color: #52c41a; }
.status-off { color: #d9d9d9; }

.btn-edit {
  padding: 4px 12px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #666;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
}

.btn-edit:hover { border-color: #1890ff; color: #1890ff; }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.modal {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  width: 420px;
  box-shadow: 0 6px 30px rgba(0,0,0,0.2);
}

.modal h3 { margin-bottom: 16px; font-size: 16px; }

.form-group { margin-bottom: 14px; }

.form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 4px; }

.form-group input, .form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
}

.form-group input:focus, .form-group select:focus { border-color: #1890ff; }

.form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }

.btn-submit {
  padding: 8px 20px;
  background: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-cancel {
  padding: 8px 20px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #666;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}
</style>
