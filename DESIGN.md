# SWAT 问题管理系统 — 设计文档

## 一、系统概述

SWAT 问题管理系统是一个面向 IT 运维场景的全栈 Web 应用，用于管理问题（Issue）的全生命周期，包括问题登记、分类、时间追踪、局点/版本关联、应急预案等。采用前后端分离架构。

| 层级 | 技术栈 |
|------|--------|
| 前端 | Vue 3 + Vue Router + Element Plus + Axios + Vite |
| 后端 | Spring Boot 2.7 + MyBatis + BCrypt |
| 数据库 | PostgreSQL |

---

## 二、系统架构

```
Browser (Vue SPA)
    │  Axios (REST JSON)
    ▼
Vite Dev Server (:3002)
    │  proxy /api → :45123
    ▼
Spring Boot (:45123)
    │  MyBatis
    ▼
PostgreSQL (:5432 / swat)
```

---

## 三、数据库设计

### 3.1 数据库概览

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `users` | 系统用户 | username (UNIQUE), password (BCrypt), email |
| `sites` | 局点 | code, name (UNIQUE), region, version_ids (JSON) |
| `versions` | 版本 | version_code (UNIQUE), sites (JSON), status |
| `issues` | 问题 | issue_no (UNIQUE), occur_time, handle_date, 30+ 业务字段 |
| `issue_categories` | 问题分类 | name, parent_id (自引用), level (1/2/3), color |
| `rls` | RL（处理人） | name (UNIQUE) |

### 3.2 核心表结构

#### issues 表（30+ 字段）

```
┌────────────────────────────────────────────────────────┐
│ issues                                                  │
├─────────────────┬──────────────────────────────────────┤
│ 基础信息         │ issue_no, occur_time, handle_date,    │
│                 │ customer_name, category,              │
│                 │ key_site, site_type, mgmt_deploy,     │
│                 │ kernel_version, kernel_deploy, rl,    │
│                 │ ops_ticket, ecare_ticket, description │
├─────────────────┼──────────────────────────────────────┤
│ 快速属性         │ biz_interrupt, urgent_recover, remark │
├─────────────────┼──────────────────────────────────────┤
│ 发现问题         │ has_alarm, alarm_trigger, find_remark│
├─────────────────┼──────────────────────────────────────┤
│ 关键时间         │ perceive_time, create_time,           │
│                 │ swat_start_time, bound_time,          │
│                 │ biz_recover_time, full_recover_time,  │
│                 │ time_remark                           │
├─────────────────┼──────────────────────────────────────┤
│ 问题归档         │ doc_link, screen_link                 │
├─────────────────┼──────────────────────────────────────┤
│ 应急预案         │ had_plan, has_plan, plan_name         │
├─────────────────┼──────────────────────────────────────┤
│ 审计             │ created_at, updated_at               │
└─────────────────┴──────────────────────────────────────┘
```

#### issue_categories 表（自引用树形结构）

```
id | name | parent_id | level | color | sort_order
───┼──────┼───────────┼───────┼───────┼───────────
 1 | 功能问题 | NULL | 1 | blue | 0
 6 | 内核模块 | 1    | 2 | blue | 0
19 | 缺陷    | 6    | 3 | blue | 0
```

### 3.3 关联设计

- **局点 ↔ 版本**：双向 JSON 数组同步。`sites.version_ids` ↔ `versions.sites`，通过 SiteService 的 `syncVersionSites()` 维护一致性。
- **版本 → 局点**：前端显示时通过 `resolveSiteNames()` 从 ID 解析名称。
- **客户名称**：映射局点管理中的局点名称，通过下拉框选择。
- **内核版本**：映射版本管理中的版本号，通过下拉框选择。
- **问题分类**：映射分类管理中的三级分类树，前端级联选择。
- **RL**：映射 RL 管理中的处理人名称。

---

## 四、后端设计

### 4.1 项目结构

```
backend/
├── pom.xml                          # Spring Boot 2.7, MyBatis, PostgreSQL, BCrypt
├── sql/                             # 建表脚本
└── src/main/
    ├── java/com/swat/
    │   ├── SwatApplication.java     # 启动类
    │   ├── config/CorsConfig.java   # CORS 跨域
    │   ├── controller/              # REST 控制器
    │   │   ├── UserController.java        # /api/user
    │   │   ├── SiteController.java        # /api/sites
    │   │   ├── VersionController.java     # /api/versions
    │   │   ├── IssueController.java       # /api/issues
    │   │   ├── IssueCategoryController.java # /api/issue-categories
    │   │   └── RlController.java          # /api/rls
    │   ├── service/                 # 业务逻辑层
    │   ├── mapper/                  # MyBatis Mapper 接口
    │   └── model/                   # 实体类（含 getter/setter）
    └── resources/
        ├── application.yml          # 数据库连接、端口配置
        └── mapper/                  # MyBatis XML 映射文件
```

### 4.2 API 端点一览

