<template>
  <div>
    <div class="panel-header">
      <h3>局点管理</h3>
      <button class="btn-add" @click="openAdd">&#x2795; 新增局点</button>
    </div>

    <div class="panel">
      <div class="search-bar">
        <input v-model="keyword" placeholder="搜索局点名称或地区..." class="search-input" @input="debounceSearch" />
      </div>

      <table class="table">
        <thead>
          <tr>
            <th>局点编号</th>
            <th>局点名称</th>
            <th>涉及版本</th>
            <th>地区</th>
            <th>联系人</th>
            <th>联系电话</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="site in sites" :key="site.id">
            <td>{{ site.code }}</td>
            <td>{{ site.name }}</td>
            <td>
              <span class="ver-tag" v-for="v in resolveVersionCodes(site.versionIds)" :key="v">{{ v }}</span>
              <span v-if="!site.versionIds" class="no-data">-</span>
            </td>
            <td>{{ site.region }}</td>
            <td>{{ site.contact }}</td>
            <td>{{ site.phone }}</td>
            <td>
              <span :class="site.active ? 'tag-on' : 'tag-off'">
                {{ site.active ? '启用' : '停用' }}
              </span>
            </td>
            <td>
              <button class="btn-action" @click="editSite(site)">编辑</button>
              <button class="btn-action danger" @click="deleteSite(site)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="sites.length === 0" class="empty">暂无局点数据</div>
    </div>

    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑局点' : '新增局点' }}</h3>
        <form @submit.prevent="saveSite">
          <div class="form-group">
            <label>局点编号</label>
            <input v-model="form.code" type="text" placeholder="如 SITE-001" />
          </div>
          <div class="form-group">
            <label>局点名称 <span class="required">*</span></label>
            <input
              v-model="form.name"
              type="text"
              placeholder="请输入局点名称"
              :disabled="editing"
              :class="{ 'input-disabled': editing }"
            />
            <span v-if="editing" class="hint">编辑模式下不可修改局点名称</span>
          </div>
          <div class="form-group">
            <label>涉及版本</label>
            <div class="custom-multi-select" ref="multiSelect">
              <div class="select-box" @click="dropdownOpen = !dropdownOpen">
                <span v-if="form.versionIds.length === 0" class="placeholder">请选择版本</span>
                <span v-for="id in form.versionIds" :key="id" class="sel-tag">
                  {{ getVersionCode(id) }}
                  <span class="tag-close" @click.stop="removeVersion(id)">&times;</span>
                </span>
                <span class="arrow">&#x25BE;</span>
              </div>
              <div class="dropdown-panel" v-show="dropdownOpen">
                <div
                  v-for="ver in allVersions"
                  :key="ver.id"
                  class="dropdown-item"
                  :class="{ selected: form.versionIds.includes(ver.id) }"
                  @click="toggleVersion(ver.id)"
                >
                  <span class="checkmark">{{ form.versionIds.includes(ver.id) ? '&#x2713;' : '' }}</span>
                  {{ ver.versionCode }}
                </div>
                <div v-if="allVersions.length === 0" class="dropdown-empty">暂无版本</div>
              </div>
            </div>
            <span v-if="!editing" class="hint">可选，后续可编辑时添加</span>
          </div>
          <div class="form-group">
            <label>地区</label>
            <select v-model="form.region">
              <option value="">请选择地区</option>
              <option value="北京">北京</option>
              <option value="天津">天津</option>
              <option value="上海">上海</option>
              <option value="重庆">重庆</option>
              <option value="河北">河北</option>
              <option value="山西">山西</option>
              <option value="内蒙古">内蒙古</option>
              <option value="辽宁">辽宁</option>
              <option value="吉林">吉林</option>
              <option value="黑龙江">黑龙江</option>
              <option value="江苏">江苏</option>
              <option value="浙江">浙江</option>
              <option value="安徽">安徽</option>
              <option value="福建">福建</option>
              <option value="江西">江西</option>
              <option value="山东">山东</option>
              <option value="河南">河南</option>
              <option value="湖北">湖北</option>
              <option value="湖南">湖南</option>
              <option value="广东">广东</option>
              <option value="广西">广西</option>
              <option value="海南">海南</option>
              <option value="四川">四川</option>
              <option value="贵州">贵州</option>
              <option value="云南">云南</option>
              <option value="西藏">西藏</option>
              <option value="陕西">陕西</option>
              <option value="甘肃">甘肃</option>
              <option value="青海">青海</option>
              <option value="宁夏">宁夏</option>
              <option value="新疆">新疆</option>
              <option value="香港">香港</option>
              <option value="澳门">澳门</option>
              <option value="台湾">台湾</option>
              <option value="国外">国外</option>
            </select>
          </div>
          <div class="form-group">
            <label>联系人</label>
            <input v-model="form.contact" type="text" placeholder="请输入联系人" />
          </div>
          <div class="form-group">
            <label>联系电话</label>
            <input v-model="form.phone" type="text" placeholder="请输入联系电话" />
          </div>
          <div class="form-group">
            <label>状态</label>
            <select v-model="form.active">
              <option :value="true">启用</option>
              <option :value="false">停用</option>
            </select>
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
import { fetchSites, createSite, updateSite, deleteSite, checkSiteName } from '../api'
import { fetchVersions } from '../api'

