<template>
  <div class="detail-page" v-if="issue">
    <div class="detail-header">
      <button class="btn-back" @click="$router.push('/home/issues')"><span class="back-arrow">&#x2190;</span>返回列表</button>
      <h2>{{ issue.issueNo }}</h2>
      <span class="status-tag" :class="'s-' + issue.status">{{ issue.status || '待处理' }}</span>
    </div>

    <div class="detail-body">
      <!-- Left Tabs -->
      <nav class="tab-nav">
        <div
          v-for="tab in tabs" :key="tab.key"
          class="tab-item" :class="{ active: activeTab === tab.key }"
          @click="activeTab = tab.key"
        >
          <span class="tab-num">{{ tab.key }}</span>
          <span class="tab-label">{{ tab.label }}</span>
        </div>
      </nav>

      <!-- Right Content -->
      <div class="tab-content">

        <!-- 1. 基础信息 -->
        <div v-show="activeTab === 1">
          <div class="section-header">
            <h3 class="content-title">基础信息</h3>
            <button v-if="!editingBasic" class="btn-edit" @click="editingBasic = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="saveBasic">保存</button>
              <button class="btn-cancel-sm" @click="cancelBasic">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item"><label>日期</label><span>{{ issue.handleDate || '-' }}</span></div>
            <div class="info-item"><label>客户名称</label><span>{{ issue.customerName || '-' }}</span></div>
            <div class="info-item">
              <label>重点局点</label>
              <span v-if="!editingBasic" class="tag-pill" :class="formBasic.keySite ? 'level-p1' : ''">{{ formBasic.keySite ? '是' : '否' }}</span>
              <select v-else v-model="formBasic.keySite" class="field-select">
                <option :value="false">否</option>
                <option :value="true">是</option>
              </select>
            </div>
            <div class="info-item">
              <label>局点类型</label>
              <span v-if="!editingBasic">{{ formBasic.siteType || '金融' }}</span>
              <select v-else v-model="formBasic.siteType" class="field-select">
                <option value="金融">金融</option>
                <option value="非金融">非金融</option>
              </select>
            </div>
            <div class="info-item full">
              <label>问题分类</label>
              <span v-if="!editingBasic">{{ formBasic.category || '未分类' }}</span>
              <div v-else class="cascade-selects">
                <select v-model="formBasic.catL1" class="field-select" @change="onCatL1Change">
                  <option value="">一级分类</option>
                  <option v-for="l1 in allCategories" :key="l1.id" :value="l1.id + ':' + l1.name">{{ l1.name }}</option>
                </select>
                <select v-model="formBasic.catL2" class="field-select" :disabled="!catL2Options.length" @change="onCatL2Change">
                  <option value="">二级分类</option>
                  <option v-for="l2 in catL2Options" :key="l2.id" :value="l2.id + ':' + l2.name">{{ l2.name }}</option>
                </select>
                <select v-model="formBasic.catL3" class="field-select" :disabled="!catL3Options.length">
                  <option value="">三级分类</option>
                  <option v-for="l3 in catL3Options" :key="l3.id" :value="l3.id + ':' + l3.name">{{ l3.name }}</option>
                </select>
              </div>
            </div>
            <div class="info-item">
              <label>管控部署形态</label>
              <span v-if="!editingBasic" :class="{ muted: !formBasic.mgmtDeploy }">{{ formBasic.mgmtDeploy || '待补充' }}</span>
              <select v-else v-model="formBasic.mgmtDeploy" class="field-select">
                <option value="">请选择</option>
                <option value="TPOPS">TPOPS</option>
                <option value="HCS">HCS</option>
                <option value="公有云">公有云</option>
                <option value="HCSO">HCSO</option>
              </select>
            </div>
            <div class="info-item">
              <label>内核版本</label>
              <span v-if="!editingBasic">{{ issue.kernelVersion || '-' }}</span>
              <select v-else v-model="formBasic.kernelVersion" class="field-select">
                <option value="">请选择版本</option>
                <option v-for="v in allVersions" :key="v.id" :value="v.versionCode">{{ v.versionCode }}</option>
              </select>
            </div>
            <div class="info-item">
              <label>内核部署形态</label>
              <span v-if="!editingBasic" :class="{ muted: !formBasic.kernelDeploy }">{{ formBasic.kernelDeploy || '待补充' }}</span>
              <select v-else v-model="formBasic.kernelDeploy" class="field-select">
                <option value="">请选择</option>
                <option value="集中式">集中式</option>
                <option value="分布式">分布式</option>
                <option value="单节点">单节点</option>
                <option value="主备">主备</option>
              </select>
            </div>
            <div class="info-item">
              <label>RL</label>
              <span v-if="!editingBasic" :class="{ muted: !formBasic.rl }">{{ formBasic.rl || '待补充' }}</span>
              <select v-else v-model="formBasic.rl" class="field-select">
                <option value="">请选择RL</option>
                <option v-for="r in allRls" :key="r.id" :value="r.name">{{ r.name }}</option>
              </select>
            </div>
            <div class="info-item full"><label>问题简述</label><span>{{ issue.description || '-' }}</span></div>
            <div class="info-item">
              <label>运维系统单号</label>
              <span v-if="!editingBasic" :class="{ muted: !formBasic.opsTicket }">{{ formBasic.opsTicket || '待补充' }}</span>
              <input v-else v-model="formBasic.opsTicket" type="text" class="field-input" placeholder="请输入" />
            </div>
            <div class="info-item">
              <label>ecare单号</label>
              <span v-if="!editingBasic" :class="{ muted: !formBasic.ecareTicket }">{{ formBasic.ecareTicket || '待补充' }}</span>
              <input v-else v-model="formBasic.ecareTicket" type="text" class="field-input" placeholder="请输入" />
            </div>
          </div>
        </div>

        <!-- 2. 快速属性 -->
        <div v-show="activeTab === 2">
          <div class="section-header">
            <h3 class="content-title">快速属性</h3>
            <button v-if="!editingQuick" class="btn-edit" @click="editingQuick = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="saveQuick">保存</button>
              <button class="btn-cancel-sm" @click="cancelQuick">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <label>业务中断</label>
              <span v-if="!editingQuick" class="tag-pill" :class="formQuick.bizInterrupt ? 'level-p1' : ''">{{ formQuick.bizInterrupt ? '是' : '否' }}</span>
              <select v-else v-model="formQuick.bizInterrupt" class="field-select">
                <option :value="false">否</option>
                <option :value="true">是</option>
              </select>
            </div>
            <div class="info-item">
              <label>紧急恢复</label>
              <span v-if="!editingQuick" class="tag-pill" :class="formQuick.urgentRecover ? 'level-p1' : ''">{{ formQuick.urgentRecover ? '是' : '否' }}</span>
              <select v-else v-model="formQuick.urgentRecover" class="field-select">
                <option :value="false">否</option>
                <option :value="true">是</option>
              </select>
            </div>
            <div class="info-item full">
              <label>备注</label>
              <span v-if="!editingQuick" :class="{ muted: !formQuick.remark }">{{ formQuick.remark || '待补充' }}</span>
              <textarea v-else v-model="formQuick.remark" class="field-textarea" rows="3" placeholder="请输入备注"></textarea>
            </div>
          </div>
        </div>

        <!-- 3. 发现问题 -->
        <div v-show="activeTab === 3">
          <div class="section-header">
            <h3 class="content-title">发现问题</h3>
            <button v-if="!editingFind" class="btn-edit" @click="editingFind = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="saveFind">保存</button>
              <button class="btn-cancel-sm" @click="cancelFind">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <label>有无告警</label>
              <span v-if="!editingFind" class="tag-pill" :class="formFind.hasAlarm ? 'level-p1' : ''">{{ formFind.hasAlarm ? '有' : '无' }}</span>
              <select v-else v-model="formFind.hasAlarm" class="field-select">
                <option :value="false">无</option>
                <option :value="true">有</option>
              </select>
            </div>
            <div class="info-item">
              <label>告警触发</label>
              <span v-if="!editingFind" class="tag-pill" :class="formFind.alarmTrigger ? 'level-p1' : ''">{{ formFind.alarmTrigger ? '是' : '否' }}</span>
              <select v-else v-model="formFind.alarmTrigger" class="field-select">
                <option :value="false">否</option>
                <option :value="true">是</option>
              </select>
            </div>
            <div class="info-item full">
              <label>备注</label>
              <span v-if="!editingFind" :class="{ muted: !formFind.remark }">{{ formFind.remark || '待补充' }}</span>
              <textarea v-else v-model="formFind.remark" class="field-textarea" rows="3" placeholder="请输入备注"></textarea>
            </div>
          </div>
        </div>

        <!-- 4. 关键时间 -->
        <div v-show="activeTab === 4">
          <div class="section-header">
            <h3 class="content-title">关键时间</h3>
            <button v-if="!editingTime" class="btn-edit" @click="editingTime = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="saveTime">保存</button>
              <button class="btn-cancel-sm" @click="cancelTime">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <label>问题发生时间</label>
              <span v-if="!editingTime">{{ formTime.occurTime || '-' }}</span>
              <input v-else v-model="formTime.occurTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>一线感知时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.perceiveTime }">{{ formTime.perceiveTime || '待补充' }}</span>
              <input v-else v-model="formTime.perceiveTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>问题建单时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.createTime }">{{ formTime.createTime || '待补充' }}</span>
              <input v-else v-model="formTime.createTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>SWAT开始处理时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.swatStartTime }">{{ formTime.swatStartTime || '待补充' }}</span>
              <input v-else v-model="formTime.swatStartTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>问题定界时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.boundTime }">{{ formTime.boundTime || '待补充' }}</span>
              <input v-else v-model="formTime.boundTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>业务恢复时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.bizRecoverTime }">{{ formTime.bizRecoverTime || '待补充' }}</span>
              <input v-else v-model="formTime.bizRecoverTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item">
              <label>完全恢复时间</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.fullRecoverTime }">{{ formTime.fullRecoverTime || '待补充' }}</span>
              <input v-else v-model="formTime.fullRecoverTime" type="datetime-local" class="field-input" />
            </div>
            <div class="info-item full">
              <label>备注</label>
              <span v-if="!editingTime" :class="{ muted: !formTime.remark }">{{ formTime.remark || '待补充' }}</span>
              <textarea v-else v-model="formTime.remark" class="field-textarea" rows="2" placeholder="请输入备注"></textarea>
            </div>
          </div>

          <!-- Summary -->
          <div class="time-summary">
            <h4 class="summary-title">&#x1F4CA; 耗时总结（分钟）</h4>
            <div class="summary-grid">
              <div class="summary-item"><label>拉SWAT时间</label><span>{{ calcMin(formTime.createTime, formTime.swatStartTime) }}</span><small>问题建单 → SWAT开始处理</small></div>
              <div class="summary-item"><label>问题发现耗时</label><span>{{ calcMin(formTime.occurTime, formTime.perceiveTime) }}</span><small>问题发生 → 一线感知</small></div>
              <div class="summary-item"><label>一线建单耗时</label><span>{{ calcMin(formTime.perceiveTime, formTime.createTime) }}</span><small>一线感知 → 问题建单</small></div>
              <div class="summary-item"><label>启动WARROOM耗时</label><span>{{ calcMin(formTime.createTime, formTime.swatStartTime) }}</span><small>问题建单 → SWAT开始处理</small></div>
              <div class="summary-item"><label>SWAT定界耗时</label><span>{{ calcMin(formTime.swatStartTime, formTime.boundTime) }}</span><small>SWAT开始处理 → 问题定界</small></div>
              <div class="summary-item"><label>SWAT介入恢复耗时</label><span>{{ calcMin(formTime.swatStartTime, formTime.bizRecoverTime) }}</span><small>SWAT开始处理 → 业务恢复</small></div>
              <div class="summary-item full"><label>端到端恢复耗时</label><span class="total">{{ calcMin(formTime.occurTime, formTime.bizRecoverTime) }}</span><small>问题发生 → 业务恢复</small></div>
            </div>
          </div>
        </div>

        <!-- 5. 问题归档 -->
        <div v-show="activeTab === 5">
          <div class="section-header">
            <h3 class="content-title">问题归档</h3>
            <button v-if="!editingArchive" class="btn-edit" @click="editingArchive = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="saveArchive">保存</button>
              <button class="btn-cancel-sm" @click="cancelArchive">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item full">
              <label>文档链接</label>
              <span v-if="!editingArchive" :class="{ muted: !formArchive.docLink }">{{ formArchive.docLink || '待补充' }}</span>
              <input v-else v-model="formArchive.docLink" type="text" class="field-input" placeholder="请输入文档链接" />
            </div>
            <div class="info-item full">
              <label>录屏链接</label>
              <span v-if="!editingArchive" :class="{ muted: !formArchive.screenLink }">{{ formArchive.screenLink || '待补充' }}</span>
              <input v-else v-model="formArchive.screenLink" type="text" class="field-input" placeholder="请输入录屏链接" />
            </div>
          </div>
        </div>

        <!-- 6. 应急预案 -->
        <div v-show="activeTab === 6">
          <div class="section-header">
            <h3 class="content-title">应急预案</h3>
            <button v-if="!editingPlan" class="btn-edit" @click="editingPlan = true">&#x270E; 编辑</button>
            <div v-else class="btn-group">
              <button class="btn-save" @click="savePlan">保存</button>
              <button class="btn-cancel-sm" @click="cancelPlan">取消</button>
            </div>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <label>处理时是否有应急预案</label>
              <span v-if="!editingPlan" class="tag-pill" :class="formPlan.hadPlan ? '' : 'level-p1'">{{ formPlan.hadPlan ? '有' : '无' }}</span>
              <select v-else v-model="formPlan.hadPlan" class="field-select">
                <option :value="true">有</option>
                <option :value="false">无</option>
              </select>
            </div>
            <div class="info-item">
              <label>当前是否有应急预案</label>
              <span v-if="!editingPlan" class="tag-pill" :class="formPlan.hasPlan ? '' : 'level-p1'">{{ formPlan.hasPlan ? '有' : '无' }}</span>
              <select v-else v-model="formPlan.hasPlan" class="field-select">
                <option :value="true">有</option>
                <option :value="false">无</option>
              </select>
            </div>
            <div class="info-item full">
              <label>应急预案名称 <span v-if="editingPlan && formPlan.hasPlan" class="required">*</span></label>
              <span v-if="!editingPlan" :class="{ muted: !formPlan.planName }">{{ formPlan.planName || '待补充' }}</span>
              <input v-else v-model="formPlan.planName" type="text" class="field-input" placeholder="请输入应急预案名称" />
            </div>
          </div>
        </div>


      </div>
    </div>
  </div>
  <div v-else class="loading">加载中...</div>
