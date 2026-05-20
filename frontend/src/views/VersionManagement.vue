<template>
  <div>
    <div class="panel-header">
      <h3>版本管理</h3>
      <button class="btn-add" @click="openAdd">&#x2795; 新增版本</button>
    </div>

    <div class="panel">
      <table class="table">
        <thead>
          <tr>
            <th>版本号</th>
            <th>关联局点</th>
            <th>发布日期</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="ver in versions" :key="ver.id">
            <td><code>{{ ver.versionCode }}</code></td>
            <td>
              <span class="site-tag" v-for="name in resolveSiteNames(ver.sites)" :key="name">{{ name }}</span>
              <span v-if="!ver.sites || resolveSiteNames(ver.sites).length === 0" class="no-sites">-</span>
            </td>
            <td>{{ ver.releaseDate || '-' }}</td>
            <td>
              <span :class="['status-tag', 'status-' + ver.status]">{{ statusMap[ver.status] }}</span>
            </td>
            <td>
              <button class="btn-action" @click="editVersion(ver)">编辑</button>
              <button class="btn-action danger" @click="deleteVersion(ver)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="versions.length === 0" class="empty">暂无版本记录</div>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑版本' : '新增版本' }}</h3>
        <form @submit.prevent="saveVersion">
          <div class="form-row">
            <div class="form-group">
              <label>版本号 <span class="required">*</span></label>
              <input v-model="form.versionCode" type="text" placeholder="如 505.2.1.SPC0800" />
            </div>
            <div class="form-group">
              <label>发布日期</label>
              <input v-model="form.releaseDate" type="date" />
            </div>
          </div>

          <!-- Read-only associated sites display (edit mode only) -->
          <div class="form-group" v-if="editing">
            <label>关联局点</label>
            <div class="site-list-readonly">
              <span v-for="name in editRelatedSites" :key="name" class="site-tag">{{ name }}</span>
              <span v-if="editRelatedSites.length === 0" class="no-sites">暂未关联任何局点（可在局点管理中编辑关联）</span>
            </div>
          </div>

          <div class="form-group">
            <label>状态</label>
            <select v-model="form.status">
              <option value="dev">开发中</option>
              <option value="test">测试中</option>
              <option value="released">已发布</option>
              <option value="archived">已归档</option>
            </select>
          </div>
          <div class="form-group">
            <label>变更说明</label>
            <textarea v-model="form.notes" rows="4" placeholder="请输入版本变更说明..."></textarea>
          </div>
          <div v-if="errorMsg" class="msg-error">{{ errorMsg }}</div>
          <div class="form-actions">
            <button type="submit" class="btn-submit" :disabled="saving">
              {{ saving ? '保存中...' : '保存' }}
            </button>
            <button type="button" class="btn-cancel" @click="showModal = false">取消</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { fetchVersions, createVersion, updateVersion, deleteVersion, checkVersionCode } from '../api'
import { fetchSites } from '../api'

