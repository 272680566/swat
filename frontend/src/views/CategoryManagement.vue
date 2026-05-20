<template>
  <div>
    <div class="panel-header">
      <h3>分类管理</h3>
      <div class="header-actions">
        <button class="btn-add" @click="openAdd(null)">&#x2795; 新增一级分类</button>
      </div>
    </div>

    <div class="panel">
      <div class="cat-tree" v-if="tree.length > 0">
        <div v-for="l1 in tree" :key="l1.id" class="tree-l1">
          <div class="tree-row l1" @click="toggleExpand(l1.id)">
            <span class="tree-arrow">
              <template v-if="l1.children && l1.children.length">
                {{ expanded.has(l1.id) ? '&#x25BE;' : '&#x25B8;' }}
              </template>
            </span>
            <span class="tree-level-badge l1">一级</span>
            <span class="tree-color" :style="{background: colorMap[l1.color] || '#1890ff'}"></span>
            <span class="tree-name">{{ l1.name }}</span>
            <span class="tree-actions" @click.stop>
              <button class="btn-sm" @click="openAdd(l1.id, 2)">+二级</button>
              <button class="btn-sm" @click="editCat(l1)">编辑</button>
              <button class="btn-sm danger" @click="deleteCat(l1)">删除</button>
            </span>
          </div>

          <div v-show="expanded.has(l1.id)" class="tree-children">
            <div v-for="l2 in l1.children" :key="l2.id" class="tree-l2-wrap">
              <div class="tree-row l2" @click="toggleExpand(l2.id)">
                <span class="tree-arrow">
                  <template v-if="l2.children && l2.children.length">
                    {{ expanded.has(l2.id) ? '&#x25BE;' : '&#x25B8;' }}
                  </template>
                </span>
                <span class="tree-level-badge l2">二级</span>
                <span class="tree-color" :style="{background: colorMap[l2.color] || '#5b8def'}"></span>
                <span class="tree-name">{{ l2.name }}</span>
                <span class="tree-actions" @click.stop>
                  <button class="btn-sm" @click="openAdd(l2.id, 3)">+三级</button>
                  <button class="btn-sm" @click="editCat(l2)">编辑</button>
                  <button class="btn-sm danger" @click="deleteCat(l2)">删除</button>
                </span>
              </div>

              <div v-show="expanded.has(l2.id)" class="tree-children">
                <div v-for="l3 in l2.children" :key="l3.id" class="tree-l3-wrap">
                  <div class="tree-row l3">
                    <span class="tree-arrow"></span>
                    <span class="tree-level-badge l3">三级</span>
                    <span class="tree-color" :style="{background: colorMap[l3.color] || '#8cb8f0'}"></span>
                    <span class="tree-name">{{ l3.name }}</span>
                    <span class="tree-actions">
                      <button class="btn-sm" @click="editCat(l3)">编辑</button>
                      <button class="btn-sm danger" @click="deleteCat(l3)">删除</button>
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="empty">暂无分类，请先创建一级分类</div>
    </div>

    <!-- Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑分类' : '新增分类' }}</h3>
        <form @submit.prevent="saveCat">
          <div class="form-group" v-if="!editing && formParentId">
            <label>所属上级</label>
            <input :value="parentLabel" type="text" disabled class="input-disabled" />
          </div>
          <div class="form-group">
            <label>分类名称 <span class="required">*</span></label>
            <input v-model="form.name" type="text" placeholder="请输入分类名称" />
          </div>
          <div class="form-group">
            <label>主题颜色</label>
            <select v-model="form.color">
              <option value="blue">蓝色</option>
              <option value="orange">橙色</option>
              <option value="red">红色</option>
              <option value="purple">紫色</option>
              <option value="green">绿色</option>
            </select>
          </div>
          <div class="form-group">
            <label>排序</label>
            <input v-model.number="form.sortOrder" type="number" placeholder="数字越小越靠前" />
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
import { fetchCategoryTree, createCategory, updateCategory, deleteCategory } from '../api'

