<template>
  <div class="issues-layout">
    <!-- Left Category Sidebar -->
    <aside class="category-sidebar">
      <div class="category-header">
        <span class="category-title">&#x1F4C2; 问题分类</span>
        <button v-if="hasSelection" class="btn-clear" @click="clearAll">重置</button>
      </div>

      <div class="category-tree">
        <div v-if="categories.length === 0" class="cat-empty">
          <div class="cat-empty-icon">&#x1F4C2;</div>
          <p>暂无分类</p>
          <router-link to="/home/categories" class="cat-empty-link">前往分类管理</router-link>
        </div>
        <div v-for="l1 in categories" :key="l1.key" class="cat-l1-group" :class="{ expanded: l1.open }">
          <!-- Level 1 -->
          <div class="cat-l1" :class="l1.color" @click="l1.open = !l1.open">
            <span class="cat-icon">{{ l1.open ? '&#x25BE;' : '&#x25B8;' }}</span>
            <div class="cat-check"
              :class="{ checked: isL1Checked(l1), partial: isL1Partial(l1) }"
              @click.stop="toggleL1(l1)">
              <span v-if="isL1Checked(l1)" class="check-icon">&#x2713;</span>
              <span v-else-if="isL1Partial(l1)" class="partial-bar"></span>
            </div>
            <span class="cat-name">{{ l1.name }}</span>
            <span class="cat-count">{{ countIssuesByL1(l1) }}</span>
          </div>

          <!-- Level 2 -->
          <div v-show="l1.open" class="cat-l2-list">
            <div v-for="l2 in l1.children" :key="l2.key" class="cat-l2-group" :class="{ expanded: l2.open }">
              <div class="cat-l2" @click="l2.open = !l2.open">
                <span class="cat-icon">{{ l2.open ? '&#x25BE;' : '&#x25B8;' }}</span>
                <div class="cat-check sm"
                  :class="{ checked: isL2Checked(l1, l2), partial: isL2Partial(l1, l2) }"
                  @click.stop="toggleL2(l1, l2)">
                  <span v-if="isL2Checked(l1, l2)" class="check-icon">&#x2713;</span>
                  <span v-else-if="isL2Partial(l1, l2)" class="partial-bar"></span>
                </div>
                <span class="cat-name">{{ l2.name }}</span>
                <span class="cat-count">{{ countIssuesByL2(l1, l2) }}</span>
              </div>

              <!-- Level 3 -->
              <div v-show="l2.open" class="cat-l3-list">
                <div v-for="l3 in l2.children" :key="l3.key" class="cat-l3">
                  <div class="cat-check xs"
                    :class="{ checked: selected.l3.includes(l3.key) }"
                    @click="toggleL3(l1, l2, l3)">
                    <span v-if="selected.l3.includes(l3.key)" class="check-icon">&#x2713;</span>
                  </div>
                  <span class="cat-name">{{ l3.name }}</span>
                  <span class="cat-count dim">{{ countIssuesByL3(l3) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="category-footer">
        <span v-if="!hasSelection" class="footer-hint">选择分类以筛选问题</span>
        <span v-else class="footer-selected">已选 <em>{{ selectedCount }}</em> 项分类</span>
      </div>
    </aside>

    <!-- Right Content -->
    <div class="issue-content">
      <div class="panel-header">
        <h3>问题列表</h3>
        <div class="header-btns">
          <button class="btn-urgent" :class="{ active: filterUrgentRecover === '是' }" @click="toggleUrgentFilter">
            &#x1F6A8; 紧急恢复问题{{ filterUrgentRecover === '是' ? ' (已筛选)' : '' }}
          </button>
          <button class="btn-import" @click="openImport">&#x1F4C1; 批量导入</button>
          <button class="btn-add" @click="openAdd">&#x2795; 新增问题</button>
        </div>
      </div>

      <div class="panel">
        <div class="search-bar">
          <div class="gear-btn-wrap">
            <button class="gear-btn" @click.stop="showColumnPicker = !showColumnPicker">&#x2699;</button>
            <div v-if="showColumnPicker" class="column-picker" @click.stop>
            <div class="picker-scroll">
              <div v-for="col in columnDefs" :key="col.key" class="picker-item" @click="toggleColumn(col.key)">
                <span class="picker-check">{{ colVisible(col.key) ? '&#x2713;' : '' }}</span>
                {{ col.label }}
              </div>
            </div>
            <div class="picker-footer">
              <div class="picker-divider"></div>
              <div class="picker-item picker-reset" @click="resetColumns">&#x21BA; 重置为默认</div>
            </div>
            </div>
          </div>
        </div>

        <div class="table-wrapper">
        <table class="table" ref="resizeTable">
          <thead>
            <tr>
              <th v-if="colVisible('issueNo')" class="resizable" :style="colWidth('issueNo')">问题编号<div class="resize-handle" data-col="issueNo" @mousedown.stop="startResize($event, 'issueNo')"></div></th>
              <th class="sticky-left resizable" :style="stickyStyle('occurTime', 0)">
                <div class="th-filter">
                  <span>日期</span>
                  <span class="filter-icon" :class="{ active: filterDateStart || filterDateEnd }" @click.stop="openDatePicker($event)">
                    <svg viewBox="0 0 24 24" width="12" height="12" fill="currentColor"><path d="M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z"/></svg>
                  </span>
                </div>
                <div class="resize-handle" data-col="occurTime" @mousedown.stop="startResize($event, 'occurTime')"></div>
              </th>
              <th class="sticky-left resizable" :style="stickyStyle('customerName', 120)">
                <div class="th-filter">
                  <span>客户名称</span>
                  <span class="filter-icon" :class="{ active: filterCustomerName.length }" @click.stop="openCustomerPicker($event)">
                    <svg viewBox="0 0 24 24" width="12" height="12" fill="currentColor"><path d="M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z"/></svg>
                  </span>
                </div>
                <div class="resize-handle" data-col="customerName" @mousedown.stop="startResize($event, 'customerName')"></div>
              </th>
              <th class="sticky-left resizable" :style="stickyStyle('description', 260)">问题简述<div class="resize-handle" data-col="description" @mousedown.stop="startResize($event, 'description')"></div></th>
              <th v-if="colVisible('category')" class="resizable" :style="colWidth('category')">问题分类<div class="resize-handle" data-col="category" @mousedown.stop="startResize($event, 'category')"></div></th>
              <th v-if="colVisible('kernelVersion')" class="resizable" :style="colWidth('kernelVersion')">
                <div class="th-filter">
                  <span>内核版本</span>
                  <span class="filter-icon" :class="{ active: filterKernelVersions.length }" @click.stop="openVersionPicker($event)">
                    <svg viewBox="0 0 24 24" width="12" height="12" fill="currentColor"><path d="M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z"/></svg>
                  </span>
                </div>
                <div class="resize-handle" data-col="kernelVersion" @mousedown.stop="startResize($event, 'kernelVersion')"></div>
              </th>
              <th v-if="colVisible('status')" class="resizable" :style="colWidth('status')">状态<div class="resize-handle" data-col="status" @mousedown.stop="startResize($event, 'status')"></div></th>
              <th v-if="colVisible('keySite')" class="resizable" :style="colWidth('keySite')">重点局点<div class="resize-handle" data-col="keySite" @mousedown.stop="startResize($event, 'keySite')"></div></th>
              <th v-if="colVisible('siteType')" class="resizable" :style="colWidth('siteType')">局点类型<div class="resize-handle" data-col="siteType" @mousedown.stop="startResize($event, 'siteType')"></div></th>
              <th v-if="colVisible('mgmtDeploy')" class="resizable" :style="colWidth('mgmtDeploy')">管控部署形态<div class="resize-handle" data-col="mgmtDeploy" @mousedown.stop="startResize($event, 'mgmtDeploy')"></div></th>
              <th v-if="colVisible('rl')" class="resizable" :style="colWidth('rl')">RL<div class="resize-handle" data-col="rl" @mousedown.stop="startResize($event, 'rl')"></div></th>
              <th v-if="colVisible('opsTicket')" class="resizable" :style="colWidth('opsTicket')">运维系统单号<div class="resize-handle" data-col="opsTicket" @mousedown.stop="startResize($event, 'opsTicket')"></div></th>
              <th v-if="colVisible('ecareTicket')" class="resizable" :style="colWidth('ecareTicket')">ecare单号<div class="resize-handle" data-col="ecareTicket" @mousedown.stop="startResize($event, 'ecareTicket')"></div></th>
              <th v-if="colVisible('kernelDeploy')" class="resizable" :style="colWidth('kernelDeploy')">内核部署形态<div class="resize-handle" data-col="kernelDeploy" @mousedown.stop="startResize($event, 'kernelDeploy')"></div></th>
              <th v-if="colVisible('bizInterrupt')" class="resizable" :style="colWidth('bizInterrupt')">业务中断<div class="resize-handle" data-col="bizInterrupt" @mousedown.stop="startResize($event, 'bizInterrupt')"></div></th>
              <th v-if="colVisible('urgentRecover')" class="resizable" :style="colWidth('urgentRecover')">
                <div class="th-filter">
                  <span>紧急恢复</span>
                  <span class="filter-icon" :class="{ active: filterUrgentRecover !== '' }" @click.stop="openUrgentFilter($event)">
                    <svg viewBox="0 0 24 24" width="12" height="12" fill="currentColor"><path d="M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z"/></svg>
                  </span>
                </div>
                <div class="resize-handle" data-col="urgentRecover" @mousedown.stop="startResize($event, 'urgentRecover')"></div>
              </th>
              <th v-if="colVisible('hasAlarm')" class="resizable" :style="colWidth('hasAlarm')">有无告警<div class="resize-handle" data-col="hasAlarm" @mousedown.stop="startResize($event, 'hasAlarm')"></div></th>
              <th v-if="colVisible('alarmTrigger')" class="resizable" :style="colWidth('alarmTrigger')">告警触发<div class="resize-handle" data-col="alarmTrigger" @mousedown.stop="startResize($event, 'alarmTrigger')"></div></th>
              <th v-if="colVisible('occurTimeFull')" class="resizable" :style="colWidth('occurTimeFull')">问题发生时间<div class="resize-handle" data-col="occurTimeFull" @mousedown.stop="startResize($event, 'occurTimeFull')"></div></th>
              <th v-if="colVisible('perceiveTime')" class="resizable" :style="colWidth('perceiveTime')">一线感知时间<div class="resize-handle" data-col="perceiveTime" @mousedown.stop="startResize($event, 'perceiveTime')"></div></th>
              <th v-if="colVisible('createTime')" class="resizable" :style="colWidth('createTime')">问题建单时间<div class="resize-handle" data-col="createTime" @mousedown.stop="startResize($event, 'createTime')"></div></th>
              <th v-if="colVisible('swatStartTime')" class="resizable" :style="colWidth('swatStartTime')">SWAT开始处理时间<div class="resize-handle" data-col="swatStartTime" @mousedown.stop="startResize($event, 'swatStartTime')"></div></th>
              <th v-if="colVisible('boundTime')" class="resizable" :style="colWidth('boundTime')">问题定界时间<div class="resize-handle" data-col="boundTime" @mousedown.stop="startResize($event, 'boundTime')"></div></th>
              <th v-if="colVisible('bizRecoverTime')" class="resizable" :style="colWidth('bizRecoverTime')">业务恢复时间<div class="resize-handle" data-col="bizRecoverTime" @mousedown.stop="startResize($event, 'bizRecoverTime')"></div></th>
              <th v-if="colVisible('swatPullTime')" class="resizable" :style="colWidth('swatPullTime')">拉SWAT时间<div class="resize-handle" data-col="swatPullTime" @mousedown.stop="startResize($event, 'swatPullTime')"></div></th>
              <th v-if="colVisible('discoverDuration')" class="resizable" :style="colWidth('discoverDuration')">问题发现耗时<div class="resize-handle" data-col="discoverDuration" @mousedown.stop="startResize($event, 'discoverDuration')"></div></th>
              <th v-if="colVisible('createOrderDuration')" class="resizable" :style="colWidth('createOrderDuration')">一线建单耗时<div class="resize-handle" data-col="createOrderDuration" @mousedown.stop="startResize($event, 'createOrderDuration')"></div></th>
              <th v-if="colVisible('warroomDuration')" class="resizable" :style="colWidth('warroomDuration')">启动WARROOM耗时<div class="resize-handle" data-col="warroomDuration" @mousedown.stop="startResize($event, 'warroomDuration')"></div></th>
              <th v-if="colVisible('swatBoundDuration')" class="resizable" :style="colWidth('swatBoundDuration')">SWAT定界耗时<div class="resize-handle" data-col="swatBoundDuration" @mousedown.stop="startResize($event, 'swatBoundDuration')"></div></th>
              <th v-if="colVisible('swatRecoverDuration')" class="resizable" :style="colWidth('swatRecoverDuration')">SWAT介入恢复耗时<div class="resize-handle" data-col="swatRecoverDuration" @mousedown.stop="startResize($event, 'swatRecoverDuration')"></div></th>
              <th v-if="colVisible('e2eDuration')" class="resizable" :style="colWidth('e2eDuration')">端到端恢复耗时<div class="resize-handle" data-col="e2eDuration" @mousedown.stop="startResize($event, 'e2eDuration')"></div></th>
              <th class="sticky-col" style="position:sticky;right:0;z-index:5;background:#fafafa">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredIssues" :key="item.id">
              <td v-if="colVisible('issueNo')"><code>{{ item.issueNo }}</code></td>
              <td class="sticky-left" :style="stickyStyle('occurTime', 0)">{{ item.handleDate || formatDate(item.occurTime) }}</td>
              <td class="sticky-left" :style="stickyStyle('customerName', 120)">{{ item.customerName || '-' }}</td>
              <td class="sticky-left desc-cell" :style="stickyStyle('description', 260)">{{ item.description || '-' }}</td>
              <td v-if="colVisible('category')"><span class="cat-badge" :class="catBadgeClass(item.category)">{{ item.category || '-' }}</span></td>
              <td v-if="colVisible('kernelVersion')">{{ item.kernelVersion || '-' }}</td>
              <td v-if="colVisible('status')"><span class="status-tag" :class="'s-' + item.status">{{ item.status || '-' }}</span></td>
              <td v-if="colVisible('keySite')">{{ item.keySite ? '是' : '否' }}</td>
              <td v-if="colVisible('siteType')">{{ item.siteType || '-' }}</td>
              <td v-if="colVisible('mgmtDeploy')">{{ item.mgmtDeploy || '-' }}</td>
              <td v-if="colVisible('rl')">{{ item.rl || '-' }}</td>
              <td v-if="colVisible('opsTicket')">{{ item.opsTicket || '-' }}</td>
              <td v-if="colVisible('ecareTicket')">{{ item.ecareTicket || '-' }}</td>
              <td v-if="colVisible('kernelDeploy')">{{ item.kernelDeploy || '-' }}</td>
              <td v-if="colVisible('bizInterrupt')">{{ item.bizInterrupt ? '是' : '否' }}</td>
              <td v-if="colVisible('urgentRecover')">{{ item.urgentRecover ? '是' : '否' }}</td>
              <td v-if="colVisible('hasAlarm')">{{ item.hasAlarm ? '有' : '无' }}</td>
              <td v-if="colVisible('alarmTrigger')">{{ item.alarmTrigger ? '是' : '否' }}</td>
              <td v-if="colVisible('occurTimeFull')">{{ item.occurTime || '-' }}</td>
              <td v-if="colVisible('perceiveTime')">{{ item.perceiveTime || '-' }}</td>
              <td v-if="colVisible('createTime')">{{ item.createTime || '-' }}</td>
              <td v-if="colVisible('swatStartTime')">{{ item.swatStartTime || '-' }}</td>
              <td v-if="colVisible('boundTime')">{{ item.boundTime || '-' }}</td>
              <td v-if="colVisible('bizRecoverTime')">{{ item.bizRecoverTime || '-' }}</td>
              <td v-if="colVisible('swatPullTime')">{{ calcMinDisplay(item.createTime, item.swatStartTime) }}</td>
              <td v-if="colVisible('discoverDuration')">{{ calcMinDisplay(item.occurTime, item.perceiveTime) }}</td>
              <td v-if="colVisible('createOrderDuration')">{{ calcMinDisplay(item.perceiveTime, item.createTime) }}</td>
              <td v-if="colVisible('warroomDuration')">{{ calcMinDisplay(item.createTime, item.swatStartTime) }}</td>
              <td v-if="colVisible('swatBoundDuration')">{{ calcMinDisplay(item.swatStartTime, item.boundTime) }}</td>
              <td v-if="colVisible('swatRecoverDuration')">{{ calcMinDisplay(item.swatStartTime, item.bizRecoverTime) }}</td>
              <td v-if="colVisible('e2eDuration')">{{ calcMinDisplay(item.occurTime, item.bizRecoverTime) }}</td>
              <td class="sticky-col">
                <button class="btn-action" @click="$router.push('/home/issues/' + item.id)">编辑</button>
                <button class="btn-action danger" @click="deleteIssue(item)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
        </div>

        <div v-if="filteredIssues.length === 0" class="empty">
          <div class="empty-icon">&#x1F50D;</div>
          <div>暂无匹配的问题记录</div>
        </div>

        <!-- Pagination -->
        <div class="pagination">
          <div class="page-left">
            <select v-model.number="pageSize" class="page-size-select" @change="onPageSizeChange">
              <option :value="10">10 条/页</option>
              <option :value="20">20 条/页</option>
              <option :value="50">50 条/页</option>
              <option :value="100">100 条/页</option>
            </select>
          </div>
          <div class="page-center">
            <button class="page-btn" :disabled="page <= 1" @click="goPage(1)">首页</button>
            <button class="page-btn" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
            <button
              v-for="p in pageNumbers" :key="p"
              class="page-btn" :class="{ active: p === page }"
              @click="goPage(p)"
            >{{ p }}</button>
            <button class="page-btn" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
            <button class="page-btn" :disabled="page >= totalPages" @click="goPage(totalPages)">末页</button>
          </div>
          <span class="page-info">共 {{ effectiveTotal }} 条，第 {{ page }}/{{ totalPages }} 页</span>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editing ? '编辑问题' : '新增问题' }}</h3>
        <form @submit.prevent="saveIssue">

          <!-- Row 1 -->
          <div class="form-row">
            <div class="form-group">
              <label>日期 <span class="required">*</span></label>
              <input v-model="form.handleDate" type="date" />
            </div>
            <div class="form-group">
              <label>客户名称 <span class="required">*</span></label>
              <div class="searchable-select" ref="siteDropdown">
                <div class="select-input" @click="siteDropdownOpen = !siteDropdownOpen">
                  <span v-if="form.customerName" class="selected-text">{{ form.customerName }}</span>
                  <span v-else class="placeholder">请选择客户</span>
                  <span class="arrow">&#x25BE;</span>
                </div>
                <div class="select-dropdown" v-show="siteDropdownOpen">
                  <input v-model="siteSearch" type="text" class="dropdown-search" placeholder="搜索局点..." @click.stop />
                  <div class="dropdown-list">
                    <div v-for="site in filteredSites" :key="site.id" class="dropdown-option"
                      :class="{ active: form.customerName === site.name }" @click="selectSite(site.name)">{{ site.name }}</div>
                    <div v-if="filteredSites.length === 0" class="dropdown-empty">无匹配局点</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Row 2 -->
          <div class="form-row">
            <div class="form-group">
              <label>管控部署形态 <span class="required">*</span></label>
              <select v-model="form.mgmtDeploy" class="field-select">
                <option value="">请选择</option>
                <option value="TPOPS">TPOPS</option>
                <option value="HCS">HCS</option>
                <option value="HCSO">HCSO</option>
                <option value="公有云">公有云</option>
              </select>
            </div>
            <div class="form-group">
              <label>内核版本 <span class="required">*</span></label>
              <select v-model="form.kernelVersion" class="field-select" @mousedown="onKernelClick">
                <option value="">请选择版本</option>
                <option v-for="v in filteredVersions" :key="v.id" :value="v.versionCode">{{ v.versionCode }}</option>
              </select>
            </div>
          </div>

          <!-- Row 3 -->
          <div class="form-row">
            <div class="form-group">
              <label>内核部署形态 <span class="required">*</span></label>
              <select v-model="form.kernelDeploy" class="field-select">
                <option value="">请选择</option>
                <option value="集中式">集中式</option>
                <option value="分布式">分布式</option>
                <option value="单节点">单节点</option>
              </select>
            </div>
            <div class="form-group">
              <label>RL <span class="required">*</span></label>
              <select v-model="form.rl" class="field-select">
                <option value="">请选择RL</option>
                <option v-for="r in allRls" :key="r.id" :value="r.name">{{ r.name }}</option>
              </select>
            </div>
          </div>

          <!-- Row 4 -->
          <div class="form-row">
            <div class="form-group">
              <label>有无告警 <span class="required">*</span></label>
              <select v-model="form.hasAlarm" class="field-select">
                <option value="">请选择</option>
                <option value="yes">有</option>
                <option value="no">无</option>
              </select>
            </div>
            <div class="form-group">
              <label>告警触发 <span class="required">*</span></label>
              <select v-model="form.alarmTrigger" class="field-select">
                <option value="">请选择</option>
                <option value="yes">是</option>
                <option value="no">否</option>
              </select>
            </div>
          </div>

          <!-- Row 5 -->
          <div class="form-row">
            <div class="form-group">
              <label>业务中断 <span class="required">*</span></label>
              <select v-model="form.bizInterrupt" class="field-select">
                <option value="">请选择</option>
                <option value="yes">是</option>
                <option value="no">否</option>
              </select>
            </div>
            <div class="form-group">
              <label>紧急恢复 <span class="required">*</span></label>
              <select v-model="form.urgentRecover" class="field-select">
                <option value="">请选择</option>
                <option value="yes">是</option>
                <option value="no">否</option>
              </select>
            </div>
          </div>

          <!-- Row 5b - Category -->
          <div class="form-group">
            <label>问题分类</label>
            <div class="cascade-selects">
              <select v-model="form.catL1" class="field-select" @change="form.catL2='';form.catL3=''">
                <option value="">一级分类</option>
                <option v-for="l1 in categories" :key="l1.key" :value="l1.key + ':' + l1.name">{{ l1.name }}</option>
              </select>
              <select v-model="form.catL2" class="field-select" :disabled="!catL2Opts.length" @change="form.catL3=''">
                <option value="">二级分类</option>
                <option v-for="l2 in catL2Opts" :key="l2.key" :value="l2.key + ':' + l2.name">{{ l2.name }}</option>
              </select>
              <select v-model="form.catL3" class="field-select" :disabled="!catL3Opts.length">
                <option value="">三级分类</option>
                <option v-for="l3 in catL3Opts" :key="l3.key" :value="l3.key + ':' + l3.name">{{ l3.name }}</option>
              </select>
            </div>
          </div>

          <!-- Row 6 - Timeline -->
          <div class="form-row">
            <div class="form-group">
              <label>问题发生时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.occurTime" type="datetime-local" />
            </div>
            <div class="form-group">
              <label>一线感知时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.perceiveTime" type="datetime-local" />
            </div>
          </div>

          <!-- Row 6b -->
          <div class="form-row">
            <div class="form-group">
              <label>问题建单时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.createTime" type="datetime-local" />
            </div>
            <div class="form-group">
              <label>SWAT开始处理时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.swatStartTime" type="datetime-local" />
            </div>
          </div>

          <!-- Row 7 -->
          <div class="form-row">
            <div class="form-group">
              <label>问题定界时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.boundTime" type="datetime-local" />
            </div>
            <div class="form-group">
              <label>业务恢复时间 <span v-if="form.urgentRecover === 'yes'" class="required">*</span></label>
              <input v-model="form.bizRecoverTime" type="datetime-local" />
            </div>
          </div>

          <!-- Row 8 - Status (edit only) -->
          <div class="form-row" v-if="editing">
            <div class="form-group">
              <label>状态</label>
              <select v-model="form.status">
                <option value="待处理">待处理</option>
                <option value="处理中">处理中</option>
                <option value="已解决">已解决</option>
                <option value="已关闭">已关闭</option>
              </select>
            </div>
          </div>

          <!-- Problem description -->
          <div class="form-group">
            <label>问题简述</label>
            <textarea v-model="form.description" rows="3" placeholder="请简要描述问题..."></textarea>
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

    <!-- Import Modal -->
    <div class="modal-overlay" v-if="showImport" @click.self="showImport = false">
      <div class="modal">
        <h3>批量导入问题</h3>
        <div class="import-area" @click="pickFile">
          <input type="file" ref="importFileInput" accept=".csv,.xlsx,.xls" @change="handleFile" class="import-file-input" />
          <div class="import-upload">
            <span class="import-icon">&#x1F4C2;</span>
            <p>点击选择文件</p>
            <p class="import-hint">支持 CSV、Excel（.xlsx）格式</p>
          </div>
        </div>
        <div v-if="importPreview.length" class="import-preview">
          <h4>预览 ({{ importPreview.length }} 条)</h4>
          <div class="preview-table-wrap">
            <table class="preview-table">
              <thead>
                <tr><th v-for="k in importKeys" :key="k">{{ k }}</th></tr>
              </thead>
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
          <button class="btn-submit" :disabled="!importPreview.length || importing" @click="doImport">
            {{ importing ? '导入中...' : '确认导入' }}
          </button>
          <button class="btn-cancel" @click="showImport = false">取消</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Teleported Filter Popups -->
  <teleport to="body">
    <div v-if="showDatePicker" class="filter-popup-overlay" @click="showDatePicker = false"></div>
    <div v-if="showDatePicker" class="date-picker-popup" :style="popupStyleDate" @click.stop>
      <input v-model="filterDateStart" type="date" class="popup-date" />
      <span class="date-sep">至</span>
      <input v-model="filterDateEnd" type="date" class="popup-date" />
      <button class="popup-confirm" @click="onDateFilter">确定</button>
      <button v-if="filterDateStart || filterDateEnd" class="popup-clear" @click="filterDateStart='';filterDateEnd='';onDateFilter()">清除</button>
    </div>

    <div v-if="showCustomerFilter" class="filter-popup-overlay" @click="showCustomerFilter = false"></div>
    <div v-if="showCustomerFilter" class="customer-filter-popup" :style="popupStyleCustomer" @click.stop>
      <input v-model="customerSearch" type="text" class="filter-popup-search" placeholder="搜索..." @click.stop />
      <div class="filter-popup-divider"></div>
      <div class="filter-checkbox-list">
        <div v-for="name in filteredCustomerNames" :key="name" class="filter-checkbox-item" @click="toggleCustomerName(name)">
          <span class="filter-checkbox" :class="{ checked: filterCustomerName.includes(name) }">
            <span v-if="filterCustomerName.includes(name)" class="check-icon">&#x2713;</span>
          </span>
          <span class="filter-checkbox-label">{{ name }}</span>
        </div>
        <div v-if="uniqueCustomerNames.length === 0" class="filter-empty">暂无客户数据</div>
      </div>
      <div class="filter-popup-actions">
        <button class="popup-confirm" @click="onCustomerFilter">确定</button>
        <button v-if="filterCustomerName.length" class="popup-clear" @click="filterCustomerName=[];onCustomerFilter()">清除</button>
      </div>
    </div>

    <div v-if="showVersionPicker" class="filter-popup-overlay" @click="showVersionPicker = false"></div>
    <div v-if="showVersionPicker" class="version-picker-popup" :style="popupStyleVersion" @click.stop>
      <input v-model="versionSearch" type="text" class="filter-popup-search" placeholder="搜索..." @click.stop />
      <div class="filter-popup-divider"></div>
      <div class="filter-checkbox-list">
        <div v-for="v in filteredKernelVersions" :key="v" class="filter-checkbox-item" @click="toggleKernelVersion(v)">
          <span class="filter-checkbox" :class="{ checked: filterKernelVersions.includes(v) }">
            <span v-if="filterKernelVersions.includes(v)" class="check-icon">&#x2713;</span>
          </span>
          <span class="filter-checkbox-label">{{ v }}</span>
        </div>
        <div v-if="uniqueKernelVersions.length === 0" class="filter-empty">暂无版本数据</div>
      </div>
      <div class="filter-popup-actions">
        <button class="popup-confirm" @click="onVersionFilter">确定</button>
        <button v-if="filterKernelVersions.length" class="popup-clear" @click="filterKernelVersions=[];onVersionFilter()">清除</button>
      </div>
    </div>

    <div v-if="showUrgentFilter" class="filter-popup-overlay" @click="showUrgentFilter = false"></div>
    <div v-if="showUrgentFilter" class="version-picker-popup" :style="popupStyleUrgent" @click.stop>
      <div class="filter-checkbox-list">
        <div class="filter-checkbox-item" @click="filterUrgentRecover='是';onUrgentFilter()">
          <span class="filter-checkbox" :class="{ checked: filterUrgentRecover==='是' }"><span v-if="filterUrgentRecover==='是'" class="check-icon">&#x2713;</span></span>
          <span class="filter-checkbox-label">是（紧急恢复）</span>
        </div>
        <div class="filter-checkbox-item" @click="filterUrgentRecover='否';onUrgentFilter()">
          <span class="filter-checkbox" :class="{ checked: filterUrgentRecover==='否' }"><span v-if="filterUrgentRecover==='否'" class="check-icon">&#x2713;</span></span>
          <span class="filter-checkbox-label">否</span>
        </div>
      </div>
      <div class="filter-popup-actions">
        <button v-if="filterUrgentRecover" class="popup-clear" @click="filterUrgentRecover='';onUrgentFilter()">清除</button>
      </div>
    </div>
  </teleport>
