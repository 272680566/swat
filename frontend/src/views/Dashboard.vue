<template>
  <div>
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-number">128</div>
        <div class="stat-label">问题总数</div>
      </div>
      <div class="stat-card green">
        <div class="stat-number">86</div>
        <div class="stat-label">已解决</div>
      </div>
      <div class="stat-card orange">
        <div class="stat-number">23</div>
        <div class="stat-label">处理中</div>
      </div>
      <div class="stat-card red">
        <div class="stat-number">19</div>
        <div class="stat-label">待处理</div>
      </div>
    </div>

    <div class="panel">
      <h3 class="panel-title">最近提交的问题</h3>
      <table class="table">
        <thead>
          <tr>
            <th>编号</th><th>标题</th><th>优先级</th><th>状态</th><th>提交时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in recentIssues" :key="item.id">
            <td>{{ item.id }}</td>
            <td>{{ item.title }}</td>
            <td><span :class="'tag tag-' + item.priority">{{ item.priority }}</span></td>
            <td><span :class="'tag tag-' + item.status">{{ item.status }}</span></td>
            <td>{{ item.time }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DashboardView',
  data() {
    return {
      recentIssues: [
        { id: 'SWAT-0128', title: '登录页面样式错乱', priority: '高', status: '处理中', time: '2026-05-18' },
        { id: 'SWAT-0127', title: '数据库连接池耗尽', priority: '紧急', status: '已解决', time: '2026-05-17' },
        { id: 'SWAT-0126', title: '导出报表格式错误', priority: '中', status: '待处理', time: '2026-05-16' },
        { id: 'SWAT-0125', title: '用户权限校验失效', priority: '高', status: '已解决', time: '2026-05-15' },
        { id: 'SWAT-0124', title: '首页加载速度慢', priority: '中', status: '已解决', time: '2026-05-14' }
      ]
    }
  }
}
</script>

<style scoped>
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  border-left: 4px solid #1890ff;
}

.stat-card.green { border-left-color: #52c41a; }
.stat-card.orange { border-left-color: #fa8c16; }
.stat-card.red { border-left-color: #ff4d4f; }

.stat-number {
  font-size: 32px;
  font-weight: 600;
  color: #333;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 4px;
}

.panel {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.panel-title {
  font-size: 16px;
  color: #333;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.table {
  width: 100%;
  border-collapse: collapse;
}

.table th,
.table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.table th {
  background: #fafafa;
  color: #666;
  font-weight: 500;
  font-size: 13px;
}

.table td {
  font-size: 14px;
  color: #333;
}

.tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 12px;
}

.tag-高 { color: #ff4d4f; background: #fff1f0; border: 1px solid #ffa39e; }
.tag-中 { color: #fa8c16; background: #fff7e6; border: 1px solid #ffd591; }
.tag-低 { color: #52c41a; background: #f6ffed; border: 1px solid #b7eb8f; }
.tag-紧急 { color: #fff; background: #ff4d4f; border: 1px solid #ff4d4f; }
.tag-已解决 { color: #52c41a; background: #f6ffed; border: 1px solid #b7eb8f; }
.tag-处理中 { color: #1890ff; background: #e6f7ff; border: 1px solid #91d5ff; }
.tag-待处理 { color: #fa8c16; background: #fff7e6; border: 1px solid #ffd591; }
</style>