export default {
  name: 'CategoryManagementView',
  data() {
    return {
      tree: [],
      showModal: false,
      editing: false,
      editId: null,
      formParentId: null,
      formLevel: 1,
      saving: false,
      errorMsg: '',
      form: { name: '', color: 'blue', sortOrder: 0 },
      colorMap: { blue: '#1890ff', orange: '#fa8c16', red: '#ff4d4f', purple: '#722ed1', green: '#52c41a' },
      expanded: new Set()
    }
  },
  computed: {
    parentLabel() {
      const find = (nodes, id) => {
        for (const n of nodes) {
          if (n.id === id) return n.name
          if (n.children) {
            const r = find(n.children, id)
            if (r) return r
          }
        }
        return null
      }
      return find(this.tree, this.formParentId) || ''
    }
  },
  mounted() { this.loadTree() },
  methods: {
    toggleExpand(id) {
      if (this.expanded.has(id)) this.expanded.delete(id)
      else this.expanded.add(id)
    },
    expandAll(nodes) {
      nodes.forEach(n => {
        if (n.children && n.children.length) {
          this.expanded.add(n.id)
          this.expandAll(n.children)
        }
      })
    },
    async loadTree() {
      const saved = new Set(this.expanded)
      try {
        const res = await fetchCategoryTree()
        this.tree = Array.isArray(res.data) ? res.data : []
        if (saved.size === 0) {
          this.expandAll(this.tree)
        } else {
          this.expanded = saved
        }
      } catch { this.tree = [] }
    },
    openAdd(parentId, level) {
      this.editing = false
      this.editId = null
      this.formParentId = parentId || null
      this.formLevel = level || 1
      this.errorMsg = ''
      this.form = { name: '', color: 'blue', sortOrder: 0 }
      this.showModal = true
    },
    editCat(cat) {
      this.editing = true
      this.editId = cat.id
      this.formParentId = cat.parentId
      this.errorMsg = ''
      this.form = { name: cat.name, color: cat.color || 'blue', sortOrder: cat.sortOrder || 0 }
      this.showModal = true
    },
    async saveCat() {
      this.errorMsg = ''
      if (!this.form.name.trim()) {
        this.errorMsg = '分类名称不能为空'
        return
      }
      this.saving = true
      try {
        let res
        if (this.editing) {
          res = await updateCategory(this.editId, this.form)
        } else {
          const payload = {
            name: this.form.name.trim(),
            parentId: this.formParentId || null,
            color: this.form.color,
            sortOrder: this.form.sortOrder
          }
          res = await createCategory(payload)
        }
        if (res.data.success) {
          this.showModal = false
          this.loadTree()
        } else {
          this.errorMsg = res.data.message
        }
      } catch {
        this.errorMsg = '网络错误'
      } finally { this.saving = false }
    },
    async deleteCat(cat) {
      if (!confirm(`确定删除分类「${cat.name}」吗？` + (cat.children?.length ? '\n其下所有子分类将被级联删除' : ''))) return
      try {
        const res = await deleteCategory(cat.id)
        if (res.data.success) {
          this.loadTree()
        } else {
          alert(res.data.message)
        }
      } catch { alert('删除失败') }
    }
  }
}
</script>

<style scoped>
.panel-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
}
.panel-header h3 { font-size: 16px; color: #333; }
.btn-add { padding: 8px 16px; background: #1890ff; color: #fff; border: none; border-radius: 4px; font-size: 13px; cursor: pointer; }
.btn-add:hover { opacity: 0.85; }
.panel { background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }

.cat-tree { }

.tree-l1 { margin-bottom: 8px; }
.tree-l1, .tree-l2-wrap, .tree-l3-wrap, .tree-children {
  width: 100%; margin: 0; padding: 0;
}

.tree-arrow { width: 16px; font-size: 10px; color: #bbb; flex-shrink: 0; text-align: center; cursor: pointer; }
.tree-arrow.empty { visibility: hidden; }

.tree-row {
  display: flex; align-items: center; gap: 8px;
  height: 42px; width: 100%; box-sizing: border-box;
  padding: 0 12px;
  border-radius: 4px; line-height: 1;
}
.tree-row.l1 { background: #f0f5ff; padding-left: 12px; }
.tree-row.l2 { background: #fafbfc; padding-left: 52px; }
.tree-row.l3 { background: #fff;      padding-left: 92px; }
.tree-row.l1, .tree-row.l2, .tree-row.l3 { margin-bottom: 2px; }
.tree-row:last-child { margin-bottom: 0; }

.tree-level-badge {
  padding: 1px 8px; border-radius: 3px; font-size: 11px; color: #fff; flex-shrink: 0;
}
.tree-level-badge.l1 { background: #1890ff; }
.tree-level-badge.l2 { background: #5b8def; }
.tree-level-badge.l3 { background: #8cb8f0; }

.tree-color { width: 12px; height: 12px; border-radius: 50%; flex-shrink: 0; }
.tree-name { flex: 1; font-size: 14px; color: #333; }
.tree-actions { display: flex; gap: 4px; }

.btn-sm {
  padding: 2px 8px; border: 1px solid #d9d9d9; background: #fff;
  color: #555; border-radius: 3px; font-size: 12px; cursor: pointer;
}
.btn-sm:hover { border-color: #1890ff; color: #1890ff; }
.btn-sm.danger { color: #ff4d4f; }
.btn-sm.danger:hover { border-color: #ff4d4f; }

.empty { text-align: center; padding: 48px; color: #999; font-size: 14px; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: flex-start; justify-content: center; padding: 8vh 20px 20px; overflow-y: auto; z-index: 100; }
.modal { background: #fff; border-radius: 8px; padding: 24px; width: 440px; max-height: 90vh; overflow-y: auto; box-shadow: 0 6px 30px rgba(0,0,0,0.2); }
.modal h3 { margin-bottom: 16px; font-size: 16px; }
.form-group { margin-bottom: 14px; }
.form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 4px; }
.required { color: #ff4d4f; }
.form-group input, .form-group select { width: 100%; padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 14px; outline: none; }
.form-group input:focus, .form-group select:focus { border-color: #1890ff; }
.input-disabled { background: #f5f5f5; color: #999; }
.msg-error { color: #ff4d4f; font-size: 13px; background: #fff1f0; padding: 8px 12px; border-radius: 4px; margin-bottom: 12px; }
.form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }
.btn-submit { padding: 8px 20px; background: #1890ff; color: #fff; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-cancel { padding: 8px 20px; border: 1px solid #d9d9d9; background: #fff; color: #666; border-radius: 4px; cursor: pointer; font-size: 14px; }
</style>