</template>

<script>
import { fetchIssues, createIssue, updateIssue, deleteIssue, fetchCategoryTree, fetchAllSites, fetchAllVersions, fetchRls } from '../api'
import { ElMessageBox, ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'

export default {
  name: 'IssuesView',
  data() {
    return {
      keyword: '',
      filterStatus: '',
      filterDateStart: '',
      filterDateEnd: '',
      showDatePicker: false,
      popupStyleDate: {},
      popupStyleCustomer: {},
      popupStyleVersion: {},
      filterKernelVersions: [],
      showVersionPicker: false,
      filterCustomerName: [],
      filterKernelVersions: [],
      filterUrgentRecover: '',
      showUrgentFilter: false,
      showCustomerFilter: false,
      customerSearch: '',
      versionSearch: '',
      allCustomerNames: [],
      page: 1,
      pageSize: 10,
      total: 0,
      showModal: false,
      showImport: false,
      importPreview: [],
      importError: '',
      importSuccess: '',
      importing: false,
      editing: false,
      editId: null,
      saving: false,
      errorMsg: '',
      form: { occurTime: '', handleDate: '', customerName: '', description: '', category: '', kernelVersion: '', status: '待处理',
        mgmtDeploy: '', kernelDeploy: '', rl: '', hasAlarm: '', alarmTrigger: '',
        bizInterrupt: '', urgentRecover: '',
        perceiveTime: '', createTime: '', swatStartTime: '', boundTime: '', bizRecoverTime: '',
        catL1: '', catL2: '', catL3: '' },
      issues: [],
      allIssuesFull: [],
      allIssuesFiltered: [],
      searchTimer: null,
      allSites: [],
      allVersions: [],
      allRls: [],
      siteSearch: '',
      siteDropdownOpen: false,
      showColumnPicker: false,
      columnWidths: {},
      resizing: null,
      columnDefs: [
        { key: 'issueNo', label: '问题编号', visible: false, defaultVisible: false },
        { key: 'category', label: '问题分类', visible: true, defaultVisible: true },
        { key: 'kernelVersion', label: '内核版本', visible: true, defaultVisible: true },
        { key: 'status', label: '状态', visible: false, defaultVisible: false },
        { key: 'keySite', label: '重点局点', visible: false, defaultVisible: false },
        { key: 'siteType', label: '局点类型', visible: false, defaultVisible: false },
        { key: 'mgmtDeploy', label: '管控部署形态', visible: false, defaultVisible: false },
        { key: 'rl', label: 'RL', visible: false, defaultVisible: false },
        { key: 'opsTicket', label: '运维系统单号', visible: false, defaultVisible: false },
        { key: 'ecareTicket', label: 'ecare单号', visible: false, defaultVisible: false },
        { key: 'kernelDeploy', label: '内核部署形态', visible: true, defaultVisible: true },
        { key: 'bizInterrupt', label: '业务中断', visible: false, defaultVisible: false },
        { key: 'urgentRecover', label: '紧急恢复', visible: false, defaultVisible: false },
        { key: 'hasAlarm', label: '有无告警', visible: false, defaultVisible: false },
        { key: 'alarmTrigger', label: '告警触发', visible: false, defaultVisible: false },
        { key: 'occurTimeFull', label: '问题发生时间', visible: false, defaultVisible: false },
        { key: 'perceiveTime', label: '一线感知时间', visible: false, defaultVisible: false },
        { key: 'createTime', label: '问题建单时间', visible: false, defaultVisible: false },
        { key: 'swatStartTime', label: 'SWAT开始处理时间', visible: false, defaultVisible: false },
        { key: 'boundTime', label: '问题定界时间', visible: false, defaultVisible: false },
        { key: 'bizRecoverTime', label: '业务恢复时间', visible: false, defaultVisible: false },
        { key: 'swatPullTime', label: '拉SWAT时间', visible: false, defaultVisible: false },
        { key: 'discoverDuration', label: '问题发现耗时', visible: false, defaultVisible: false },
        { key: 'createOrderDuration', label: '一线建单耗时', visible: false, defaultVisible: false },
        { key: 'warroomDuration', label: '启动WARROOM耗时', visible: false, defaultVisible: false },
        { key: 'swatBoundDuration', label: 'SWAT定界耗时', visible: true, defaultVisible: true },
        { key: 'swatRecoverDuration', label: 'SWAT介入恢复耗时', visible: true, defaultVisible: true },
        { key: 'e2eDuration', label: '端到端恢复耗时', visible: true, defaultVisible: true }
      ],
      selected: { l1: [], l2: [], l3: [] },
      categories: [],
      _defaultCategories: [
        {
          key: 'func', name: '功能问题', color: 'blue', open: false,
          children: [
            { key: 'func-kernel', name: '内核模块', open: false, children: [
              { key: 'func-kernel-bug', name: '缺陷' }, { key: 'func-kernel-feat', name: '需求' }, { key: 'func-kernel-opt', name: '优化' }
            ]},
            { key: 'func-network', name: '网络模块', open: false, children: [
              { key: 'func-network-bug', name: '缺陷' }, { key: 'func-network-feat', name: '需求' }, { key: 'func-network-opt', name: '优化' }
            ]},
            { key: 'func-storage', name: '存储模块', open: false, children: [
              { key: 'func-storage-bug', name: '缺陷' }, { key: 'func-storage-feat', name: '需求' }
            ]},
            { key: 'func-api', name: 'API模块', open: false, children: [
              { key: 'func-api-bug', name: '缺陷' }, { key: 'func-api-feat', name: '需求' }, { key: 'func-api-opt', name: '优化' }
            ]}
          ]
        },
        {
          key: 'perf', name: '性能问题', color: 'orange', open: false,
          children: [
            { key: 'perf-cpu', name: 'CPU', open: false, children: [
              { key: 'perf-cpu-high', name: '占用过高' }, { key: 'perf-cpu-leak', name: '泄漏' }, { key: 'perf-cpu-spike', name: '间歇峰值' }
            ]},
            { key: 'perf-mem', name: '内存', open: false, children: [
              { key: 'perf-mem-leak', name: '内存泄漏' }, { key: 'perf-mem-oom', name: 'OOM' }, { key: 'perf-mem-frag', name: '碎片化' }
            ]},
            { key: 'perf-io', name: 'IO', open: false, children: [
              { key: 'perf-io-slow', name: '读写延迟' }, { key: 'perf-io-thru', name: '吞吐不足' }
            ]}
          ]
        },
        {
          key: 'security', name: '安全问题', color: 'red', open: false,
          children: [
            { key: 'sec-auth', name: '认证鉴权', open: false, children: [
              { key: 'sec-auth-bypass', name: '越权访问' }, { key: 'sec-auth-expire', name: '会话失效' }
            ]},
            { key: 'sec-vuln', name: '漏洞', open: false, children: [
              { key: 'sec-vuln-cve', name: 'CVE漏洞' }, { key: 'sec-vuln-inject', name: '注入攻击' }
            ]}
          ]
        },
        {
          key: 'compat', name: '兼容性问题', color: 'purple', open: false,
          children: [
            { key: 'compat-os', name: '操作系统', open: false, children: [
              { key: 'compat-os-linux', name: 'Linux' }, { key: 'compat-os-win', name: 'Windows' }, { key: 'compat-os-mac', name: 'macOS' }
            ]},
            { key: 'compat-db', name: '数据库', open: false, children: [
              { key: 'compat-db-pg', name: 'PostgreSQL' }, { key: 'compat-db-mysql', name: 'MySQL' }
            ]}
          ]
        },
        {
          key: 'ux', name: '体验优化', color: 'green', open: false,
          children: [
            { key: 'ux-ui', name: 'UI交互', open: false, children: [
              { key: 'ux-ui-layout', name: '布局错乱' }, { key: 'ux-ui-style', name: '样式问题' }, { key: 'ux-ui-ux', name: '交互优化' }
            ]},
            { key: 'ux-doc', name: '文档', open: false, children: [
              { key: 'ux-doc-error', name: '文档错误' }, { key: 'ux-doc-miss', name: '文档缺失' }
            ]}
          ]
        }
      ]
    }
  },
  computed: {
    hasSelection() {
      return this.selected.l1.length > 0 || this.selected.l2.length > 0 || this.selected.l3.length > 0
    },
    selectedCount() {
      return this.selected.l1.length + this.selected.l2.length + this.selected.l3.length
    },
    filteredSites() {
      const kw = this.siteSearch.toLowerCase()
      return this.allSites.filter(s => s.name.toLowerCase().includes(kw))
    },
    importKeys() {
      if (!this.importPreview.length) return []
      return Object.keys(this.importPreview[0])
    },
    filteredVersions() {
      if (!this.form.customerName) return []
      const site = this.allSites.find(s => s.name === this.form.customerName)
      if (!site || !site.versionIds) return []
      const ids = this.parseIds(site.versionIds)
      return this.allVersions.filter(v => ids.includes(v.id))
    },
    uniqueCustomerNames() {
      const names = new Set(this.allCustomerNames)
      this.filterCustomerName.forEach(n => names.add(n))
      return Array.from(names).sort()
    },
    filteredCustomerNames() {
      const kw = this.customerSearch.toLowerCase()
      return this.uniqueCustomerNames.filter(n => n.toLowerCase().includes(kw))
    },
    uniqueKernelVersions() {
      const versions = new Set()
      this.filterKernelVersions.forEach(v => versions.add(v))
      this.allIssuesFull.forEach(i => { if (i.kernelVersion) versions.add(i.kernelVersion) })
      this.allVersions.forEach(v => { if (v.versionCode) versions.add(v.versionCode) })
      return Array.from(versions).sort()
    },
    filteredKernelVersions() {
      const kw = this.versionSearch.toLowerCase()
      return this.uniqueKernelVersions.filter(v => v.toLowerCase().includes(kw))
    },
    catL2Opts() {
      if (!this.form.catL1) return []
      const key = this.form.catL1.split(':')[0]
      const l1 = this.categories.find(c => c.key === key)
      return l1 ? (l1.children || []) : []
    },
    catL3Opts() {
      if (!this.form.catL2) return []
      const key = this.form.catL2.split(':')[0]
      for (const l1 of this.categories) {
        if (l1.children) {
          const l2 = l1.children.find(c => c.key === key)
          if (l2) return l2.children || []
        }
      }
      return []
    },
    categoryFiltered() {
      if (!this.hasSelection) return []
      const sel = new Set([...this.selected.l1, ...this.selected.l2, ...this.selected.l3])
      return this.allIssuesFiltered.filter(item => {
        const catKey = this.resolveCategoryKey(item.category)
        return catKey && sel.has(catKey)
      })
    },
    filteredIssues() {
      if (!this.hasSelection) return this.issues
      const start = (this.page - 1) * this.pageSize
      return this.categoryFiltered.slice(start, start + this.pageSize)
    },
    effectiveTotal() {
      return this.hasSelection ? this.categoryFiltered.length : this.total
    },
    totalPages() {
      return Math.max(1, Math.ceil(this.effectiveTotal / this.pageSize))
    },
    pageNumbers() {
      const pages = []
      const tp = this.totalPages
      let start = Math.max(1, this.page - 2)
      let end = Math.min(tp, this.page + 2)
      if (end - start < 4) {
        if (start === 1) end = Math.min(tp, start + 4)
        else start = Math.max(1, end - 4)
      }
      for (let i = start; i <= end; i++) pages.push(i)
      return pages
    }
  },
  mounted() {
    this.loadIssues(); this.loadAllIssuesForCounts(); this.loadAllIssuesFull(); this.loadCategories(); this.loadSites(); this.loadVersions(); this.loadRls(); this.loadCustomerNameOptions()
    document.addEventListener('click', this.onClickOutside)
    this.columnDefs.forEach(c => {
      if (c.visible && !this.columnWidths[c.key]) {
        this.columnWidths = { ...this.columnWidths, [c.key]: 120 }
      }
    })
    if (!this.columnWidths['occurTime']) this.columnWidths = { ...this.columnWidths, occurTime: 120 }
    if (!this.columnWidths['customerName']) this.columnWidths = { ...this.columnWidths, customerName: 120 }
    if (!this.columnWidths['description']) this.columnWidths = { ...this.columnWidths, description: 140 }
    if (!this.columnWidths['kernelDeploy']) this.columnWidths = { ...this.columnWidths, kernelDeploy: 120 }
    if (!this.columnWidths['swatBoundDuration']) this.columnWidths = { ...this.columnWidths, swatBoundDuration: 130 }
    if (!this.columnWidths['swatRecoverDuration']) this.columnWidths = { ...this.columnWidths, swatRecoverDuration: 140 }
    if (!this.columnWidths['e2eDuration']) this.columnWidths = { ...this.columnWidths, e2eDuration: 130 }
  },
  beforeUnmount() { document.removeEventListener('click', this.onClickOutside) },
  methods: {
    onClickOutside(e) {
      if (this.$refs.siteDropdown && !this.$refs.siteDropdown.contains(e.target)) {
        this.siteDropdownOpen = false
      }
      if (this.showColumnPicker && !e.target.closest('.gear-btn-wrap')) {
        this.showColumnPicker = false
      }
      if (this.showDatePicker && !e.target.closest('.th-filter')) {
        this.showDatePicker = false
      }
      if (this.showVersionPicker && !e.target.closest('.th-filter')) {
        this.showVersionPicker = false
      }
      if (this.showCustomerFilter && !e.target.closest('.th-filter')) {
        this.showCustomerFilter = false
      }
    },
    colVisible(key) {
      if (key === 'occurTime' || key === 'customerName' || key === 'description') return true
      const def = this.columnDefs.find(c => c.key === key)
      return def ? def.visible : false
    },
    toggleColumn(key) {
      const def = this.columnDefs.find(c => c.key === key)
      if (def) {
        def.visible = !def.visible
        if (def.visible && !this.columnWidths[key]) {
          this.columnWidths = { ...this.columnWidths, [key]: 120 }
        }
      }
    },
    resetColumns() {
      this.columnDefs.forEach(c => { c.visible = c.defaultVisible })
    },
    stickyStyle(key, defW) {
      const w = (this.columnWidths[key] || defW)
      const leftKeys = { occurTime: 0, customerName: 0, description: 0 }
      const order = ['issueNo', 'occurTime', 'customerName', 'description']
      let left = 0
      for (const k of order) {
        if (k === key) break
        if (k === 'issueNo' && this.colVisible('issueNo')) left += (this.columnWidths['issueNo'] || 120)
        if (k === 'occurTime') left += (this.columnWidths['occurTime'] || 120)
        if (k === 'customerName') left += (this.columnWidths['customerName'] || 120)
      }
      return { width: w + 'px', minWidth: w + 'px', left: left + 'px' }
    },
    colWidth(key) {
      const w = this.columnWidths[key]
      return w ? { width: w + 'px', minWidth: w + 'px' } : {}
    },
    colStyle(key) {
      const w = this.columnWidths[key] || 120
      return { width: w + 'px', minWidth: w + 'px' }
    },
    startResize(e, col) {
      const ths = this.$refs.resizeTable.querySelectorAll('thead th.resizable')
      const widths = {}
      ths.forEach(th => {
        const key = th.querySelector('.resize-handle')?.dataset.col
        if (key) widths[key] = th.offsetWidth
      })
      this.resizing = { col, startX: e.clientX, startW: widths[col] || 120, allWidths: widths }
      document.addEventListener('mousemove', this.doResize)
      document.addEventListener('mouseup', this.stopResize)
      e.preventDefault()
    },
    doResize(e) {
      if (!this.resizing) return
      const diff = e.clientX - this.resizing.startX
      const newW = Math.max(80, this.resizing.startW + diff)
      this.columnWidths = { ...this.resizing.allWidths, [this.resizing.col]: newW }
    },
    stopResize() {
      this.resizing = null
      document.removeEventListener('mousemove', this.doResize)
      document.removeEventListener('mouseup', this.stopResize)
    },
    onKernelClick() {
      if (!this.form.customerName) {
        ElMessage.warning('请选择客户名称')
      }
    },
    parseIds(raw) {
      if (!raw) return []
      if (Array.isArray(raw)) return raw
      try { return JSON.parse(raw) } catch { return [] }
    },
    selectSite(name) {
      this.form.customerName = name
      this.form.kernelVersion = ''
      this.siteDropdownOpen = false
      this.siteSearch = ''
    },
    async loadSites() {
      try {
        const res = await fetchAllSites()
        this.allSites = Array.isArray(res.data) ? res.data : []
      } catch { this.allSites = [] }
    },
    async loadVersions() {
      try {
        const res = await fetchAllVersions()
        this.allVersions = Array.isArray(res.data) ? res.data : []
      } catch { this.allVersions = [] }
    },
    async loadRls() {
      try {
        const res = await fetchRls()
        this.allRls = Array.isArray(res.data) ? res.data : []
      } catch { this.allRls = [] }
    },
    async loadCustomerNameOptions() {
      try {
        const res = await fetchIssues('', '', 1, 100000, '', '', '', '')
        const data = res.data
        const issues = Array.isArray(data.list) ? data.list : (Array.isArray(data) ? data : [])
        const names = new Set()
        issues.forEach(i => { if (i.customerName) names.add(i.customerName) })
        this.allCustomerNames = Array.from(names).sort()
      } catch { this.allCustomerNames = [] }
    },
    async loadCategories() {
      try {
        const res = await fetchCategoryTree()
        const data = Array.isArray(res.data) ? res.data : []
        this.categories = data.length > 0 ? this.transformTree(data) : []
      } catch { this.categories = [] }
    },
    transformTree(nodes) {
      return nodes.map(n => ({
        key: String(n.id),
        name: n.name,
        color: n.color || 'blue',
        open: false,
        children: n.children ? this.transformTree(n.children) : []
      }))
    },
    resolveCategoryKey(cat) {
      if (!cat) return null
      for (const l1 of this.categories) {
        for (const l2 of l1.children) {
          for (const l3 of l2.children) {
            if (cat.includes(l3.name)) return l3.key
          }
          if (cat.includes(l2.name)) return l2.key
        }
        if (cat.startsWith(l1.name)) return l1.key
      }
      return null
    },
    buildAllKeys() {
      const all = { l1: new Set(), l2: new Set(), l3: new Set() }
      for (const l1 of this.categories) {
        all.l1.add(l1.key)
        for (const l2 of l1.children) {
          all.l2.add(l2.key)
          for (const l3 of l2.children) all.l3.add(l3.key)
        }
      }
      return all
    },
    // -- Indeterminate helpers --
    isL1Checked(l1) {
      return this.selected.l1.includes(l1.key)
    },
    isL1Partial(l1) {
      if (this.selected.l1.includes(l1.key)) return false
      for (const l2 of l1.children) {
        if (this.selected.l2.includes(l2.key)) return true
        if (l2.children.some(l3 => this.selected.l3.includes(l3.key))) return true
      }
      return false
    },
    isL2Checked(l1, l2) {
      return this.selected.l2.includes(l2.key)
    },
    isL2Partial(l1, l2) {
      if (this.selected.l2.includes(l2.key)) return false
      return l2.children.some(l3 => this.selected.l3.includes(l3.key))
    },

    // -- Cascade toggle --
    toggleL1(l1) {
      const l2keys = l1.children.map(l2 => l2.key)
      const l3keys = []; l1.children.forEach(l2 => l2.children.forEach(l3 => l3keys.push(l3.key)))
      if (this.isL1Checked(l1)) {
        this.selected.l1 = this.selected.l1.filter(k => k !== l1.key)
        this.selected.l2 = this.selected.l2.filter(k => !l2keys.includes(k))
        this.selected.l3 = this.selected.l3.filter(k => !l3keys.includes(k))
      } else {
        if (!this.selected.l1.includes(l1.key)) this.selected.l1.push(l1.key)
        l2keys.forEach(k => { if (!this.selected.l2.includes(k)) this.selected.l2.push(k) })
        l3keys.forEach(k => { if (!this.selected.l3.includes(k)) this.selected.l3.push(k) })
      }
      this.page = 1; this.loadIssues()
    },
    toggleL2(l1, l2) {
      const l3keys = l2.children.map(l3 => l3.key)
      if (this.isL2Checked(l1, l2)) {
        this.selected.l2 = this.selected.l2.filter(k => k !== l2.key)
        this.selected.l3 = this.selected.l3.filter(k => !l3keys.includes(k))
        this.selected.l1 = this.selected.l1.filter(k => k !== l1.key)
      } else {
        if (!this.selected.l2.includes(l2.key)) this.selected.l2.push(l2.key)
        l3keys.forEach(k => { if (!this.selected.l3.includes(k)) this.selected.l3.push(k) })
        if (l1.children.every(c => this.selected.l2.includes(c.key))) {
          if (!this.selected.l1.includes(l1.key)) this.selected.l1.push(l1.key)
        }
      }
      this.page = 1; this.loadIssues()
    },
    toggleL3(l1, l2, l3) {
      const idx = this.selected.l3.indexOf(l3.key)
      if (idx >= 0) {
        this.selected.l3.splice(idx, 1)
        this.selected.l2 = this.selected.l2.filter(k => k !== l2.key)
        this.selected.l1 = this.selected.l1.filter(k => k !== l1.key)
      } else {
        if (!this.selected.l3.includes(l3.key)) this.selected.l3.push(l3.key)
        // If all L3 under this L2 now selected, auto-select L2
        const allL3 = l2.children.every(c => this.selected.l3.includes(c.key))
        if (allL3 && !this.selected.l2.includes(l2.key)) {
          this.selected.l2.push(l2.key)
        }
        // If all L2 under this L1 now selected, auto-select L1
        const allL2 = l1.children.every(c => this.selected.l2.includes(c.key))
        if (allL2 && !this.selected.l1.includes(l1.key)) {
          this.selected.l1.push(l1.key)
        }
      }
      this.page = 1; this.loadIssues()
    },
    countIssuesByL1(l1) {
      const keys = new Set([l1.key])
      l1.children.forEach(l2 => {
        keys.add(l2.key)
        l2.children.forEach(l3 => keys.add(l3.key))
      })
      return this.allIssuesFiltered.filter(i => {
        const k = this.resolveCategoryKey(i.category)
        return k && keys.has(k)
      }).length
    },
    countIssuesByL2(l1, l2) {
      const keys = new Set([l2.key])
      l2.children.forEach(l3 => keys.add(l3.key))
      return this.allIssuesFiltered.filter(i => {
        const k = this.resolveCategoryKey(i.category)
        return k && keys.has(k)
      }).length
    },
    countIssuesByL3(l3) {
      return this.allIssuesFiltered.filter(i => {
        const k = this.resolveCategoryKey(i.category)
        return k === l3.key
      }).length
    },
    catBadgeClass(cat) {
      if (!cat) return ''
      for (const l1 of this.categories) {
        if (cat.startsWith(l1.name)) return 'badge-' + l1.color
      }
      return ''
    },
    clearAll() { this.selected = { l1: [], l2: [], l3: [] }; this.page = 1; this.loadIssues() },
    openDatePicker(e) {
      this.showDatePicker = !this.showDatePicker
      if (this.showDatePicker) {
        const r = e.currentTarget.getBoundingClientRect()
        this.popupStyleDate = { position: 'fixed', top: (r.bottom + 4) + 'px', left: r.left + 'px' }
      }
    },
    openCustomerPicker(e) {
      this.showCustomerFilter = !this.showCustomerFilter
      if (this.showCustomerFilter) {
        this.customerSearch = ''
        const r = e.currentTarget.getBoundingClientRect()
        this.popupStyleCustomer = { position: 'fixed', top: (r.bottom + 4) + 'px', left: r.left + 'px' }
      }
    },
    openUrgentFilter(e) {
      this.showUrgentFilter = !this.showUrgentFilter
      if (this.showUrgentFilter) {
        const r = e.currentTarget.getBoundingClientRect()
        this.popupStyleUrgent = { position: 'fixed', top: (r.bottom + 4) + 'px', left: r.left + 'px' }
      }
    },
    toggleUrgentFilter() {
      this.filterUrgentRecover = this.filterUrgentRecover === '是' ? '' : '是'
      this.page = 1
      this.loadIssues()
    },
    onUrgentFilter() { this.page = 1; this.showUrgentFilter = false; this.loadIssues() },
    openVersionPicker(e) {
      this.showVersionPicker = !this.showVersionPicker
      if (this.showVersionPicker) {
        this.versionSearch = ''
        const r = e.currentTarget.getBoundingClientRect()
        this.popupStyleVersion = { position: 'fixed', top: (r.bottom + 4) + 'px', left: r.left + 'px' }
      }
    },
    toggleDatePicker(e) {
      this.showDatePicker = !this.showDatePicker
      if (this.showDatePicker) {
        const rect = e.currentTarget.getBoundingClientRect()
        this.popupStyleDate = { top: (rect.bottom + 4) + 'px', left: rect.left + 'px' }
      }
    },
    onDateFilter() { this.page = 1; this.showDatePicker = false; this.loadIssues() },
    toggleCustomerPicker(e) {
      this.showCustomerFilter = !this.showCustomerFilter
      if (this.showCustomerFilter) { const r = e.currentTarget.getBoundingClientRect(); this.popupStyleCustomer = { top: (r.bottom + 4) + 'px', left: r.left + 'px' } }
    },
    toggleVersionPicker(e) {
      this.showVersionPicker = !this.showVersionPicker
      if (this.showVersionPicker) { const r = e.currentTarget.getBoundingClientRect(); this.popupStyleVersion = { top: (r.bottom + 4) + 'px', left: r.left + 'px' } }
    },
    onVersionFilter() { this.page = 1; this.showVersionPicker = false; this.loadIssues() },
    onCustomerFilter() { this.page = 1; this.showCustomerFilter = false; this.loadIssues() },
    toggleCustomerName(name) {
      const idx = this.filterCustomerName.indexOf(name)
      if (idx >= 0) {
        this.filterCustomerName.splice(idx, 1)
      } else {
        this.filterCustomerName.push(name)
      }
    },
    toggleKernelVersion(v) {
      const idx = this.filterKernelVersions.indexOf(v)
      if (idx >= 0) {
        this.filterKernelVersions.splice(idx, 1)
      } else {
        this.filterKernelVersions.push(v)
      }
    },
    async loadIssues() {
      try {
        const res = await fetchIssues(this.keyword, this.filterStatus, this.page, this.pageSize, this.filterDateStart, this.filterDateEnd, this.filterCustomerName.join(','), this.filterKernelVersions.join(','), this.filterUrgentRecover)
        const data = res.data
        this.issues = Array.isArray(data.list) ? data.list : (Array.isArray(data) ? data : [])
        this.total = data.total || 0
      } catch { this.issues = []; this.total = 0 }
      this.loadAllIssuesForCounts()
      this.loadAllIssuesFull()
      this.loadCustomerNameOptions()
    },
    async loadAllIssuesForCounts() {
      try {
        const res = await fetchIssues(this.keyword, this.filterStatus, 1, 100000, this.filterDateStart, this.filterDateEnd, this.filterCustomerName.join(','), this.filterKernelVersions.join(','), this.filterUrgentRecover)
        const data = res.data
        this.allIssuesFiltered = Array.isArray(data.list) ? data.list : (Array.isArray(data) ? data : [])
      } catch { this.allIssuesFiltered = [] }
    },
    async loadAllIssuesFull() {
      try {
        const res = await fetchIssues(this.keyword, this.filterStatus, 1, 100000, this.filterDateStart, this.filterDateEnd, this.filterCustomerName.join(','), '', this.filterUrgentRecover)
        const data = res.data
        this.allIssuesFull = Array.isArray(data.list) ? data.list : (Array.isArray(data) ? data : [])
      } catch { this.allIssuesFull = [] }
    },
    debounceSearch() {
      clearTimeout(this.searchTimer)
      this.page = 1
      this.searchTimer = setTimeout(() => this.loadIssues(), 300)
    },
    goPage(p) {
      this.page = p
      this.loadIssues()
    },
    onPageSizeChange() {
      this.page = 1
      this.loadIssues()
    },
    openImport() {
      this.showImport = true; this.importPreview = []; this.importError = ''; this.importSuccess = ''
    },
    pickFile() {
      this.$refs.importFileInput.click()
    },
    handleFile(e) {
      const file = e.target.files[0]
      if (file) this.parseFile(file)
      e.target.value = ''
    },
    parseFile(file) {
      this.importError = ''; this.importSuccess = ''; this.importPreview = []
      const ext = file.name.split('.').pop().toLowerCase()
      if (ext === 'xlsx' || ext === 'xls') {
        const reader = new FileReader()
        reader.onload = (ev) => {
          try {
            const wb = XLSX.read(ev.target.result, { type: 'array' })
            const ws = wb.Sheets[wb.SheetNames[0]]
            const json = XLSX.utils.sheet_to_json(ws, { header: 1 })
            if (json.length < 2) { this.importError = '文件内容为空'; return }
            const headers = json[0].map(h => String(h || '').trim())
            const isDateCol = (h) => /时间|日期|date|time/i.test(h)
            const data = json.slice(1).map(row => {
              const obj = {}
              headers.forEach((h, i) => {
                const cell = row[i]
                if (cell === undefined || cell === null) { obj[h] = '' }
                else if (typeof cell === 'number') {
                  obj[h] = isDateCol(h) ? this.excelToDate(cell) : String(cell)
                }
                else { obj[h] = String(cell).trim() }
              })
              return obj
            }).filter(d => Object.values(d).some(v => v))
            if (data.length === 0) { this.importError = '未解析到有效数据行'; return }
            this.importPreview = data
          } catch { this.importError = 'Excel 解析失败' }
        }
        reader.onerror = () => { this.importError = '文件读取失败' }
        reader.readAsArrayBuffer(file)
      } else {
        const reader = new FileReader()
        reader.onload = (ev) => {
          try {
            const text = ev.target.result
            const lines = text.split(/\r?\n/).filter(l => l.trim())
            if (lines.length < 2) { this.importError = '文件内容为空或格式不正确（需包含表头行和数据行）'; return }
            const headers = lines[0].split(',').map(h => h.trim().replace(/^"(.*)"$/, '$1'))
            const data = lines.slice(1).map(line => {
              const cols = line.split(',').map(c => c.trim().replace(/^"(.*)"$/, '$1'))
              const obj = {}
              headers.forEach((h, i) => { obj[h] = cols[i] || '' })
              return obj
            }).filter(d => Object.values(d).some(v => v))
            if (data.length === 0) { this.importError = '未解析到有效数据行'; return }
            this.importPreview = data
          } catch { this.importError = '文件解析失败，请检查格式' }
        }
        reader.onerror = () => { this.importError = '文件读取失败' }
        reader.readAsText(file, 'UTF-8')
      }
    },
    getField(row, ...keys) {
      for (const k of keys) { if (row[k] !== undefined && row[k] !== '') return row[k] }
      return ''
    },
    excelToDate(serial) {
      if (typeof serial === 'string') return serial
      if (typeof serial !== 'number') return ''
      const utcMs = Math.round((serial - 25569) * 86400 * 1000)
      const d = new Date(utcMs)
      if (isNaN(d.getTime())) return ''
      const pad = n => String(n).padStart(2, '0')
      const datePart = d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
      if (serial % 1 === 0) return datePart
      return datePart + 'T' + pad(d.getHours()) + ':' + pad(d.getMinutes())
    },
    toDateTime(val) {
      if (!val && val !== 0) return ''
      if (typeof val === 'number') return this.excelToDate(val)
      let s = String(val).trim()
      if (/^\d{5}$/.test(s)) { const n = parseInt(s); if (n > 30000 && n < 80000) return this.excelToDate(n) }
      s = s.replace(/\//g, '-').replace(/\s+/g, 'T')
      if (s.length === 10 && s.includes('-')) s += 'T00:00'
      if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(s)) return s
      if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/.test(s)) return s.substring(0, 16)
      return s
    },
    toBool(val) {
      const s = String(val || '').trim()
      return s === '是' || s === '有' || s === 'yes' || s === 'true' || s === '1'
    },
    async doImport() {
      this.importError = ''; this.importSuccess = ''; this.importing = true
      let count = 0
      for (const row of this.importPreview) {
        try {
          const payload = {
            occurTime: this.toDateTime(this.getField(row, '问题发生时间', 'occurTime')),
            handleDate: this.getField(row, '日期', 'handleDate') || new Date().toISOString().slice(0, 10),
            customerName: this.getField(row, '客户名称', 'customerName'),
            description: this.getField(row, '问题简述', 'description'),
            kernelVersion: this.getField(row, '内核版本', 'kernelVersion'),
            mgmtDeploy: this.getField(row, '管控部署形态', 'mgmtDeploy'),
            kernelDeploy: this.getField(row, '内核部署形态', 'kernelDeploy'),
            rl: this.getField(row, 'RL', 'rl'),
            perceiveTime: this.toDateTime(this.getField(row, '一线感知时间', 'perceiveTime')),
            createTime: this.toDateTime(this.getField(row, '问题建单时间', 'createTime')),
            swatStartTime: this.toDateTime(this.getField(row, 'SWAT开始处理时间', 'swatStartTime')),
            boundTime: this.toDateTime(this.getField(row, '问题定界时间', 'boundTime')),
            bizRecoverTime: this.toDateTime(this.getField(row, '业务恢复时间', 'bizRecoverTime')),
            hasAlarm: this.toBool(this.getField(row, '有无告警', 'hasAlarm')),
            alarmTrigger: this.toBool(this.getField(row, '告警触发', 'alarmTrigger')),
            opsTicket: this.getField(row, '运维单号', 'opsTicket'),
            ecareTicket: this.getField(row, 'ecare单号', 'ecareTicket'),
            docLink: this.getField(row, '文档链接', 'docLink'),
            screenLink: this.getField(row, '录屏链接', 'screenLink'),
            bizInterrupt: this.toBool(this.getField(row, '业务中断', 'bizInterrupt')),
            urgentRecover: this.toBool(this.getField(row, '紧急恢复', 'urgentRecover'))
          }
          // Build category from three-level fields
          const catParts = []
          const l1 = this.getField(row, '一级分类')
          const l2 = this.getField(row, '二级分类')
          const l3 = this.getField(row, '三级分类')
          if (l1) catParts.push(l1)
          if (l2) catParts.push(l2)
          if (l3) catParts.push(l3)
          if (catParts.length) payload.category = catParts.join(' > ')
          if (!payload.customerName || !payload.description) continue
          const res = await createIssue(payload)
          if (res.data && res.data.success) count++
        } catch {}
      }
      if (count > 0) {
        this.importSuccess = `成功导入 ${count} 条数据`
        setTimeout(() => { this.showImport = false; this.loadIssues() }, 1000)
      } else {
        this.importError = '导入失败，请检查文件格式（至少需要客户名称和问题简述）'
      }
      this.importing = false
    },
    openAdd() {
      this.editing = false; this.editId = null; this.errorMsg = ''
      this.form = { occurTime: '', handleDate: '', customerName: '', description: '', category: '', kernelVersion: '', status: '待处理',
        mgmtDeploy: '', kernelDeploy: '', rl: '', hasAlarm: '', alarmTrigger: '',
        bizInterrupt: '', urgentRecover: '',
        perceiveTime: '', createTime: '', swatStartTime: '', boundTime: '', bizRecoverTime: '',
        catL1: '', catL2: '', catL3: '' }
      this.showModal = true
    },
    editIssue(item) {
      this.editing = true; this.editId = item.id; this.errorMsg = ''
      this.form = {
        occurTime: item.occurTime || '', customerName: item.customerName || '',
        description: item.description || '', category: item.category || '',
        kernelVersion: item.kernelVersion || '', status: item.status || '待处理'
      }
      this.showModal = true
    },
    formatDate(val) {
      if (!val) return '-'
      return val.substring(0, 10)
    },
    calcMinDisplay(from, to) {
      if (!from || !to) return '-'
      const diff = new Date(to) - new Date(from)
      if (isNaN(diff) || diff < 0) return '-'
      return Math.round(diff / 60000) + ' min'
    },
    async saveIssue() {
      this.errorMsg = ''
      const requireds = [
        { key: 'handleDate', label: '日期' },
        { key: 'customerName', label: '客户名称' },
        { key: 'mgmtDeploy', label: '管控部署形态' },
        { key: 'kernelVersion', label: '内核版本' },
        { key: 'kernelDeploy', label: '内核部署形态' },
        { key: 'rl', label: 'RL' },
        { key: 'hasAlarm', label: '有无告警' },
        { key: 'alarmTrigger', label: '告警触发' },
        { key: 'bizInterrupt', label: '业务中断' },
        { key: 'urgentRecover', label: '紧急恢复' }
      ]
      if (this.form.urgentRecover === 'yes') {
        requireds.push(
          { key: 'occurTime', label: '问题发生时间' },
          { key: 'perceiveTime', label: '一线感知时间' },
          { key: 'createTime', label: '问题建单时间' },
          { key: 'swatStartTime', label: 'SWAT开始处理时间' },
          { key: 'boundTime', label: '问题定界时间' },
          { key: 'bizRecoverTime', label: '业务恢复时间' }
        )
      }
      for (const r of requireds) {
        if (!this.form[r.key]) { this.errorMsg = r.label + '不能为空'; return }
      }
      // Build category from cascading selects
      const parts = []
      if (this.form.catL1) parts.push(this.form.catL1.split(':')[1])
      if (this.form.catL2) parts.push(this.form.catL2.split(':')[1])
      if (this.form.catL3) parts.push(this.form.catL3.split(':')[1])
      if (parts.length) this.form.category = parts.join(' > ')
      this.saving = true
      try {
        const payload = { ...this.form }
        payload.hasAlarm = this.form.hasAlarm === 'yes'
        payload.alarmTrigger = this.form.alarmTrigger === 'yes'
        payload.bizInterrupt = this.form.bizInterrupt === 'yes'
        payload.urgentRecover = this.form.urgentRecover === 'yes'
        const res = this.editing ? await updateIssue(this.editId, payload) : await createIssue(payload)
        if (res.data.success) { this.showModal = false; this.loadIssues() }
        else { this.errorMsg = res.data.message }
      } catch { this.errorMsg = '网络错误，请稍后重试' }
      finally { this.saving = false }
    },
    async deleteIssue(item) {
      try {
        await ElMessageBox.confirm(
          `确定删除问题「${item.issueNo}」吗？`,
          '删除确认',
          { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
        )
        const res = await deleteIssue(item.id)
        if (res.data.success) {
          this.loadIssues()
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
.issues-layout {
  display: flex;
  gap: 20px;
  height: calc(100vh - 56px - 48px);
}

/* ======== Category Sidebar ======== */
.category-sidebar {
  width: 248px;
  background: #fafbfc;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  min-height: 0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.category-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f0f0f0;
  border-radius: 8px 8px 0 0;
}

.category-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.btn-clear {
  padding: 2px 10px;
  border: none;
  background: #f0f0f0;
  color: #999;
  border-radius: 3px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-clear:hover { background: #ff4d4f; color: #fff; }

.cat-empty {
  padding: 40px 20px;
  text-align: center;
  color: #bbb;
}
.cat-empty-icon { font-size: 32px; margin-bottom: 8px; }
.cat-empty p { font-size: 13px; margin-bottom: 16px; }
.cat-empty-link {
  display: inline-block;
  padding: 6px 16px;
  background: #1890ff;
  color: #fff;
  border-radius: 4px;
  font-size: 13px;
  text-decoration: none;
}
.cat-empty-link:hover { opacity: 0.85; }

.category-tree {
  flex: 1;
  overflow-y: auto;
  padding: 4px 0;
  min-height: 0;
}

/* ---- Level 1 ---- */
.cat-l1-group { border-bottom: 1px solid #f5f5f5; }
.cat-l1-group:first-child { border-top: none; }
.cat-l1-group:last-child { border-bottom: none; }

.cat-l1 {
  display: flex;
  align-items: center;
  padding: 8px 10px 8px 12px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  color: #333;
  transition: background 0.15s;
}
.cat-l1:hover { background: #fff; }
.cat-l1 .cat-icon { width: 14px; font-size: 10px; color: #bbb; flex-shrink: 0; margin-right: 4px; }
.cat-l1 .cat-name { flex: 1; }
.cat-l1 .cat-count { font-size: 11px; color: #bbb; font-weight: 400; margin-left: auto; padding: 1px 6px; border-radius: 10px; background: #f0f0f0; }

/* ---- Level 2 ---- */
.cat-l2-list { background: #f5f6f8; }

.cat-l2 {
  display: flex;
  align-items: center;
  padding: 6px 10px 6px 28px;
  cursor: pointer;
  font-size: 13px;
  color: #555;
  transition: background 0.15s;
}
.cat-l2:hover { background: #eeeff2; }
.cat-l2 .cat-icon { width: 14px; font-size: 10px; color: #bbb; flex-shrink: 0; margin-right: 4px; }
.cat-l2 .cat-name { flex: 1; }
.cat-l2 .cat-count { font-size: 11px; color: #bbb; font-weight: 400; margin-left: auto; padding: 1px 6px; border-radius: 10px; background: #e8e8e8; }

/* ---- Level 3 ---- */
.cat-l3-list { background: #f0f1f4; padding: 2px 0; }

.cat-l3 {
  display: flex;
  align-items: center;
  padding: 4px 10px 4px 56px;
  font-size: 12px;
  color: #777;
  cursor: default;
  transition: background 0.15s;
}
.cat-l3:hover { background: #eaebef; }
.cat-l3 .cat-name { flex: 1; }
.cat-l3 .cat-count.dim { font-size: 11px; color: #ccc; margin-left: auto; }

/* ---- Custom Checkbox ---- */
.cat-check {
  width: 16px; height: 16px;
  border: 2px solid #d9d9d9;
  border-radius: 3px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  cursor: pointer;
  transition: all 0.15s;
  margin-right: 8px;
}
.cat-check.sm { width: 14px; height: 14px; border-radius: 3px; }
.cat-check.xs { width: 12px; height: 12px; border-radius: 2px; margin-right: 8px; }
.cat-check:hover { border-color: #1890ff; }

.cat-l1 .cat-check.checked { background: #1890ff; border-color: #1890ff; }
.cat-l2 .cat-check.checked { background: #5b8def; border-color: #5b8def; }
.cat-l3 .cat-check.checked { background: #8cb8f0; border-color: #8cb8f0; }

.cat-check.partial { background: #fff; border-color: #1890ff; }
.cat-l2 .cat-check.partial { border-color: #5b8def; }

.check-icon { font-size: 11px; color: #fff; line-height: 1; }

.partial-bar {
  display: block;
  width: 8px;
  height: 2px;
  background: #1890ff;
  border-radius: 1px;
}
.cat-l2 .partial-bar { width: 7px; background: #5b8def; }
.cat-l3 .partial-bar { width: 6px; }

/* ---- Color dot on L1 ---- */
.cat-l1.blue { border-left: 3px solid transparent; }
.cat-l1.blue:hover { border-left-color: #1890ff; }
.cat-l1.blue .cat-check.checked ~ .cat-name { color: #1890ff; }

.cat-l1.orange { border-left: 3px solid transparent; }
.cat-l1.orange:hover { border-left-color: #fa8c16; }
.cat-l1.orange .cat-check.checked ~ .cat-name { color: #fa8c16; }

.cat-l1.red { border-left: 3px solid transparent; }
.cat-l1.red:hover { border-left-color: #ff4d4f; }
.cat-l1.red .cat-check.checked ~ .cat-name { color: #ff4d4f; }

.cat-l1.purple { border-left: 3px solid transparent; }
.cat-l1.purple:hover { border-left-color: #722ed1; }
.cat-l1.purple .cat-check.checked ~ .cat-name { color: #722ed1; }

.cat-l1.green { border-left: 3px solid transparent; }
.cat-l1.green:hover { border-left-color: #52c41a; }
.cat-l1.green .cat-check.checked ~ .cat-name { color: #52c41a; }

/* ---- Footer ---- */
.category-footer {
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
  font-size: 12px;
  color: #bbb;
  text-align: center;
  border-radius: 0 0 8px 8px;
}
.footer-selected em { color: #1890ff; font-style: normal; font-weight: 600; }

/* ======== Right Content ======== */
.issue-content {
  flex: 1; padding: 0; min-width: 0;
  display: flex; flex-direction: column;
  overflow-y: auto;
}

.panel-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
}
.panel-header h3 { font-size: 16px; color: #333; }

.btn-add {
  padding: 8px 16px; background: #1890ff; color: #fff;
  border: none; border-radius: 4px; font-size: 13px; cursor: pointer;
}
.btn-add:hover { opacity: 0.85; }

.panel {
  background: #fff; border-radius: 8px; padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 16px; }

.search-input {
  padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px;
  font-size: 13px; width: 260px; outline: none;
}
.search-input:focus { border-color: #1890ff; }

.filter-select {
  padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px;
  font-size: 13px; outline: none; background: #fff;
}

.result-count { font-size: 13px; color: #999; margin-left: auto; }

/* ---- Column Resize & Gear ---- */
.gear-btn-wrap { position: relative; margin-left: auto; }
.gear-btn {
  width: 32px; height: 32px; border: 1px solid #d9d9d9; background: #fff;
  border-radius: 4px; font-size: 16px; color: #888; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
}
.gear-btn:hover { border-color: #1890ff; color: #1890ff; }
.table { table-layout: fixed; width: auto; min-width: 100%; }
.table td { border-bottom: 1px solid #f0f0f0; }

.resizable { position: relative; }
.resize-handle {
  position: absolute; right: -4px; top: 0; bottom: 0; width: 8px;
  cursor: col-resize; z-index: 1;
}
.resize-handle::after {
  content: ''; position: absolute; left: 3px; top: 20%; bottom: 20%;
  width: 1px; background: #e0e0e0;
}

.column-picker {
  position: absolute; right: 0; top: calc(100% + 4px); z-index: 30;
  background: #fff; border: 1px solid #e8e8e8; border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12); min-width: 150px;
  display: flex; flex-direction: column;
}
.picker-scroll { max-height: 340px; overflow-y: auto; scrollbar-width: none; -ms-overflow-style: none; padding: 8px 0 0; }
.picker-scroll::-webkit-scrollbar { display: none; }
.picker-footer { padding: 0 0 8px; }
.picker-item {
  display: flex; align-items: center; gap: 8px; padding: 8px 16px;
  font-size: 13px; color: #333; cursor: pointer; white-space: nowrap;
}
.picker-item:hover { background: #f5f5f5; }
.picker-check { width: 16px; text-align: center; color: #1890ff; font-weight: 600; }
.picker-divider { height: 1px; background: #f0f0f0; margin: 4px 0; }
.picker-reset { color: #999; justify-content: center; }
.picker-reset:hover { color: #1890ff; }

.status-tag { padding: 2px 8px; border-radius: 3px; font-size: 12px; }
.s-待处理 { background: #fff7e6; color: #fa8c16; }
.s-处理中 { background: #e6f7ff; color: #1890ff; }
.s-已解决 { background: #f6ffed; color: #52c41a; }
.s-已关闭 { background: #f5f5f5; color: #999; }

/* ---- Pagination ---- */
.pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
  margin-top: 16px;
}

.page-left {
  flex-shrink: 0;
}

.page-size-select {
  padding: 6px 8px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  font-size: 13px;
  outline: none;
  background: #fff;
  color: #555;
  cursor: pointer;
}

.page-size-select:focus { border-color: #1890ff; }

.page-center {
  display: flex;
  align-items: center;
  gap: 4px;
}

.page-btn {
  min-width: 36px;
  height: 32px;
  padding: 0 10px;
  border: 1px solid #d9d9d9;
  background: #fff;
  color: #555;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.15s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  white-space: nowrap;
}

.page-btn:hover:not(:disabled) {
  border-color: #1890ff;
  color: #1890ff;
}

.page-btn.active {
  background: #1890ff;
  border-color: #1890ff;
  color: #fff;
  font-weight: 600;
}

.page-btn:disabled {
  color: #d9d9d9;
  cursor: not-allowed;
}

.page-info {
  flex-shrink: 0;
  font-size: 13px;
  color: #999;
  margin-left: 16px;
}

.table-wrapper { overflow: auto; max-height: calc(100vh - 280px); }
.panel { overflow: visible; }
.table thead { overflow: visible; position: sticky; top: 0; z-index: 4; }
.table thead th { background: #fafafa; }
.table thead th { overflow: visible; position: relative; }
.th-filter { position: relative; z-index: 1; }
.th-filter:has(.date-picker-popup),
.th-filter:has(.customer-filter-popup),
.th-filter:has(.version-picker-popup) { z-index: 60; }
.table-wrapper::-webkit-scrollbar { height: 6px; }
.table-wrapper::-webkit-scrollbar-thumb { background: #d9d9d9; border-radius: 3px; }
.table-wrapper::-webkit-scrollbar-thumb:hover { background: #bbb; }
.table-wrapper::-webkit-scrollbar-track { background: transparent; }
.table { width: 100%; min-width: 800px; border-collapse: collapse; }
.table th, .table td { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.sticky-left {
  position: sticky; z-index: 1; background: #fff;
}
.table thead th.sticky-left {
  position: sticky; background: #fafafa; z-index: 5;
}

.sticky-col {
  position: sticky; right: 0; z-index: 1;
  background: #fff; width: 130px; min-width: 130px; max-width: 130px;
  white-space: nowrap;
}
.sticky-col .btn-action { white-space: nowrap; flex-shrink: 0; }
.table thead .sticky-col {
  background: #fafafa; z-index: 5;
}
.table tbody .sticky-col::before {
  content: ''; position: absolute; left: 0; top: 0; bottom: 0;
  width: 6px; background: linear-gradient(to right, rgba(0,0,0,0.05), transparent);
  transform: translateX(-100%);
}
.table th, .table td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #f0f0f0; }
.table th { background: #fafafa; color: #666; font-weight: 500; font-size: 13px; }
.table td { font-size: 14px; color: #333; }

.desc-cell { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

code {
  background: #f5f5f5; padding: 2px 8px; border-radius: 3px;
  font-size: 12px; color: #d4380d;
}

.cat-badge {
  display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 12px;
  background: #f0f5ff; color: #597ef7;
}
.badge-blue { background: #f0f5ff; color: #597ef7; }
.badge-orange { background: #fff7e6; color: #d87a16; }
.badge-red { background: #fff1f0; color: #cf1322; }
.badge-purple { background: #f9f0ff; color: #722ed1; }
.badge-green { background: #f6ffed; color: #389e0d; }

.btn-action {
  padding: 4px 10px; border: 1px solid #d9d9d9; background: #fff;
  color: #1890ff; border-radius: 4px; font-size: 12px; cursor: pointer; margin-right: 6px;
}
.btn-action:hover { border-color: #1890ff; }
.btn-action.danger { color: #ff4d4f; }
.btn-action.danger:hover { border-color: #ff4d4f; }

.empty { text-align: center; padding: 48px; color: #bbb; font-size: 14px; }
.empty-icon { font-size: 36px; margin-bottom: 8px; }

/* ======== Modal (unchanged) ======== */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4);
  display: flex; align-items: flex-start; justify-content: center;
  padding: 6vh 20px 20px; overflow-y: auto; z-index: 100;
}
.modal {
  background: #fff; border-radius: 8px; padding: 24px; width: 680px;
  max-height: 90vh; overflow-y: auto; box-shadow: 0 6px 30px rgba(0,0,0,0.2);
}
.modal h3 { margin-bottom: 16px; font-size: 16px; }
.form-group { margin-bottom: 14px; }
.form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 4px; }
.required { color: #ff4d4f; }
.form-group input, .form-group select, .form-group textarea {
  width: 100%; padding: 8px 12px; border: 1px solid #d9d9d9;
  border-radius: 4px; font-size: 14px; outline: none; font-family: inherit;
}
.form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #1890ff; }
.field-input, .field-select { width: 100%; padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 14px; outline: none; box-sizing: border-box; background: #fff; }
.field-input:focus, .field-select:focus { border-color: #1890ff; }
.cascade-selects { display: flex; gap: 6px; }
.cascade-selects .field-select { flex: 1; min-width: 0; }
.cascade-selects .field-select:disabled { background: #f5f5f5; color: #ccc; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

/* ---- Searchable Select ---- */
.searchable-select { position: relative; }
.select-input {
  width: 100%; padding: 8px 28px 8px 12px; border: 1px solid #d9d9d9;
  border-radius: 4px; font-size: 14px; cursor: pointer; background: #fff;
  position: relative; min-height: 38px; display: flex; align-items: center;
}
.select-input:focus, .select-input:focus-within { border-color: #1890ff; }
.select-input .arrow { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); font-size: 12px; color: #999; }
.select-input .placeholder { color: #bfbfbf; }
.select-input .selected-text { color: #333; }

.select-dropdown {
  position: absolute; top: 100%; left: 0; right: 0; z-index: 20;
  background: #fff; border: 1px solid #d9d9d9; border-top: none;
  border-radius: 0 0 4px 4px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  overflow: hidden; padding: 8px 8px 0;
}
.dropdown-search {
  display: block; width: 100%; padding: 6px 10px;
  border: 1px solid #e8e8e8; border-radius: 4px; font-size: 13px; outline: none;
  box-sizing: border-box;
}
.dropdown-search:focus { border-color: #1890ff; }
.dropdown-list { max-height: 180px; overflow-y: auto; }
.dropdown-option {
  padding: 8px 12px; font-size: 14px; color: #333; cursor: pointer;
}
.dropdown-option:hover { background: #f5f5f5; }
.dropdown-option.active { color: #1890ff; background: #e6f7ff; font-weight: 500; }
.dropdown-empty { padding: 12px; text-align: center; color: #bbb; font-size: 13px; }
.msg-error {
  color: #ff4d4f; font-size: 13px; background: #fff1f0;
  padding: 8px 12px; border-radius: 4px; margin-bottom: 12px;
}
.form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }
.btn-submit {
  padding: 8px 20px; background: #1890ff; color: #fff;
  border: none; border-radius: 4px; cursor: pointer; font-size: 14px;
}
.btn-submit:hover { opacity: 0.85; }
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-cancel {
  padding: 8px 20px; border: 1px solid #d9d9d9; background: #fff;
  color: #666; border-radius: 4px; cursor: pointer; font-size: 14px;
}

.header-btns { display: flex; gap: 10px; }
.btn-urgent { padding: 8px 16px; background: #fff; color: #fa8c16; border: 1px solid #fa8c16; border-radius: 4px; font-size: 13px; cursor: pointer; transition: all 0.2s; }
.btn-urgent:hover { background: #fff7e6; }
.btn-urgent.active { background: #fa8c16; color: #fff; border-color: #fa8c16; }
.btn-import { padding: 8px 16px; background: #fff; color: #1890ff; border: 1px solid #1890ff; border-radius: 4px; font-size: 13px; cursor: pointer; }
.btn-import:hover { background: #e6f7ff; }

.import-file-input { display: none; }
.import-area { margin-bottom: 16px; cursor: pointer; }
.import-upload { display: block; border: 2px dashed #d9d9d9; border-radius: 8px; padding: 48px 20px; text-align: center; transition: all 0.2s; }
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
.msg-success { color: #52c41a; font-size: 13px; background: #f6ffed; padding: 8px 12px; border-radius: 4px; margin-bottom: 12px; }
.th-filter { display: flex; align-items: center; gap: 4px; position: relative; }
.filter-icon { cursor: pointer; color: #bbb; transition: color 0.15s; margin-left: auto; display: flex; align-items: center; }
.filter-icon:hover { color: #666; }
.filter-icon.active { color: #1890ff; }
.filter-popup-overlay { position: fixed; inset: 0; z-index: 98; }
.date-picker-popup { position: fixed !important; z-index: 99; background: #fff; border: 1px solid #e8e8e8; border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); padding: 8px; display: flex; gap: 6px; align-items: center; white-space: nowrap; }
.customer-filter-popup, .version-picker-popup { position: fixed !important; z-index: 99; background: #fff; border: 1px solid #e8e8e8; border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); padding: 8px; min-width: 180px; max-height: 300px; overflow-y: auto; }
.filter-popup-search { display: block; width: calc(100% - 24px); margin: 8px 12px; padding: 7px 10px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 13px; outline: none; box-sizing: border-box; }
.filter-popup-search:focus { border-color: #1890ff; }
.filter-popup-divider { height: 1px; background: #f0f0f0; margin: 0 4px 4px; }
.popup-date { padding: 4px 8px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 13px; outline: none; }
.date-sep { font-size: 12px; color: #999; }
.popup-confirm { padding: 4px 10px; border: none; background: #1890ff; color: #fff; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap; }
.popup-confirm:hover { opacity: 0.85; }
.popup-clear { padding: 4px 10px; border: 1px solid #d9d9d9; background: #fff; color: #999; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap; }
.popup-clear:hover { border-color: #ff4d4f; color: #ff4d4f; }
.version-picker-popup { position: absolute; top: 100%; left: 0; z-index: 200; background: #fff; border: 1px solid #e8e8e8; border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); padding: 4px 0; min-width: 180px; }
.popup-select { padding: 6px 8px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 13px; outline: none; min-width: 160px; background: #fff; }
.customer-filter-popup { position: absolute; top: 100%; left: 0; z-index: 200; background: #fff; border: 1px solid #e8e8e8; border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); padding: 4px 0; min-width: 180px; }
.filter-checkbox-list { max-height: 220px; overflow-y: auto; padding: 4px 8px; }
.filter-checkbox-item { display: flex; align-items: center; gap: 8px; padding: 6px 8px; cursor: pointer; border-radius: 4px; font-size: 13px; color: #333; }
.filter-checkbox-item:hover { background: #f5f5f5; }
.filter-checkbox { width: 15px; height: 15px; border: 2px solid #d9d9d9; border-radius: 3px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; transition: all 0.15s; }
.filter-checkbox.checked { background: #1890ff; border-color: #1890ff; }
.filter-checkbox .check-icon { font-size: 10px; color: #fff; line-height: 1; }
.filter-checkbox-label { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.filter-popup-actions { display: flex; gap: 6px; padding: 8px 10px 4px; border-top: 1px solid #f0f0f0; }
.filter-empty { padding: 16px; text-align: center; color: #bbb; font-size: 13px; }
.popup-select:focus { border-color: #1890ff; }
</style>
