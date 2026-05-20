<template>
  <div class="panel">
    <h3 class="panel-title">创建问题</h3>

    <form @submit.prevent="submit" class="issue-form">
      <div class="form-group">
        <label>问题标题 <span class="required">*</span></label>
        <input v-model="form.title" type="text" placeholder="请输入问题标题" />
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>优先级</label>
          <select v-model="form.priority">
            <option value="低">低</option>
            <option value="中" selected>中</option>
            <option value="高">高</option>
            <option value="紧急">紧急</option>
          </select>
        </div>
        <div class="form-group">
          <label>负责人</label>
          <select v-model="form.assignee">
            <option value="">请选择</option>
            <option value="张三">张三</option>
            <option value="李四">李四</option>
            <option value="王五">王五</option>
            <option value="赵六">赵六</option>
          </select>
        </div>
      </div>

      <div class="form-group">
        <label>问题描述 <span class="required">*</span></label>
        <textarea v-model="form.description" placeholder="请详细描述问题..." rows="6"></textarea>
      </div>

      <div v-if="msg" :class="msg.type">{{ msg.text }}</div>

      <div class="form-actions">
        <button type="submit" class="btn-submit" :disabled="submitting">
          {{ submitting ? '提交中...' : '提交问题' }}
        </button>
        <button type="button" class="btn-reset" @click="reset">重置</button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'CreateIssueView',
  data() {
    return {
      form: { title: '', priority: '中', assignee: '', description: '' },
      submitting: false,
      msg: null
    }
  },
  methods: {
    submit() {
      if (!this.form.title || !this.form.description) {
        this.msg = { type: 'error', text: '请填写必填项' }
        return
      }
      this.submitting = true
      setTimeout(() => {
        this.submitting = false
        this.msg = { type: 'success', text: '问题提交成功！' }
        this.form = { title: '', priority: '中', assignee: '', description: '' }
      }, 800)
    },
    reset() {
      this.form = { title: '', priority: '中', assignee: '', description: '' }
      this.msg = null
    }
  }
}
</script>

<style scoped>
.panel {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  max-width: 720px;
}

.panel-title {
  font-size: 16px;
  color: #333;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.issue-form .form-group {
  margin-bottom: 18px;
}

.issue-form label {
  display: block;
  margin-bottom: 6px;
  font-size: 14px;
  color: #555;
}

.required { color: #ff4d4f; }

.issue-form input,
.issue-form select,
.issue-form textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  font-family: inherit;
}

.issue-form input:focus,
.issue-form select:focus,
.issue-form textarea:focus {
  border-color: #1890ff;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-actions {
  display: flex;
  gap: 12px;
  padding-top: 8px;
}

.btn-submit {
  padding: 10px 28px;
  background: #1890ff;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
}

.btn-submit:hover { opacity: 0.85; }
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-reset {
  padding: 10px 28px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #666;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
}

.btn-reset:hover { border-color: #1890ff; color: #1890ff; }

.success { color: #52c41a; background: #f6ffed; padding: 10px; border-radius: 4px; margin-bottom: 12px; font-size: 14px; }
.error { color: #ff4d4f; background: #fff1f0; padding: 10px; border-radius: 4px; margin-bottom: 12px; font-size: 14px; }
</style>