export default {
  name: 'SiteManagementView',
  data() {
    return {
      keyword: '',
      showModal: false,
      editing: false,
      editId: null,
      saving: false,
      errorMsg: '',
      form: { code: '', name: '', versionIds: [], region: '', contact: '', phone: '', active: true },
      sites: [],
      allVersions: [],
      searchTimer: null,
      dropdownOpen: false
    }
  },
  mounted() {
    this.loadSites()
    this.loadVersions()
    document.addEventListener('click', this.handleClickOutside)
  },
  beforeUnmount() {
    document.removeEventListener('click', this.handleClickOutside)
  },
  methods: {
    async loadSites() {
      try {
        const res = await fetchSites(this.keyword)
        this.sites = Array.isArray(res.data) ? res.data : []
      } catch {
        this.sites = []
      }
    },
    async loadVersions() {
      try {
        const res = await fetchVersions()
        this.allVersions = Array.isArray(res.data) ? res.data : []
      } catch {
        this.allVersions = []
      }
    },
    getVersionCode(id) {
      const ver = this.allVersions.find(v => v.id === id)
      return ver ? ver.versionCode : String(id)
    },
    toggleVersion(id) {
      const idx = this.form.versionIds.indexOf(id)
      if (idx >= 0) {
        this.form.versionIds.splice(idx, 1)
      } else {
        this.form.versionIds.push(id)
      }
    },
    removeVersion(id) {
      const idx = this.form.versionIds.indexOf(id)
      if (idx >= 0) this.form.versionIds.splice(idx, 1)
    },
    handleClickOutside(e) {
      if (this.$refs.multiSelect && !this.$refs.multiSelect.contains(e.target)) {
        this.dropdownOpen = false
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
    resolveVersionCodes(raw) {
      const ids = this.parseIds(raw)
      return ids.map(id => {
        const ver = this.allVersions.find(v => v.id === Number(id) || v.id === id)
        return ver ? ver.versionCode : null
      }).filter(Boolean)
    },
    debounceSearch() {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => this.loadSites(), 300)
    },
    openAdd() {
      this.editing = false
      this.editId = null
      this.errorMsg = ''
      this.form = { code: '', name: '', versionIds: [], region: '', contact: '', phone: '', active: true }
      this.showModal = true
    },
    editSite(site) {
      this.editing = true
      this.editId = site.id
      this.errorMsg = ''
      this.form = {
        code: site.code,
        name: site.name,
        versionIds: this.parseIds(site.versionIds),
        region: site.region,
        contact: site.contact,
        phone: site.phone,
        active: site.active
      }
      this.showModal = true
    },
    async saveSite() {
      this.errorMsg = ''
      if (!this.form.name || !this.form.code) {
        this.errorMsg = '请填写必填项'
        return
      }
      this.saving = true
      try {
        const versionIds = JSON.stringify(this.form.versionIds.length > 0 ? this.form.versionIds : [])
        if (this.editing) {
          const payload = {
            code: this.form.code,
            region: this.form.region,
            contact: this.form.contact,
            phone: this.form.phone,
            active: this.form.active,
            versionIds: versionIds
          }
          const res = await updateSite(this.editId, payload)
          if (res.data.success) {
            this.showModal = false
            this.loadSites()
          } else {
            this.errorMsg = res.data.message
          }
        } else {
          const checkRes = await checkSiteName(this.form.name)
          if (checkRes.data && checkRes.data.exists) {
            this.errorMsg = '局点名称已存在，请更换'
            this.saving = false
            return
          }
          const res = await createSite({ ...this.form, versionIds: versionIds })
          if (res.data.success) {
            this.showModal = false
            this.loadSites()
          } else {
            this.errorMsg = res.data.message
          }
        }
      } catch {
        this.errorMsg = '网络错误，请稍后重试'
      } finally {
        this.saving = false
      }
    },
    async deleteSite(site) {
      if (!confirm(`确定删除局点「${site.name}」吗？`)) return
      try {
        const res = await deleteSite(site.id)
        if (res.data.success) {
          this.loadSites()
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

.search-bar { margin-bottom: 16px; }

.search-input {
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 13px;
  width: 280px;
  outline: none;
}

.search-input:focus { border-color: #1890ff; }

.table { width: 100%; border-collapse: collapse; }

.table th, .table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }

.tag-on { color: #52c41a; font-weight: 500; }
.tag-off { color: #d9d9d9; }

.ver-tag {
  display: inline-block;
  padding: 2px 6px;
  margin: 2px 4px 2px 0;
  background: #fff7e6;
  color: #fa8c16;
  border: 1px solid #ffd591;
  border-radius: 3px;
  font-size: 12px;
}

.no-data { color: #ccc; }

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

.form-group input, .form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
}

.form-group input:focus, .form-group select:focus { border-color: #1890ff; }

.input-disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.custom-multi-select {
  position: relative;
}

.select-box {
  min-height: 38px;
  padding: 4px 28px 4px 8px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
  position: relative;
  background: #fff;
}

.select-box:focus,
.select-box:focus-within {
  border-color: #1890ff;
}

.placeholder {
  color: #bfbfbf;
}

.arrow {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 12px;
  color: #999;
  pointer-events: none;
}

.sel-tag {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 1px 6px;
  background: #e6f7ff;
  color: #1890ff;
  border: 1px solid #91d5ff;
  border-radius: 3px;
  font-size: 12px;
}

.tag-close {
  cursor: pointer;
  color: #999;
  font-size: 14px;
  line-height: 1;
  margin-left: 2px;
}

.tag-close:hover {
  color: #ff4d4f;
}

.dropdown-panel {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  max-height: 200px;
  overflow-y: auto;
  background: #fff;
  border: 1px solid #d9d9d9;
  border-top: none;
  border-radius: 0 0 4px 4px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 10;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  font-size: 14px;
  color: #333;
  cursor: pointer;
}

.dropdown-item:hover {
  background: #f5f5f5;
}

.dropdown-item.selected {
  color: #1890ff;
  font-weight: 500;
}

.checkmark {
  width: 16px;
  font-size: 14px;
  color: #1890ff;
  text-align: center;
}

.dropdown-empty {
  padding: 12px;
  text-align: center;
  color: #999;
  font-size: 13px;
}

.hint {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
  display: block;
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