</template>

<script>
import { fetchIssue, fetchAllVersions, fetchCategoryTree, updateIssue, fetchRls } from '../api'
import { ElMessage } from 'element-plus'

export default {
  name: 'IssueDetailView',
  data() {
    return {
      issue: null,
      activeTab: 1,
      editingBasic: false,
      editingQuick: false,
      editingFind: false,
      editingTime: false,
      editingArchive: false,
      editingPlan: false,
      allVersions: [],
      allCategories: [],
      allRls: [],
      categoryOptions: [],
      formBasic: { handleDate: '', keySite: false, siteType: '金融', mgmtDeploy: '', kernelVersion: '', kernelDeploy: '', rl: '', opsTicket: '', ecareTicket: '', category: '', catL1: '', catL2: '', catL3: '' },
      formQuick: { bizInterrupt: false, urgentRecover: false, remark: '' },
      formFind: { hasAlarm: false, alarmTrigger: false, remark: '' },
      formTime: { occurTime: '', perceiveTime: '', createTime: '', swatStartTime: '', boundTime: '', bizRecoverTime: '', fullRecoverTime: '', remark: '' },
      formArchive: { docLink: '', screenLink: '' },
      formPlan: { hadPlan: false, hasPlan: false, planName: '' },
      tabs: [
        { key: 1, label: '基础信息' },
        { key: 2, label: '快速属性' },
        { key: 3, label: '发现问题' },
        { key: 4, label: '关键时间' },
        { key: 5, label: '问题归档' },
        { key: 6, label: '应急预案' }
      ]
    }
  },
  async mounted() {
    const id = this.$route.params.id
    try {
      const res = await fetchIssue(id)
      this.issue = res.data
    } catch { this.issue = { issueNo: '加载失败' } }
    this.initForm()
    this.loadVersions()
    this.loadCategories()
    this.loadRls()
  },
  computed: {
    catL2Options() {
      if (!this.formBasic.catL1) return []
      const l1Id = parseInt(this.formBasic.catL1.split(':')[0])
      const l1 = this.allCategories.find(c => c.id === l1Id)
      return l1 ? (l1.children || []) : []
    },
    catL3Options() {
      if (!this.formBasic.catL2) return []
      const l2Id = parseInt(this.formBasic.catL2.split(':')[0])
      for (const l1 of this.allCategories) {
        if (l1.children) {
          const l2 = l1.children.find(c => c.id === l2Id)
          if (l2) return l2.children || []
        }
      }
      return []
    }
  },
  methods: {
    async loadRls() {
      try {
        const res = await fetchRls()
        this.allRls = Array.isArray(res.data) ? res.data : []
      } catch { this.allRls = [] }
    },
    async loadVersions() {
      try {
        const res = await fetchAllVersions()
        this.allVersions = Array.isArray(res.data) ? res.data : []
      } catch { this.allVersions = [] }
    },
    async loadCategories() {
      try {
        const res = await fetchCategoryTree()
        this.allCategories = Array.isArray(res.data) ? res.data : []
        this.buildCategoryOptions()
      } catch { this.allCategories = [] }
    },
    buildCategoryOptions() {
      const opts = []
      const walk = (nodes, prefix) => {
        nodes.forEach(n => {
          const label = prefix ? prefix + ' > ' + n.name : n.name
          opts.push({ value: label, label })
          if (n.children && n.children.length) walk(n.children, label)
        })
      }
      walk(this.allCategories, '')
      this.categoryOptions = opts
    },
    onCatL1Change() {
      this.formBasic.catL2 = ''
      this.formBasic.catL3 = ''
    },
    onCatL2Change() {
      this.formBasic.catL3 = ''
    },
    parseCategoryToCascade() {
      const cat = this.formBasic.category
      if (!cat) return
      const parts = cat.split(' > ')
      const findId = (nodes, name, level) => {
        for (const n of nodes) {
          if (n.name === name) return n.id + ':' + n.name
        }
        return ''
      }
      if (parts[0]) this.formBasic.catL1 = findId(this.allCategories, parts[0]) || ''
      if (parts[1]) {
        const l1 = this.allCategories.find(c => c.name === parts[0])
        if (l1) this.formBasic.catL2 = findId(l1.children || [], parts[1]) || ''
      }
      if (parts[2]) {
        for (const l1 of this.allCategories) {
          if (l1.name === parts[0] && l1.children) {
            const l2 = l1.children.find(c => c.name === parts[1])
            if (l2) this.formBasic.catL3 = findId(l2.children || [], parts[2]) || ''
          }
        }
      }
    },
    buildCategoryFromCascade() {
      const parts = []
      if (this.formBasic.catL1) parts.push(this.formBasic.catL1.split(':')[1])
      if (this.formBasic.catL2) parts.push(this.formBasic.catL2.split(':')[1])
      if (this.formBasic.catL3) parts.push(this.formBasic.catL3.split(':')[1])
      return parts.join(' > ')
    },
    initForm() {
      if (!this.issue) return
      this.formBasic = {
        handleDate: this.issue.handleDate || '',
        keySite: this.issue.keySite || false,
        siteType: this.issue.siteType || '金融',
        mgmtDeploy: this.issue.mgmtDeploy || '',
        kernelVersion: this.issue.kernelVersion || '',
        kernelDeploy: this.issue.kernelDeploy || '',
        rl: this.issue.rl || '',
        opsTicket: this.issue.opsTicket || '',
        ecareTicket: this.issue.ecareTicket || '',
        category: this.issue.category || '',
        catL1: '', catL2: '', catL3: ''
      }
      this.parseCategoryToCascade()
      this.formQuick = {
        bizInterrupt: this.issue.bizInterrupt || false,
        urgentRecover: this.issue.urgentRecover || false,
        remark: this.issue.remark || ''
      }
      this.formFind = {
        hasAlarm: this.issue.hasAlarm || false,
        alarmTrigger: this.issue.alarmTrigger || false,
        remark: this.issue.findRemark || ''
      }
      this.formTime = {
        occurTime: this.issue.occurTime || '',
        perceiveTime: this.issue.perceiveTime || '',
        createTime: this.issue.createTime || '',
        swatStartTime: this.issue.swatStartTime || '',
        boundTime: this.issue.boundTime || '',
        bizRecoverTime: this.issue.bizRecoverTime || '',
        fullRecoverTime: this.issue.fullRecoverTime || '',
        remark: this.issue.timeRemark || ''
      }
      this.formArchive = {
        docLink: this.issue.docLink || '',
        screenLink: this.issue.screenLink || ''
      }
      this.formPlan = {
        hadPlan: this.issue.hadPlan !== undefined ? this.issue.hadPlan : false,
        hasPlan: this.issue.hasPlan !== undefined ? this.issue.hasPlan : false,
        planName: this.issue.planName || ''
      }
    },
    async saveBasic() {
      this.issue.keySite = this.formBasic.keySite
      this.issue.siteType = this.formBasic.siteType
      this.issue.mgmtDeploy = this.formBasic.mgmtDeploy
      this.issue.kernelVersion = this.formBasic.kernelVersion
      this.issue.kernelDeploy = this.formBasic.kernelDeploy
      this.issue.rl = this.formBasic.rl
      this.issue.opsTicket = this.formBasic.opsTicket
      this.issue.ecareTicket = this.formBasic.ecareTicket
      this.issue.category = this.buildCategoryFromCascade()
      this.formBasic.category = this.issue.category
      await updateIssue(this.issue.id, {
        handleDate: this.issue.handleDate,
        keySite: this.issue.keySite, siteType: this.issue.siteType,
        mgmtDeploy: this.issue.mgmtDeploy, kernelVersion: this.issue.kernelVersion,
        kernelDeploy: this.issue.kernelDeploy, rl: this.issue.rl,
        opsTicket: this.issue.opsTicket, ecareTicket: this.issue.ecareTicket,
        category: this.issue.category
      })
      this.editingBasic = false
    },
    cancelBasic() {
      this.initForm()
      this.editingBasic = false
    },
    async saveQuick() {
      this.issue.bizInterrupt = this.formQuick.bizInterrupt
      this.issue.urgentRecover = this.formQuick.urgentRecover
      this.issue.remark = this.formQuick.remark
      await updateIssue(this.issue.id, {
        bizInterrupt: this.issue.bizInterrupt,
        urgentRecover: this.issue.urgentRecover,
        remark: this.issue.remark
      })
      this.editingQuick = false
    },
    cancelQuick() {
      if (!this.issue) return
      this.formQuick = {
        bizInterrupt: this.issue.bizInterrupt || false,
        urgentRecover: this.issue.urgentRecover || false,
        remark: this.issue.remark || ''
      }
      this.editingQuick = false
    },
    async saveFind() {
      this.issue.hasAlarm = this.formFind.hasAlarm
      this.issue.alarmTrigger = this.formFind.alarmTrigger
      this.issue.findRemark = this.formFind.remark
      await updateIssue(this.issue.id, {
        hasAlarm: this.issue.hasAlarm,
        alarmTrigger: this.issue.alarmTrigger,
        findRemark: this.issue.findRemark
      })
      this.editingFind = false
    },
    cancelFind() {
      if (!this.issue) return
      this.formFind = {
        hasAlarm: this.issue.hasAlarm || false,
        alarmTrigger: this.issue.alarmTrigger || false,
        remark: this.issue.findRemark || ''
      }
      this.formTime = {
        occurTime: this.issue.occurTime || '',
        perceiveTime: this.issue.perceiveTime || '',
        createTime: this.issue.createTime || '',
        swatStartTime: this.issue.swatStartTime || '',
        boundTime: this.issue.boundTime || '',
        bizRecoverTime: this.issue.bizRecoverTime || '',
        fullRecoverTime: this.issue.fullRecoverTime || '',
        remark: this.issue.timeRemark || ''
      }
      this.formArchive = {
        docLink: this.issue.docLink || '',
        screenLink: this.issue.screenLink || ''
      }
      this.formPlan = {
        hadPlan: this.issue.hadPlan !== undefined ? this.issue.hadPlan : false,
        hasPlan: this.issue.hasPlan !== undefined ? this.issue.hasPlan : false,
        planName: this.issue.planName || ''
      }
      this.editingFind = false
    },
    calcMin(from, to) {
      if (!from || !to) return '-'
      const diff = new Date(to) - new Date(from)
      if (isNaN(diff) || diff < 0) return '-'
      return Math.round(diff / 60000) + ' min'
    },
    async saveTime() {
      this.issue.occurTime = this.formTime.occurTime
      this.issue.perceiveTime = this.formTime.perceiveTime
      this.issue.createTime = this.formTime.createTime
      this.issue.swatStartTime = this.formTime.swatStartTime
      this.issue.boundTime = this.formTime.boundTime
      this.issue.bizRecoverTime = this.formTime.bizRecoverTime
      this.issue.fullRecoverTime = this.formTime.fullRecoverTime
      this.issue.timeRemark = this.formTime.remark
      await updateIssue(this.issue.id, {
        occurTime: this.issue.occurTime,
        perceiveTime: this.issue.perceiveTime,
        createTime: this.issue.createTime,
        swatStartTime: this.issue.swatStartTime,
        boundTime: this.issue.boundTime,
        bizRecoverTime: this.issue.bizRecoverTime,
        fullRecoverTime: this.issue.fullRecoverTime,
        timeRemark: this.issue.timeRemark
      })
      this.editingTime = false
    },
    async saveArchive() {
      this.issue.docLink = this.formArchive.docLink
      this.issue.screenLink = this.formArchive.screenLink
      await updateIssue(this.issue.id, {
        docLink: this.issue.docLink,
        screenLink: this.issue.screenLink
      })
      this.editingArchive = false
    },
    cancelArchive() {
      if (!this.issue) return
      this.formArchive = {
        docLink: this.issue.docLink || '',
        screenLink: this.issue.screenLink || ''
      }
      this.formPlan = {
        hadPlan: this.issue.hadPlan !== undefined ? this.issue.hadPlan : false,
        hasPlan: this.issue.hasPlan !== undefined ? this.issue.hasPlan : false,
        planName: this.issue.planName || ''
      }
      this.editingArchive = false
    },
    async savePlan() {
      if (this.formPlan.hasPlan && !this.formPlan.planName.trim()) {
        ElMessage.warning('请输出已有应急预案名称')
        return
      }
      this.issue.hadPlan = this.formPlan.hadPlan
      this.issue.hasPlan = this.formPlan.hasPlan
      this.issue.planName = this.formPlan.planName
      await updateIssue(this.issue.id, {
        hadPlan: this.issue.hadPlan,
        hasPlan: this.issue.hasPlan,
        planName: this.issue.planName
      })
      this.editingPlan = false
    },
    cancelPlan() {
      if (!this.issue) return
      this.formPlan = {
        hadPlan: this.issue.hadPlan !== undefined ? this.issue.hadPlan : false,
        hasPlan: this.issue.hasPlan !== undefined ? this.issue.hasPlan : false,
        planName: this.issue.planName || ''
      }
      this.editingPlan = false
    },
    cancelTime() {
      if (!this.issue) return
      this.formTime = {
        occurTime: this.issue.occurTime || '',
        perceiveTime: this.issue.perceiveTime || '',
        createTime: this.issue.createTime || '',
        swatStartTime: this.issue.swatStartTime || '',
        boundTime: this.issue.boundTime || '',
        bizRecoverTime: this.issue.bizRecoverTime || '',
        fullRecoverTime: this.issue.fullRecoverTime || '',
        remark: this.issue.timeRemark || ''
      }
      this.formArchive = {
        docLink: this.issue.docLink || '',
        screenLink: this.issue.screenLink || ''
      }
      this.formPlan = {
        hadPlan: this.issue.hadPlan !== undefined ? this.issue.hadPlan : false,
        hasPlan: this.issue.hasPlan !== undefined ? this.issue.hasPlan : false,
        planName: this.issue.planName || ''
      }
      this.editingTime = false
    }
  }
}
</script>