#### 用户 (User)
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/user/login` | 登录（BCrypt 验证） |
| POST | `/api/user/register` | 注册 |

#### 局点 (Site)
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/sites?keyword=` | 列表查询 |
| GET | `/api/sites/{id}` | 单个查询 |
| POST | `/api/sites` | 新增（名称唯一性校验） |
| PUT | `/api/sites/{id}` | 编辑（名称不可改） |
| DELETE | `/api/sites/{id}` | 删除 |
| GET | `/api/sites/check-name?name=` | 名称唯一性预检 |

#### 版本 (Version)
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/versions` | 列表查询 |
| GET | `/api/versions/{id}` | 单个查询 |
| POST | `/api/versions` | 新增（版本号唯一性校验） |
| PUT | `/api/versions/{id}` | 编辑（不更新 sites） |
| DELETE | `/api/versions/{id}` | 删除（检查局点引用） |
| GET | `/api/versions/check-code?code=` | 版本号唯一性预检 |

#### 问题 (Issue)
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/issues?keyword=&status=&page=&pageSize=` | 分页列表 |
| GET | `/api/issues/{id}` | 单个查询（含全部字段） |
| POST | `/api/issues` | 新增（自动生成编号） |
| PUT | `/api/issues/{id}` | 编辑（合并更新，只写非 null 字段） |
| DELETE | `/api/issues/{id}` | 删除 |

#### 问题分类 (IssueCategory)
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/issue-categories/tree` | 树形结构 |
| GET | `/api/issue-categories` | 平铺列表 |
| GET | `/api/issue-categories/{id}` | 单个查询 |
| POST | `/api/issue-categories` | 新增（自动计算 level） |
| PUT | `/api/issue-categories/{id}` | 编辑 |
| DELETE | `/api/issue-categories/{id}` | 删除（级联删除子分类） |

#### RL (Rl)
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/rls` | 列表查询 |
| POST | `/api/rls` | 新增 |
| PUT | `/api/rls/{id}` | 编辑 |
| DELETE | `/api/rls/{id}` | 删除 |

### 4.3 关键业务逻辑

**问题编号自动生成**（IssueService.create）：
```
格式：SWAT-YYYYMMDD-NNN
逻辑：
  1. 取 occurTime（为空则用 handleDate），提取 YYYYMMDD
  2. countByDate 查当天已有问题数
  3. 编号 = SWAT-日期-序号（序号 = 计数+1，零填充 3 位）
  4. 插入；若 DuplicateKeyException 则序号+1 重试（最多 5 次）
```

**合并更新**（IssueService.update）：
```
只覆盖前端传来的非 null 字段，其他字段保留原值。
支持分部保存：基础信息/快速属性/发现问题/关键时间/问题归档/应急预案各自独立保存。
```

**局点-版本双向同步**（SiteService.syncVersionSites）：
```
创建/编辑局点时：
  - 解析旧 versionIds 和新 versionIds
  - 新增的版本 → addSiteToVersion
  - 移除的版本 → removeSiteFromVersion
删除局点时 → 从所有关联版本中移除该局点 ID
```

---

## 五、前端设计

### 5.1 项目结构

```
frontend/
├── index.html
├── package.json            # Vue 3, Element Plus, Axios, Vue Router
├── vite.config.js          # 代理 /api → :45123
└── src/
    ├── main.js             # Element Plus 全局注册
    ├── App.vue             # 根组件
    ├── api/index.js         # Axios 封装 + 全部 API 函数
    ├── router/index.js      # 路由配置
    └── views/
        ├── Login.vue                 # 登录/注册页
        ├── Home.vue                  # 布局壳（侧边栏+顶栏+内容区）
        ├── Dashboard.vue            # 首页概览
        ├── Issues.vue               # 问题列表（核心页）
        ├── IssueDetail.vue           # 问题详情/编辑（6 大模块）
        ├── CreateIssue.vue          # 创建问题（已废弃，合并到 Issues.vue）
        ├── SiteManagement.vue       # 局点管理
        ├── VersionManagement.vue    # 版本管理
        ├── CategoryManagement.vue   # 分类管理
        ├── RlManagement.vue         # RL管理
        ├── Statistics.vue           # 问题统计
        └── UserManagement.vue       # 用户管理
```

### 5.2 路由表

| 路径 | 组件 | 说明 |
|------|------|------|
| `/` | Login | 登录 |
| `/home/dashboard` | Dashboard | 首页概览 |
| `/home/issues` | Issues | 问题列表 |
| `/home/issues/:id` | IssueDetail | 问题详情/编辑 |
| `/home/create` | CreateIssue | （废弃） |
| `/home/statistics` | Statistics | 问题统计 |
| `/home/users` | UserManagement | 用户管理 |
| `/home/sites` | SiteManagement | 局点管理 |
| `/home/versions` | VersionManagement | 版本管理 |
| `/home/categories` | CategoryManagement | 分类管理 |
| `/home/rls` | RlManagement | RL管理 |