export default {
  name: 'VersionManagementView',
  data() {
    return {
      showModal: false,
      editing: false,
      editId: null,
      originalVersionCode: '',
      saving: false,
      errorMsg: '',
      form: { versionCode: '', releaseDate: '', status: 'dev', notes: '' },
      statusMap: { dev: '开发中', test: '测试中', released: '已发布', archived: '已归档' },
      allSites: [],
      versions: [],
      editRelatedSites: []
    }
  },
  computed: {
    siteMap() {
      const map = {}
      this.allSites.forEach(s => { map[s.id] = s.name })
      return map
    }
  },
  async mounted() {
    await this.loadSites()
    await this.loadVersions()
  },
  methods: {
    async loadVersions() {
      try {
        const res = await fetchVersions()
        this.versions = Array.isArray(res.data) ? res.data : []
      } catch {
        this.versions = []
      }
    },
    async loadSites() {
      try {
        const res = await fetchSites('')
        this.allSites = Array.isArray(res.data) ? res.data : []
      } catch {
        this.allSites = []
      }
    },
    parseIds(raw) {
      if (!raw) return []
      if (Array.isArray(raw)) return raw
      try {
        return JSON.parse(raw)
      } catch {
        return raw.split(',').map(s => s.trim()).filter(Boolean)
      }
    },
    resolveSiteNames(raw) {
      const ids = this.parseIds(raw)
      return ids.map(id => this.siteMap[id] || String(id)).filter(Boolean)
    },
    openAdd() {
      this.editing = false
      this.editId = null
      this.originalVersionCode = ''
      this.errorMsg = ''
      this.form = { versionCode: '', releaseDate: '', status: 'dev', notes: '' }
      this.showModal = true
    },
    editVersion(ver) {
      this.editing = true
      this.editId = ver.id
      this.originalVersionCode = ver.versionCode
      this.errorMsg = ''
      this.form = {
        versionCode: ver.versionCode,
        releaseDate: ver.releaseDate || '',
        status: ver.status,
        notes: ver.notes || ''
      }
      this.editRelatedSites = this.resolveSiteNames(ver.sites)
      this.showModal = true
    },
    async saveVersion() {
      this.errorMsg = ''
      if (!this.form.versionCode) {
        this.errorMsg = '版本号不能为空'
        return
      }
      const codeChanged = this.editing && this.form.versionCode !== this.originalVersionCode
      if (!this.editing || codeChanged) {
        try {
          const checkRes = await checkVersionCode(this.form.versionCode)
          if (checkRes.data && checkRes.data.exists) {
            this.errorMsg = '版本号已存在，请更换'
            this.saving = false
            return
          }
        } catch {
          // Continue — backend will also validate
        }
      }
      this.saving = true
      try {
        const payload = {
          versionCode: this.form.versionCode,
          releaseDate: this.form.releaseDate || null,
          status: this.form.status,
          notes: this.form.notes
        }
        let res
        if (this.editing) {
          res = await updateVersion(this.editId, payload)
        } else {
          res = await createVersion(payload)
        }
        if (res.data.success) {
          this.showModal = false
          this.loadVersions()
        } else {
          this.errorMsg = res.data.message
        }
      } catch {
        this.errorMsg = '网络错误，请稍后重试'
      } finally {
        this.saving = false
      }
    },
    async deleteVersion(ver) {
      if (!confirm(`确定删除版本「${ver.versionCode}」吗？`)) return
      try {
        const res = await deleteVersion(ver.id)
        if (res.data.success) {
          this.loadVersions()
        } else {
          alert(res.data.message)
        }
      } catch {
        alert('删除失败，请稍后重试')
      }
    }
  }
}
</script>

<style scoped>
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
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

.panel {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.table { width: 100%; border-collapse: collapse; }

.table th, .table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}
.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }

code {
  background: #f5f5f5;
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 12px;
  color: #d4380d;
}

.site-tag {
  display: inline-block;
  padding: 2px 6px;
  margin: 2px 4px 2px 0;
  background: #e6f7ff;
  color: #1890ff;
  border-radius: 3px;
  font-size: 12px;
}

.no-sites { color: #ccc; font-size: 13px; }

.status-tag { padding: 2px 8px; border-radius: 3px; font-size: 12px; }
.status-dev { color: #1890ff; background: #e6f7ff; }
.status-test { color: #fa8c16; background: #fff7e6; }
.status-released { color: #52c41a; background: #f6ffed; }
.status-archived { color: #999; background: #f5f5f5; }

.btn-action {
  padding: 4px 10px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #1890ff;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  margin-right: 6px;
}

.btn-action:hover { border-color: #1890ff; }
.btn-action.danger { color: #ff4d4f; }
.btn-action.danger:hover { border-color: #ff4d4f; }

.empty { text-align: center; padding: 40px; color: #999; font-size: 14px; }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 6vh 20px 20px;
  overflow-y: auto;
  z-index: 100;
}

.modal {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 6px 30px rgba(0,0,0,0.2);
}

.modal h3 { margin-bottom: 16px; font-size: 16px; }

.form-group { margin-bottom: 14px; }
.form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 4px; }

.required { color: #ff4d4f; }

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  font-family: inherit;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  border-color: #1890ff;
}

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

.site-list-readonly {
  min-height: 32px;
  padding: 6px 8px;
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.msg-error {
  color: #ff4d4f;
  font-size: 13px;
  background: #fff1f0;
  padding: 8px 12px;
  border-radius: 4px;
  margin-bottom: 12px;
}

.form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }

.btn-submit {
  padding: 8px 20px;
  background: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-submit:hover { opacity: 0.85; }
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }

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