<style scoped>
.detail-page { max-width: 100%; margin: -12px 0 0; }
.detail-header { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
.btn-back { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border: 1px solid #d9d9d9; background: #fff; color: #555; border-radius: 4px; font-size: 13px; cursor: pointer; line-height: 1; }
.btn-back:hover { border-color: #1890ff; color: #1890ff; }
.back-arrow { display: inline-block; font-size: 14px; line-height: 1; }
.detail-header h2 { font-size: 20px; color: #333; flex: 1; }
.status-tag { padding: 4px 12px; border-radius: 4px; font-size: 13px; }
.s-待处理 { background: #fff7e6; color: #fa8c16; }
.s-处理中 { background: #e6f7ff; color: #1890ff; }
.s-已解决 { background: #f6ffed; color: #52c41a; }
.s-已关闭 { background: #f5f5f5; color: #999; }

.detail-body { display: flex; gap: 0; min-height: calc(100vh - 180px); }

/* ---- Left Tabs ---- */
.tab-nav {
  width: 170px; flex-shrink: 0;
  background: #fff; border-radius: 8px 0 0 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  padding: 4px 0; display: flex; flex-direction: column;
}
.tab-item {
  display: flex; align-items: center; gap: 10px;
  padding: 14px 16px; cursor: pointer;
  font-size: 14px; color: #666;
  border-left: 3px solid transparent;
  transition: all 0.15s;
}
.tab-item:hover { background: #f5f7fa; color: #333; }
.tab-item.active {
  background: #e6f7ff; color: #1890ff; font-weight: 600;
  border-left-color: #1890ff;
}
.tab-num {
  width: 22px; height: 22px; line-height: 22px; text-align: center;
  border-radius: 50%; font-size: 12px; font-weight: 600;
  background: #f0f0f0; color: #999; flex-shrink: 0;
}
.tab-item.active .tab-num { background: #1890ff; color: #fff; }
.tab-label { white-space: nowrap; }

/* ---- Right Content ---- */
.tab-content {
  flex: 1; background: #fff; border-radius: 0 8px 8px 0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06); padding: 24px 28px;
}

.section-header { display: flex; align-items: center; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #f0f0f0; }
.content-title { font-size: 17px; font-weight: 600; color: #333; }
.content-title { margin-bottom: 0; padding-bottom: 0; border-bottom: none; }

.btn-edit {
  margin-left: auto; padding: 4px 14px; border: 1px solid #1890ff;
  background: #fff; color: #1890ff; border-radius: 4px;
  font-size: 13px; cursor: pointer;
}
.btn-edit:hover { background: #1890ff; color: #fff; }

.btn-group { margin-left: auto; display: flex; gap: 8px; }
.btn-save {
  padding: 4px 14px; border: none; background: #1890ff; color: #fff;
  border-radius: 4px; font-size: 13px; cursor: pointer;
}
.btn-save:hover { opacity: 0.85; }
.btn-cancel-sm {
  padding: 4px 14px; border: 1px solid #d9d9d9; background: #fff;
  color: #666; border-radius: 4px; font-size: 13px; cursor: pointer;
}
.btn-cancel-sm:hover { border-color: #1890ff; color: #1890ff; }

.field-input, .field-select, .field-textarea {
  width: 100%; padding: 4px 8px; border: 1px solid #d9d9d9;
  border-radius: 4px; font-size: 14px; outline: none; box-sizing: border-box;
  font-family: inherit; resize: vertical;
}
.field-input:focus, .field-select:focus, .field-textarea:focus { border-color: #1890ff; }
.field-select { background: #fff; }

.cascade-selects { display: flex; gap: 8px; }
.cascade-selects .field-select { flex: 1; min-width: 0; }
.cascade-selects .field-select:disabled { background: #f5f5f5; color: #ccc; }

.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.info-grid.col3 { grid-template-columns: 1fr 1fr 1fr; }

.info-item label { display: block; font-size: 12px; color: #999; margin-bottom: 4px; }
.info-item span { font-size: 14px; color: #333; }
.info-item.full { grid-column: 1 / -1; margin-bottom: 12px; }
.info-item .muted { color: #bbb; font-style: italic; }

.tag-pill { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 12px; background: #f0f5ff; color: #597ef7; }
.tag-pill.level-p1 { background: #fff1f0; color: #cf1322; font-weight: 600; }

.timeline { }
.tl-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f5f5f5; }
.tl-item:last-child { border-bottom: none; }
.tl-dot { width: 10px; height: 10px; border-radius: 50%; background: #1890ff; flex-shrink: 0; }
.tl-dot.gray { background: #d9d9d9; }
.tl-label { width: 80px; font-size: 13px; color: #666; flex-shrink: 0; }
.tl-value { font-size: 14px; color: #333; }
.tl-value.muted { color: #bbb; }

/* ---- Time Summary ---- */
.time-summary { margin-top: 24px; background: #fafbfc; border-radius: 8px; padding: 20px; border: 1px solid #f0f0f0; }
.summary-title { font-size: 15px; font-weight: 600; color: #333; margin-bottom: 16px; }
.summary-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.summary-item label { display: block; font-size: 12px; color: #999; margin-bottom: 2px; }
.summary-item span { font-size: 18px; font-weight: 600; color: #1890ff; }
.summary-item span.total { color: #cf1322; font-size: 20px; }
.summary-item small { display: block; font-size: 11px; color: #bbb; margin-top: 2px; }
.summary-item.full { grid-column: 1 / -1; }

.loading { text-align: center; padding: 80px; color: #999; font-size: 15px; }

.info-block { }
</style>
