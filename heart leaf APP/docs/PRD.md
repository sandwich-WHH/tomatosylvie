# 心叶（Heart Leaf）产品需求文档（PRD）

> 版本：v3.7（对应最终可交互原型 `web/index.html` 定稿）
> 数据依据：`web/index.html`（2321 行，MD5 `E3F994B99486B6A9FCE2FB4A7A62E80B`）
> 状态：定稿，可进入开发
> 技术方向：可交互 HTML 高保真原型（PWA 就绪）+ iOS 原生 App（Swift + SwiftUI，最低 iOS 16，仅 iPhone）

---

## 1. 产品概述

### 1.1 一句话定位
**心叶** 是一款面向高压人群的「减压倾诉」手账式日记 App，让用户在无人倾诉时，把碎碎念、灵感、情绪安静地写下来。

### 1.2 解决的核心问题
- 工作 / 生活压力大的人，在情绪上头时找不到人倾诉，缺少一个私密、安全、不被打扰的出口。
- 零门槛书写：打开就写，不强迫长篇大论，一个词、一句话都算记录。
- 温柔陪伴：通过手账式视觉与回顾功能，让记录成为一种治愈而不是任务。

### 1.3 目标人群
| 维度 | 描述 |
|---|---|
| 年龄 | 20~40 岁 |
| 职业 | 上班族、学生、自由职业者，工作生活压力较大 |
| 场景 | 深夜emo、通勤时、压力峰值、灵感突现、想说话但无人可说 |
| 核心诉求 | 私密记录、情绪释放、安全感、被温柔对待 |

### 1.4 产品价值主张
> 「给无处安放的情绪，一片心形的叶子。」

---

## 2. 页面结构与导航（v3.7 定稿，以此为准）

```
┌─ 底部 Tab 栏（仅 3 个，永远固定不随内容滚动）──────┐
│  记录(时间线)   统计   我的                          │
└────────────────────────────────────────────────────┘
```

| 页面 | 视图 id | 说明 |
|---|---|---|
| 时间线（记录） | `view-home`（默认） | 顶栏（左汉堡）+ 周横条 + 时间线信息流 + FAB |
| 统计 | `view-stats` | 顶栏（本月/全部切换）+ 圆环饼图 + 条形图 |
| 我的 | `view-me` | 署名卡 + 菜单（关于/反馈/清空/设置） |
| 设置 | `view-settings` | toggle 开关、通知、小组件、编辑署名、退出登录 |
| 编辑署名 | `view-edit-signature` | 输入署名 + 保存 |
| 抽屉（月历） | 覆盖层 `.drawer` | 汉堡入口：月份切换 + 月历 + 我的本子 |

**硬性布局规则（v3.7 写死）**：
1. 每页 = 固定顶栏 `.topbar` + 固定周横条 `.week-strip`（仅首页）+ 可滚动中部 `.view-scroll`（`flex:1; overflow-y:auto`）。
2. 底部 Tab 栏 `.tab-bar` `position:absolute` 贴底，永不移动。
3. FAB 仅首页（`view-home`）显示，切换其它 Tab 自动隐藏。
4. 写记录弹层 `.modal` 非激活态 = `transform:translateY(100%)` + `visibility:hidden` + `pointer-events:none`；关闭瞬间消失。

---

## 3. 功能需求详述（对应原型逐条验证）

### F1 记录碎碎念 / 灵感（P0）
- 入口：时间线页右下角记录笔 FAB（60×60 墨黑圆形 `#2B2826`，白色铅笔 SVG，白色外光圈 `0 0 0 4px rgba(255,255,255,0.5)`）。
- **唯一入口**：全 App 只有 FAB 能打开写记录弹层（`openWriteModalFromFab()`，前置 `WRITE_MODAL_ALLOWED` 硬守卫）。`openWriteModal()` 第一行 `if (!WRITE_MODAL_ALLOWED) return;`。
- 写记录弹层结构：`.modal-header`（取消 / 「写好了 ♡」保存钮）→ 日期中英双语（`2026 年 8 月 2 日 · 周日` + `Saturday, a soft day`）→ 「现在的心情」→ 「加上标签」→ 「写点什么」→ 照片上传框。
- 保存按钮态：有心情或正文才可用（`.disabled` 移除逻辑 `onInputChange()`）。
- 保存逻辑 `saveRecord()`：`date = CURRENT_DATA.today`、`time = 当前 HH:mm`；无心情默认 `calm`、无正文默认 `(未填写文字)`；插入 records 顶部；累加对应所属月 `statsByMonth`；关闭弹层 + 重渲 时间线/周横条/统计/月历；Toast「写好了。抱抱今天的自己 ♡」。

