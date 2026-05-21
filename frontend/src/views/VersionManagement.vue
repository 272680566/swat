<template>
  <div>
    <div class="panel-header">
      <h3>版本管理</h3>
      <div class="header-btns">
        <button class="btn-import" @click="openImport">&#x1F4C1; 批量导入</button>
        <button class="btn-add" @click="openAdd">&#x2795; 新增版本</button>
      </div>
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
            <td class="site-tags-cell">
              <span class="site-tag" v-for="name in resolveSiteNames(ver.sites).slice(0, 2)" :key="name">{{ name }}</span>
              <span v-if="resolveSiteNames(ver.sites).length > 2" class="site-more">+{{ resolveSiteNames(ver.sites).length - 2 }}</span>
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

      <div class="pagination">
        <div class="page-left">
          <select v-model.number="pageSize" class="page-size-select" @change="onPageSizeChange">
            <option :value="10">10 条/页</option>
            <option :value="20">20 条/页</option>
            <option :value="50">50 条/页</option>
          </select>
        </div>
        <div class="page-center">
          <button class="page-btn" :disabled="page <= 1" @click="goPage(1)">首页</button>
          <button class="page-btn" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
          <button v-for="p in pageNumbers" :key="p" class="page-btn" :class="{ active: p === page }" @click="goPage(p)">{{ p }}</button>
          <button class="page-btn" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
          <button class="page-btn" :disabled="page >= totalPages" @click="goPage(totalPages)">末页</button>
        </div>
        <span class="page-info">共 {{ total }} 条</span>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑版本' : '新增版本' }}</h3>
        <form @submit.prevent="saveVersion">
          <div class="form-row">
            <div class="form-group">
              <label>版本号 <span class="required">*</span></label>
              <input v-model="form.versionCode" type="text" placeholder="如 505.2.1.SPC0800" :disabled="editing" :class="{ 'input-disabled': editing }" />
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
            <label>版本说明</label>
            <textarea v-model="form.notes" rows="4" placeholder="请输入版本说明..."></textarea>
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

  <!-- Import Modal -->
  <div class="modal-overlay" v-if="showImport" @click.self="showImport = false">
    <div class="modal">
      <h3>批量导入版本</h3>
      <div class="import-area" @click="pickImportFile">
        <input type="file" ref="importFileInput" accept=".csv,.xlsx,.xls" @change="handleImportFile" class="import-file-input" />
        <div class="import-upload">
          <span class="import-icon">&#x1F4C2;</span>
          <p>点击选择文件</p>
          <p class="import-hint">支持 Excel（.xlsx）格式，解析列：版本号</p>
        </div>
      </div>
      <div v-if="importPreview.length" class="import-preview">
        <h4>预览 ({{ importPreview.length }} 条)</h4>
        <div class="preview-table-wrap">
          <table class="preview-table">
            <thead><tr><th v-for="k in importKeys" :key="k">{{ k }}</th></tr></thead>
            <tbody>
              <tr v-for="(row, idx) in importPreview.slice(0, 8)" :key="idx">
                <td v-for="k in importKeys" :key="k">{{ row[k] || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="importPreview.length > 8" class="preview-more">... 还有 {{ importPreview.length - 8 }} 条</div>
      </div>
      <div v-if="importError" class="msg-error">{{ importError }}</div>
      <div v-if="importSuccess" class="msg-success">{{ importSuccess }}</div>
      <div class="form-actions">
        <button class="btn-submit" :disabled="!importPreview.length || importing" @click="doImportVersions">
          {{ importing ? '导入中...' : '确认导入' }}
        </button>
        <button class="btn-cancel" @click="showImport = false">取消</button>
      </div>
    </div>
  </div>
</template>

<script>
import { fetchVersions, createVersion, updateVersion, deleteVersion, checkVersionCode } from '../api'
import { fetchAllSites } from '../api'
import { ElMessageBox, ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'

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
      page: 1,
      pageSize: 10,
      total: 0,
      editRelatedSites: [],
      showImport: false,
      importPreview: [],
      importError: '',
      importSuccess: '',
      importing: false
    }
  },
  computed: {
    importKeys() { return this.importPreview.length ? Object.keys(this.importPreview[0]) : [] },
    totalPages() { return Math.max(1, Math.ceil(this.total / this.pageSize)) },
    pageNumbers() {
      const pages = []; const tp = this.totalPages
      let s = Math.max(1, this.page - 2), e = Math.min(tp, this.page + 2)
      if (e - s < 4) { if (s === 1) e = Math.min(tp, s + 4); else s = Math.max(1, e - 4) }
      for (let i = s; i <= e; i++) pages.push(i)
      return pages
    },
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
        const res = await fetchVersions(this.page, this.pageSize)
        const data = res.data
        this.versions = Array.isArray(data.list) ? data.list : []
        this.total = data.total || 0
      } catch {
        this.versions = []; this.total = 0
      }
    },
    async loadSites() {
      try {
        const res = await fetchAllSites()
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
    goPage(p) { this.page = p; this.loadVersions() },
    onPageSizeChange() { this.page = 1; this.loadVersions() },
    openImport() { this.showImport = true; this.importPreview = []; this.importError = ''; this.importSuccess = '' },
    pickImportFile() { this.$refs.importFileInput.click() },
    handleImportFile(e) { const f = e.target.files[0]; if (f) this.parseImportFile(f); e.target.value = '' },
    parseImportFile(file) {
      this.importError = ''; this.importSuccess = ''; this.importPreview = []
      const reader = new FileReader()
      reader.onload = (ev) => {
        try {
          const wb = XLSX.read(ev.target.result, { type: 'array' })
          const ws = wb.Sheets[wb.SheetNames[0]]
          const json = XLSX.utils.sheet_to_json(ws, { header: 1 })
          if (json.length < 2) { this.importError = '文件内容为空'; return }
          const headers = json[0].map(h => String(h || '').trim())
          const data = json.slice(1).map(row => {
            const obj = {}
            headers.forEach((h, i) => { obj[h] = row[i] !== undefined ? String(row[i] || '').trim() : '' })
            return obj
          }).filter(d => Object.values(d).some(v => v))
          if (data.length === 0) { this.importError = '未解析到有效数据'; return }
          this.importPreview = data
        } catch { this.importError = '文件解析失败' }
      }
      reader.onerror = () => { this.importError = '文件读取失败' }
      reader.readAsArrayBuffer(file)
    },
    async doImportVersions() {
      this.importError = ''; this.importSuccess = ''; this.importing = true
      let count = 0
      const getField = (row, ...keys) => { for (const k of keys) { if (row[k]) return row[k] } return '' }
      const seen = new Set()
      const deduped = this.importPreview.filter(row => {
        const vc = getField(row, '版本号', 'versionCode')
        if (!vc || seen.has(vc)) return false
        seen.add(vc); return true
      })
      for (const row of deduped) {
        try {
          const vc = getField(row, '版本号', 'versionCode')
          if (!vc) continue
          const res = await createVersion({ versionCode: vc, releaseDate: null, sites: '[]', status: 'dev', notes: '' })
          if (res.data && res.data.success) count++
        } catch {}
      }
      if (count > 0) { this.importSuccess = `成功导入 ${count} 条`; this.showImport = false; this.loadVersions() }
      else { this.importError = '导入失败' }
      this.importing = false
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
      try {
        await ElMessageBox.confirm(
          `确定删除版本「${ver.versionCode}」吗？`,
          '删除确认',
          { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
        )
        const res = await deleteVersion(ver.id)
        if (res.data.success) {
          this.loadVersions()
          ElMessage.success('删除成功')
        } else {
          ElMessage.error(res.data.message)
        }
      } catch { /* cancelled */ }
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

.site-tags-cell { max-width: 160px; }
.site-tag {
  display: inline-block; vertical-align: middle;
  padding: 2px 6px;
  margin: 2px 4px 2px 0;
  background: #e6f7ff;
  color: #1890ff;
  border-radius: 3px;
  font-size: 12px;
}
.site-more {
  display: inline-block; vertical-align: middle;
  padding: 2px 6px; margin: 2px 4px 2px 0;
  background: #f0f0f0; color: #999; border: 1px solid #e8e8e8;
  border-radius: 3px; font-size: 12px; cursor: default;
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
  width: 100%; height: 38px;
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px; box-sizing: border-box;
  outline: none;
  font-family: inherit;
}

.form-group textarea { height: auto; }
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

.pagination { display: flex; align-items: center; justify-content: space-between; padding-top: 16px; border-top: 1px solid #f0f0f0; margin-top: 16px; }
.page-left { flex-shrink: 0; }
.page-size-select { padding: 6px 8px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 13px; outline: none; background: #fff; }
.page-center { display: flex; align-items: center; gap: 4px; }
.page-btn { min-width: 36px; height: 32px; padding: 0 10px; border: 1px solid #d9d9d9; background: #fff; color: #555; border-radius: 4px; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; }
.page-btn:hover:not(:disabled) { border-color: #1890ff; color: #1890ff; }
.page-btn.active { background: #1890ff; border-color: #1890ff; color: #fff; }
.page-btn:disabled { color: #d9d9d9; cursor: not-allowed; }
.page-info { font-size: 13px; color: #999; margin-left: 12px; flex-shrink: 0; }
.input-disabled { background: #f5f5f5; color: #999; cursor: not-allowed; }
.hint { font-size: 12px; color: #999; margin-top: 2px; display: block; }
.header-btns { display: flex; gap: 10px; }
.btn-import { padding: 8px 16px; background: #fff; color: #1890ff; border: 1px solid #1890ff; border-radius: 4px; font-size: 13px; cursor: pointer; }
.btn-import:hover { background: #e6f7ff; }
.import-file-input { display: none; }
.import-area { margin-bottom: 16px; cursor: pointer; }
.import-upload { display: block; border: 2px dashed #d9d9d9; border-radius: 8px; padding: 40px 20px; text-align: center; }
.import-upload:hover { border-color: #1890ff; background: #fafbfc; }
.import-icon { font-size: 36px; display: block; margin-bottom: 8px; }
.import-upload p { color: #666; font-size: 14px; margin: 0; }
.import-hint { font-size: 12px !important; color: #bbb !important; margin-top: 4px !important; }
.import-preview { margin-bottom: 16px; }
.import-preview h4 { font-size: 14px; color: #333; margin-bottom: 8px; }
.preview-table-wrap { max-height: 260px; overflow: auto; border: 1px solid #f0f0f0; border-radius: 4px; }
.preview-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.preview-table th { background: #fafafa; padding: 8px 10px; text-align: left; border-bottom: 1px solid #f0f0f0; color: #666; white-space: nowrap; }
.preview-table td { padding: 6px 10px; border-bottom: 1px solid #f5f5f5; color: #333; max-width: 120px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.preview-more { padding: 8px 12px; text-align: center; color: #bbb; font-size: 13px; }
.msg-error { color: #ff4d4f; font-size: 13px; background: #fff1f0; padding: 8px 12px; border-radius: 4px; margin-bottom: 12px; }
.msg-success { color: #52c41a; font-size: 13px; background: #f6ffed; padding: 8px 12px; border-radius: 4px; margin-bottom: 12px; }
</style>
