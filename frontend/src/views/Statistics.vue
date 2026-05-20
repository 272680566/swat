<template>
  <div>
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-value">65%</div>
        <div class="stat-label">解决率</div>
        <div class="stat-bar"><div class="stat-fill green" style="width:65%"></div></div>
      </div>
      <div class="stat-card">
        <div class="stat-value">2.3天</div>
        <div class="stat-label">平均处理时间</div>
        <div class="stat-bar"><div class="stat-fill blue" style="width:46%"></div></div>
      </div>
    </div>

    <div class="panel">
      <h3 class="panel-title">问题分类统计</h3>
      <table class="table">
        <thead>
          <tr><th>分类</th><th>数量</th><th>占比</th></tr>
        </thead>
        <tbody>
          <tr v-for="item in categories" :key="item.name">
            <td>{{ item.name }}</td>
            <td>{{ item.count }}</td>
            <td>
              <div class="percent-bar">
                <div class="percent-fill" :style="{width: item.percent + '%'}"></div>
                <span>{{ item.percent }}%</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="panel" style="margin-top:20px">
      <h3 class="panel-title">月度趋势</h3>
      <div class="chart-placeholder">
        <div class="bar-chart">
          <div v-for="m in monthlyData" :key="m.month" class="bar-col">
            <div class="bar" :style="{height: (m.count / 2.5) + 'px'}">
              <span class="bar-value">{{ m.count }}</span>
            </div>
            <span class="bar-label">{{ m.month }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StatisticsView',
  data() {
    return {
      categories: [
        { name: '功能缺陷', count: 52, percent: 41 },
        { name: '性能问题', count: 28, percent: 22 },
        { name: '安全漏洞', count: 18, percent: 14 },
        { name: '体验优化', count: 20, percent: 15 },
        { name: '其他', count: 10, percent: 8 }
      ],
      monthlyData: [
        { month: '1月', count: 18 },
        { month: '2月', count: 22 },
        { month: '3月', count: 30 },
        { month: '4月', count: 25 },
        { month: '5月', count: 33 }
      ]
    }
  }
}
</script>

<style scoped>
.stats-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #333;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin: 4px 0 12px;
}

.stat-bar {
  height: 6px;
  background: #f0f0f0;
  border-radius: 3px;
}

.stat-fill {
  height: 100%;
  border-radius: 3px;
}

.stat-fill.green { background: #52c41a; }
.stat-fill.blue { background: #1890ff; }

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

.table th, .table td {
  text-align: left;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }

.percent-bar {
  display: flex;
  align-items: center;
  gap: 8px;
}

.percent-fill {
  height: 8px;
  background: #1890ff;
  border-radius: 4px;
}

.percent-bar span {
  font-size: 12px;
  color: #666;
  white-space: nowrap;
}

.chart-placeholder {
  padding: 20px 0;
}

.bar-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  height: 250px;
  padding: 0 20px;
}

.bar-col {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.bar {
  width: 48px;
  background: linear-gradient(180deg, #69c0ff, #1890ff);
  border-radius: 4px 4px 0 0;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  transition: height 0.3s;
  position: relative;
}

.bar-value {
  position: absolute;
  top: -22px;
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.bar-label {
  margin-top: 8px;
  font-size: 13px;
  color: #666;
}
</style>