### F2 心情选择（P0）
- 6 种固定心情（数组顺序与颜色写死，3 列 × 2 行网格）：
  | key | 名称 | 插图文件 | 颜色 |
  |---|---|---|---|
  | happy | 开心 | `mood-icons/01_开心_太阳小人_透明.png` | `#9BAE9A` |
  | calm | 平静 | `mood-icons/02_平静_茶杯小人_透明.png` | `#8FA8B5` |
  | tired | 疲惫 | `mood-icons/05_疲惫_云朵小人_透明.png` | `#A69CAE` |
  | sad | 低落 | `mood-icons/06_低落_雨伞小人_透明.png` | `#7E8EA5` |
  | anxious | 焦虑 | `mood-icons/03_焦虑_乱线小人_透明.png` | `#C2A08A` |
  | angry | 愤怒 | `mood-icons/04_愤怒_闪电小人_透明.png` | `#BF8F84` |
- 选中态：SVG 手绘圈画出（`drawCircle` 700ms）+ 心情名加粗 + 右上 ✓ 弹性现身。
- 心情用于：时间线卡片整圈边框色 + 淡色填充（`mixWhite(color, 0.8)`）、统计饼图/条形图、周横条与月历「有记录」标识。

### F3 分类标签（P0）
- 内置 6 个 `TAGS = ['工作', '生活', '灵感', '家人', '朋友', '健康']`；记录时多选（0~n）。
- 记录卡片内标签以 `#标签` chip 展示。

### F4 日历视图（P0）
- 入口：汉堡抽屉（非 Tab）。
- 月历网格 `.cal-grid`：7 列；今天品牌绿实心白字、有记录日期下方 4px 品牌绿圆点、未来日期置灰、非本月补位日期 `faded`。
- 月份切换 `‹ ›`（`calPrevMonth`/`calNextMonth`，下月按钮到当前月禁用）；点击日期 → `handleCalDay` 关闭抽屉并跳转时间线滚动到对应 `day-group[data-date]`，**绝不弹出写记录弹层**。
- 「我的本子」两本月度手绘本（August 米棕渐变 / July 嫩绿渐变，含 `diary ✿ leaf` 脚标 + 品牌绿丝带），点击 `goToMonth(2026,8)` 直达对应月。

### F5 月度日记（P0）
- 手绘本为月度入口卡片（本原型未含翻页册正文，翻页册列入原生迭代）。

### F6 随机回忆（本原型未含，纳入 backlog）

### F7 数据统计（P1）
- 顶部「本月 / 全部」切换（`TIME_RANGE = 'month' | 'all'`，`setTimeRange`）。
- 本月：按 `CAL_STATE` 对应月（`getActiveStats`）；全部：跨月聚合。
- 圆环饼图 `.pie-section`：SVG 圆环（半径 64、扇区间 1.5px 白边、`stroke-opacity 0.88`）+ 中央展示占比最高心情 + 图例（dot+名称+百分比）+ tooltip；点击扇区/图例 `selectSlice` 高亮（其余 `opacity 0.22`）+ tooltip。
- 各心情占比条形图 `.stat-row`：心情图 56px + 名称 + 横向条（`stat-bar-fill` 入场动画 1s）+ 次数大数字。
- 空态：`total === 0` → 「这月还没有记录 ♡」/「数据还在路上 ♡」+ `✿` 空态插画。
- 顶栏 title 随范围切换：「本月心情」/「全部心情」。

### F8 照片记录（P1）
- 写记录弹层底部照片上传框 `.photo-upload-box`（demo 占位，点击 Toast「这里是照片入口（demo）」）。

### F9 导出 PDF（P2，纳入 backlog）