### 5.3 侧边栏菜单结构

```
首页概览
问题列表
创建问题
问题统计
用户管理
▼ 配置管理
    局点管理
    版本管理
    分类管理
    RL管理
```

### 5.4 核心页面设计

#### 问题列表 (Issues.vue)

```
┌────────────┬──────────────────────────────────────┐
│ 问题分类     │ 搜索框 [ 状态下拉 ] [⚙]               │
│ (树形选择)   │ ┌──────────────────────────────────┐  │
│            │ │ 表头（可拖拽列宽，齿轮选择可见列）  │  │
│ ▸ 功能问题   │ │ 数据行...                         │  │
│   ▸ 内核模块 │ │ ...                              │  │
│     ☐ 缺陷   │ └──────────────────────────────────┘  │
│              │ [10条/页] [分页控件] 第 X/Y 页       │
└────────────┴──────────────────────────────────────┘
```

**列管理**：齿轮按钮弹出复选框菜单（13 个可选列），默认展示 6 列（日期、客户名称、问题简述、问题分类、内核版本、操作），操作列固定 130px 右侧粘性。

**列宽拖拽**：`table-layout: fixed`，每列最小 80px，拖拽仅改变当前列，其他列保持宽度。左侧列不动，右侧列平移。

**新增问题弹窗**：表单含 16+ 字段，客户名称用可搜索下拉框（关联局点），内核版本用下拉框（关联版本），问题分类用三级联动下拉，RL 用下拉框（关联 RL 管理），紧急恢复选"是"则 6 个时间字段必填。

#### 问题详情 (IssueDetail.vue)

左侧竖向书签（6 个模块），右侧展示内容：

| 书签 | 内容 | 编辑方式 |
|------|------|----------|
| 基础信息 | 日期、客户、重点局点、局点类型、管控部署形态、内核版本、内核部署形态、RL、问题分类(三级联动)、问题简述、运维系统单号、ecare单号 | 点击"编辑"按钮 |
| 快速属性 | 业务中断、紧急恢复、备注 | 点击"编辑"按钮 |
| 发现问题 | 有无告警、告警触发、备注 | 点击"编辑"按钮 |
| 关键时间 | 8 个时间点 + 7 项自动计算耗时总结 | 点击"编辑"按钮 |
| 问题归档 | 文档链接、录屏链接 | 点击"编辑"按钮 |
| 应急预案 | 处理时/当前是否有预案、预案名称 | 点击"编辑"按钮，有预案时名称必填 |

每个模块独立保存，后端合并更新（只写非 null 字段）。

#### 分类管理 (CategoryManagement.vue)

树形展示，可折叠。每行含色块+名称+操作按钮。支持新增/编辑/删除，删除有子分类时禁止并提示。

#### 局点管理 (SiteManagement.vue)

表格+搜索+CRUD。编辑时名称禁止修改。地区为省份下拉（含"国外"）。涉及版本用多选下拉框，关联版本管理。

#### 版本管理 (VersionManagement.vue)

表格展示版本号、关联局点（名称，非 ID）、发布日期、状态、操作。新增/编辑表单不包含关联局点选择——关联关系由局点管理侧维护。

---

## 六、部署说明

### 环境要求
- JDK 8+
- Node.js 14+
- PostgreSQL 18+
- Maven 3.8+

### 启动步骤

```bash
# 1. 初始化数据库
psql -U postgres -f backend/sql/init.sql
psql -U postgres -d swat -f backend/sql/sites.sql
psql -U postgres -d swat -f backend/sql/versions.sql
psql -U postgres -d swat -f backend/sql/issues.sql
psql -U postgres -d swat -f backend/sql/issue_categories.sql

# 2. 启动后端
cd backend
mvn spring-boot:run
# 运行在 http://localhost:45123

# 3. 启动前端
cd frontend
npm install
npm run dev
# 运行在 http://localhost:3002
```

### 配置
- 数据库：`backend/src/main/resources/application.yml` — 修改 PostgreSQL 连接信息
- 端口：`server.port`（默认 45123），Vite 代理配置在 `vite.config.js`

---

## 七、技术要点

1. **YAML 密码引号**：以 `0` 开头的数字密码需加引号，防止被解析为八进制。
2. **PostgreSQL JSONB**：`version_ids::jsonb @> to_jsonb(id)` 查询 JSON 数组包含。
3. **Element Plus 按需引入**：全局注册 `ElementPlus`，`ElMessage`/`ElMessageBox`/`ElMessage` 在组件内单独 import。
4. **合并更新**：`PUT /api/issues/{id}` 只更新前端传来的非 null 字段，支持分部保存。
5. **table-layout: fixed**：列宽可独立控制，拖拽一列不影响其他列。
6. **问题编号并发安全**：`countByDate` + 插入 + 重试机制，防止同一日期编号冲突。
7. **三级分类递归构建**：`IssueCategoryService.tree()` 递归组装 children 树。
