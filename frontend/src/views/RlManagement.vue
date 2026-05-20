<template>
  <div>
    <div class="panel-header">
      <h3>RL管理</h3>
      <button class="btn-add" @click="openAdd">&#x2795; 新增RL</button>
    </div>
    <div class="panel">
      <table class="table">
        <thead><tr><th>序号</th><th>RL名称</th><th>创建时间</th><th>操作</th></tr></thead>
        <tbody>
          <tr v-for="(item, idx) in rls" :key="item.id">
            <td>{{ idx + 1 }}</td><td>{{ item.name }}</td>
            <td>{{ (item.createdAt || '').substring(0, 10) }}</td>
            <td>
              <button class="btn-action" @click="editRl(item)">编辑</button>
              <button class="btn-action danger" @click="delRl(item)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="rls.length === 0" class="empty">暂无RL</div>
    </div>

    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑RL' : '新增RL' }}</h3>
        <form @submit.prevent="save">
          <div class="form-group">
            <label>RL名称 <span class="required">*</span></label>
            <input v-model="form.name" type="text" placeholder="请输入RL名称" />
          </div>
          <div v-if="errorMsg" class="msg-error">{{ errorMsg }}</div>
          <div class="form-actions">
            <button type="submit" class="btn-submit" :disabled="saving">{{ saving ? '保存中...' : '保存' }}</button>
            <button type="button" class="btn-cancel" @click="showModal = false">取消</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { fetchRls, createRl, updateRl, deleteRl } from '../api'
export default {
  name: 'RlManagementView',
  data() { return { rls: [], showModal: false, editing: false, editId: null, saving: false, errorMsg: '', form: { name: '' } } },
  mounted() { this.load() },
  methods: {
    async load() { try { const r = await fetchRls(); this.rls = Array.isArray(r.data) ? r.data : [] } catch { this.rls = [] } },
    openAdd() { this.editing = false; this.editId = null; this.errorMsg = ''; this.form = { name: '' }; this.showModal = true },
    editRl(item) { this.editing = true; this.editId = item.id; this.errorMsg = ''; this.form = { name: item.name }; this.showModal = true },
    async save() {
      if (!this.form.name.trim()) { this.errorMsg = 'RL名称不能为空'; return }
      this.saving = true
      try {
        const res = this.editing ? await updateRl(this.editId, this.form) : await createRl(this.form)
        if (res.data.success) { this.showModal = false; this.load() } else { this.errorMsg = res.data.message }
      } catch { this.errorMsg = '网络错误' } finally { this.saving = false }
    },
    async delRl(item) {
      if (!confirm(`确定删除RL「${item.name}」吗？`)) return
      try { const r = await deleteRl(item.id); if (r.data.success) this.load(); else alert(r.data.message) } catch { alert('删除失败') }
    }
  }
}
</script>

<style scoped>
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.panel-header h3 { font-size: 16px; color: #333; }
.btn-add { padding: 8px 16px; background: #1890ff; color: #fff; border: none; border-radius: 4px; font-size: 13px; cursor: pointer; }
.panel { background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #f0f0f0; }
.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }
.btn-action { padding: 4px 10px; border: 1px solid #d9d9d9; background: #fff; color: #1890ff; border-radius: 4px; font-size: 12px; cursor: pointer; margin-right: 6px; }
.btn-action.danger { color: #ff4d4f; }
.empty { text-align: center; padding: 48px; color: #999; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: flex-start; justify-content: center; padding: 8vh 20px 20px; z-index: 100; }
.modal { background: #fff; border-radius: 8px; padding: 24px; width: 420px; box-shadow: 0 6px 30px rgba(0,0,0,0.2); }
.modal h3 { margin-bottom: 16px; font-size: 16px; }
.form-group { margin-bottom: 14px; }
.form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 4px; }
.required { color: #ff4d4f; }
.form-group input { width: 100%; padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 14px; outline: none; }
.form-group input:focus { border-color: #1890ff; }
.msg-error { color: #ff4d4f; font-size: 13px; background: #fff1f0; padding: 8px 12px; border-radius: 4px; margin-bottom: 12px; }
.form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }
.btn-submit { padding: 8px 20px; background: #1890ff; color: #fff; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-cancel { padding: 8px 20px; border: 1px solid #d9d9d9; background: #fff; color: #666; border-radius: 4px; cursor: pointer; font-size: 14px; }
</style>