### F10 时间线浏览（P1）
- 首页信息流 `.timeline`：按日期分组（`day-group[data-date]`）、时间倒序；左侧竖线（`left:22px`，1px `--line`）。
- 周横条 `.week-strip`：今天 ±3 共 7 天（每格 40px）；`has-record` 绿边圆 + 绿叶子；今天品牌绿实心 + 白色叶子 + 白色粗日期。
- 每日期组：手写日期 `X月X日` + 心叶 SVG 叶子（今天实心绿、非今天空心描边 `fill:--bg`）。
- 卡片 `.record-card`：整圈 1.5px 心情色边框（`--mood-line`）+ 12px 圆角 + 淡心情色填充（`--mood-bg = mixWhite(0.8)`）；心情图 40px + 心情名同行靠左；正文 12.5px / 300 / `#8A867F` 层级下沉；标签 chip。
- 空状态：`✿` + 「还没有故事」+ 「要不，今天就开始？」。
- 日期跳转 `scrollToDate`：仅滚动 `.view-scroll`（`scrollTo` 到 day-group 顶部偏移，不 `scrollIntoView` 整页滚动），Toast「跳转到 X 月 X 日 ♡」。

### F11 我的页（P1）
- 署名卡 `.me-card`：头像（虚线圆 + `HL`）+ 署名（默认「亲爱的树洞听众」）+ 语录「给无处安放的情绪，一片心形的叶子」+「点我修改署名」；点击进入编辑署名。
- 菜单顺序写死：关于心叶 → 意见反馈 → 清空所有记录（confirm 确认 + Toast「已清空（demo）」）→ 设置。

### F12 设置页（P1）
- 设置行：首页用输入页（toggle）、iCloud 数据同步（toggle 默认 on）、通知设置、添加小组件、编辑署名（显示当前署名预览）。
- 底部「退出登录」墨黑胶囊按钮（Toast「已退出登录（demo）」）。

### F13 编辑署名（P1）
- 输入框 `maxlength 20`；保存 → 更新 me-name / signature-preview / drawer-hi（`hi, {署名}`）→ 返回我的页，Toast「署名已保存 ♡」。

### F14 全局 Toast
- 底部居中墨黑胶囊，`showToast` 2s 自动消失。

---

## 4. 数据模型（原型内存态）

```js
record = { date: 'yyyy-MM-dd', time: 'HH:mm', mood: key, text: string, tags: string[] }
statsByMonth = { 'yyyy-MM': { calm: n, happy: n, tired: n, anxious: n, sad: n, angry: n } }
DEMO_DATASETS = { demo1: 全量, demo2: 空, demo3: 当天多条 }   // 默认 demo1，today = '2026-08-02'
userState = { signature: '亲爱的树洞听众', writeMood: null, writeTags: [], writeText: '' }
CAL_STATE = { year, month }        // 抽屉月历
TIME_RANGE = 'month' | 'all'       // 统计范围
WRITE_MODAL_ALLOWED = false        // 弹层守卫锁
```

- `mixWhite(hex, ratio)`：心情色与白色混合得到淡填充色（ratio 0.8）。
- 调试钩子 `window.heartLeaf`：goto / switchDemo / openWriteModalFromFab / closeWriteModal / toggleDrawer / showToast / calPrevMonth / calNextMonth / calJumpToday / goToMonth / setTimeRange / renderStats / selectSlice / clearSliceSelection / data() / setRecord() / state()。

---

## 5. 视觉设计规范（Design System）

> 风格：莫兰迪克制 × HEYTEA 艺术家拙趣 × 手写字体温度。核心：大量留白、低饱和、绿色点睛。

### 5.1 色彩 Token（写死，禁止散落硬编码）
| Token | 色值 | 用途 |
|---|---|---|
| `--bg` | `#FFFFFF` | 全局背景 |
| `--paper` | `#F6F5F3` | 卡片暖白底 |
| `--ink` | `#3E3A37` | 正文墨褐 |
| `--ink-soft` | `#9B9792` | 次要文字 |
| `--line` | `#E8E6E2` | 分隔线淡米 |
| `--line-dashed` | `#C5D0BC` | 输入框虚线嫩芽 |
| `--paper-note` | `#EDE6D6` | 牛皮纸便签 |
| `--ink-line` | `#2B2826` | FAB 墨黑 / 手绘线 |
| `--brand` | `#7E9280` | 鼠尾草绿主色 |
| `--brand-dark` | `#5C7060` | 苔藓 |
| `--brand-soft` | `#C5D0BC` | 嫩芽 |
| 6 心情色 | 见 3.2 | 心情标识 |

### 5.2 字体
- 情感层（手写）：`--font-emotion: '演示悠然小楷', 'Noto Serif SC', serif`
- 装饰层（英文手写）：`--font-decorate: 'Caveat', 'Patrick Hand', cursive`
- 功能层（无衬线）：`--font-sans: 'Noto Sans SC', 'PingFang SC', sans-serif`

### 5.3 品牌图形：心叶叶子
- 品牌图标 = 心叶（`logo_leaf.png` 抠图轮廓），内联 SVG path（viewBox 24×24，`LEAF_PATH` 常量），不引入 `<img>`。
- `LEAF_SVG`（`.leaf-fill` 可填充/描边）：时间线 `.day-marker`（今天实心绿 / 非天空心描边）。
- `LEAF_SVG_INNER`（纯 `fill:currentColor`）：周横条有记录圆点内叶子（绿 / 今日白）。

### 5.4 组件规范
| 组件 | 规格 |
|---|---|
| 记录卡片 | 整圈心情色描边 1.5px + 12px 圆角 + 淡色填充 + 无阴影 |
| FAB | 墨黑 60×60 圆 + 白铅笔 + 白色外光圈，仅首页 |
| 标签 chip | 胶囊，选中品牌绿实底白字 |
| 心情选择 | 3 列 × 2 行裸插画网格，选中手绘圈 + ✓ |
| 底部 Tab | 3 个，选中品牌绿 + 顶部盖章圆点 |
| 周横条圆点 | 32×32，虚线边 → 有记录绿边 + 叶子 → 今天品牌绿实心 + 白叶 |
| 空状态 | 手绘 `✿` + 温柔文案 |

---

## 6. 交互与动效（v3.7 硬规则，写死勿改）

### 6.1 写记录弹层守卫（最高优先级）
```
1. 弹层只允许右下角记录笔 FAB 打开。
2. 点击周横条 / 月历任何日期 → 仅滚动跳转到对应卡片文本框，绝不弹出弹层。
3. 其余任何操作不得打开弹层。
实现：let WRITE_MODAL_ALLOWED=false；
     openWriteModal() 首行 if(!WRITE_MODAL_ALLOWED) return;
     openWriteModalFromFab() { true→open→false }；FAB onclick=openWriteModalFromFab；
     scrollToDate/handleCalDay 开头 closeWriteModal() + 复位 WRITE_MODAL_ALLOWED=false（双保险）。
```

### 6.2 布局硬规则
```
- 每页 = 固定顶栏 + 固定周横条(仅首页) + 可滚动中部 .view-scroll。
- 底部 Tab 栏 position:absolute 贴底，永不移动。
- .modal 非激活 = transform+visibility:hidden+pointer-events:none；关闭瞬间消失。
- 日期跳转只滚 .view-scroll（scrollTo day-group 顶部偏移）。
```

### 6.3 动效
- 页面切换淡入上移 300ms；FAB hover 1.05 / active 0.95；弹层上滑 350ms `--ease-decel`；心情手绘圈 700ms；饼图扇区入场 600ms；条形图 1s 生长；Toast 2s。
- 禁止：弹跳、旋转 loading、全屏过场、>400ms 过渡（手绘圈/条形图除外）、震动。

---

## 7. 非功能需求
| 项 | 要求 |
|---|---|
| 性能 | 首屏 < 2s；千条记录滚动流畅 |
| 隐私 | 无网络请求（原型纯本地 demo） |
| 兼容 | iPhone 竖屏，iOS 16+ / 现代移动浏览器；桌面端居中 390×844 手机预览（>450px） |
| 无障碍 | 交互元素 ≥44px、文字对比 ≥4.5:1、心情三重编码（图+字+色） |
| 稳定性 | 输入防丢（草稿）、崩溃率 < 0.5% |

---

## 8. 迭代规划
| 版本 | 内容 |
|---|---|
| v3.7（本期定稿） | 3 Tab + 抽屉月历 + FAB 弹层 + 心叶品牌 + 硬交互守卫 |
| v4.0 | 随机回忆、导出 PDF、照片真实上传、月度翻页册正文 |
| v1.1+ | 云同步、隐私锁、自定义标签、每日提醒、语音转文字、小组件 |

---

## 9. 待办 backlog
- [ ] 随机回忆（F6）
- [ ] 导出 PDF（F9）
- [ ] 照片真实选图上传
- [ ] 月度日记翻页册正文（F5）
- [ ] 云同步（iCloud）
- [ ] 生物识别锁
- [ ] 每日提醒推送
- [ ] 语音转文字
- [ ] 多语言（英文）
