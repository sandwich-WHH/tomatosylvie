# 心叶（Heart Leaf）App · 完整开发提示词（v3.7 定稿）

> 用途：让 AI 从头生成 / 维护心叶 App 的 HTML 交互原型（单文件，含 HTML + CSS + JS）。
> 风格定调：莫兰迪克制 × HEYTEA 艺术家拙趣 × 手写字体温度。核心情绪：安静陪伴 / 零负担书写 / 像无声的朋友。
> 本文件依据最终定稿 `web/index.html`（心叶 logo 版，v3.7）编写，所有类名 / 变量名 / 数值与源码一一对应。
> **第七节「交互硬规则」为最高优先级，写死不改。任何修改不得破坏弹层守卫。**

---

## 〇、硬性交互规则（写死，勿改）

> 这是全 App 最重要的约束，生成 / 修改时**必须逐字保留**，任何版本迭代都不得删除或放宽。

```
★★★ 硬性交互规则（已写死，勿改，v3.7 修订）：
1. 写记录弹层（.modal）【只允许右下角记录笔 FAB 打开】。
2. 点击周横条 / 月历【任何】日期 → 仅滚动跳转到对应卡片文本框，绝不弹出写记录弹层。
3. 除 FAB 外，其余任何操作均不得打开写记录弹层。
4. 实现机制：
   - 全局锁 let WRITE_MODAL_ALLOWED = false;
   - openWriteModal() 第一行守卫：if (!WRITE_MODAL_ALLOWED) return;
   - openWriteModalFromFab() { WRITE_MODAL_ALLOWED = true; openWriteModal(); WRITE_MODAL_ALLOWED = false; }
   - FAB onclick = "openWriteModalFromFab()"（全 App 唯一打开弹层的入口）。
   - scrollToDate() 与 handleCalDay() 开头必须调用 closeWriteModal() 强制关闭残留弹层，
     并复位 WRITE_MODAL_ALLOWED = false（双保险）。
5. FAB 仅首页（view-home 为当前视图）显示：goto() 里 fab.classList.toggle('hidden', viewId !== 'home')。

★★★ 布局硬规则（v3.7 新增，写死勿改）：
6. 每个页面 = 固定顶栏（.topbar）+ 固定周横条（.week-strip，仅首页）+ 可滚动中部（.view-scroll）。
   - .view 改为 flex-direction:column；.topbar 与 .week-strip 加 flex-shrink:0；
   - 只有 .view-scroll（flex:1; overflow-y:auto）参与滚动。
   - 底部 Tab 栏 .tab-bar 保持 position:absolute 贴底，永不移动。
7. 写记录弹层 .modal 默认隐藏态 = transform:translateY(100%) + visibility:hidden + pointer-events:none；
   仅 .modal.active 才 visibility:visible + pointer-events:auto + 上滑动画。
   关闭（移除 .active）时 visibility 即时切回 hidden（无 350ms 下滑过渡），
   保证任何日期跳转都不会看到「露出半截」的残留弹层。
8. 日期跳转只滚动 .view-scroll（scrollTo 到 day-group 的顶部偏移），不调用 scrollIntoView 整页滚动。
```

---

## 一、产品一句话

「心叶」是一款面向 20-40 岁都市高压人群的减压倾诉手账式日记 App。价值主张：**「给无处安放的情绪，一片心形的叶子。」**

---

## 二、整体技术形态（务必遵守）

- **单文件 HTML 原型**：一个 `.html` 内含全部 HTML、CSS、JS，打开即可预览。
- **纯前端 + 本地状态**：数据存于内存 `CURRENT_DATA`（demo 用），无网络 / 后端 / 构建工具依赖。
- **保留调试钩子**：暴露 `window.heartLeaf` 调试 API（页面跳转、数据集切换、弹层开关、读写数据、读取运行时状态）。
- **字体**：Google Fonts 加载 `Caveat`（手写花体）、`Noto Serif SC`（衬线手写）、`Noto Sans SC`（无衬线）。
- **心情插图**：6 张手绘透明 PNG，位于 `mood-icons/`，命名如 `01_开心_太阳小人_透明.png`。
- **心叶叶子**（logo_leaf.png 抠图轮廓）：不插入 `<img>`，使用**内联 SVG path**（见第七节 LEAF_PATH）。

---

## 三、布局框架（全局硬性约束）

- **双层容器**：外层 `.phone`（桌面端 >450px 显示，宽 390、高 844、`border-radius:40px`、`box-shadow:0 20px 60px rgba(0,0,0,0.12)`、页面外背景 `#EDEDF0`）；移动端（≤450px）全屏无边框去圆角。
- `.phone` 内为 `.app`（`position:relative; width:100%; height:100%; overflow:hidden`），所有页面元素放这里。
- **无手机外壳 / 无刘海 / 无状态栏 / 无调试面板**（v3 起移除）。
- 层级：`.phone` → `.app` → `<section class="view">` → 底部 Tab `.tab-bar` → 悬浮 FAB `.fab` → 弹层（`.modal` / `.drawer`）→ `.toast`。
- **页面**：`view-home`（时间线，默认 active）、`view-stats`（统计）、`view-me`（我的）、`view-settings`（设置）、`view-edit-signature`（编辑署名）。
- **FAB**：`position:absolute`（相对 `.app`），`right:24px`、`bottom:calc(84px + env(safe-area-inset-bottom))`，60×60 圆、`background:var(--ink-line)` 墨黑、白色铅笔 SVG。**仅首页显示**，点击 = `openWriteModalFromFab()`。
- **顶部栏 `.topbar`**：`padding:18px 24px 12px`，左汉堡（`toggleDrawer()`）；首页右侧空白 `.right-spacer`；统计页右侧「本月/全部」切换。
- **底部 Tab `.tab-bar`**：`position:absolute` 贴底，高 `calc(64px + env(safe-area-inset-bottom))`，毛玻璃白底 + 上边线 `--line`。**只有 3 个 Tab：记录(home)·统计(stats)·我的(me)**。选中 `color:var(--brand)` + 顶部品牌绿圆点（`.tab.active::before`）。日历从汉堡抽屉进入，不在 Tab。

---

## 三、设计令牌（Design Tokens，CSS 变量）

```css
/* 基础色 */
--bg:          #FFFFFF;   /* 全局背景，大量留白 */
--paper:       #F6F5F3;   /* 卡片暖白底 */
--ink:         #3E3A37;   /* 正文主文字（墨褐） */
--ink-soft:    #9B9792;   /* 次要文字 */
--line:        #E8E6E2;   /* 分隔线（淡米） */
--line-dashed: #C5D0BC;   /* 输入框虚线边框（嫩芽） */
--ink-line:    #2B2826;   /* 手绘线条 / FAB 墨黑（禁纯黑 #000） */
--paper-note:  #EDE6D6;   /* 牛皮纸便签 */

/* 品牌色 */
--brand:       #7E9280;   /* 鼠尾草绿：主按钮、选中态、今日高亮 */
--brand-dark:  #5C7060;   /* 苔藓：深色标签 */
--brand-soft:  #C5D0BC;   /* 嫩芽：浅绿辅助色 */

/* 心情色（6 种，莫兰迪低饱和） */
--mood-happy:   #9BAE9A;  /* 开心 · 灰绿 */
--mood-calm:    #8FA8B5;  /* 平静 · 灰蓝 */
--mood-tired:   #A69CAE;  /* 疲惫 · 灰紫 */
--mood-sad:     #7E8EA5;  /* 低落 · 蓝灰 */
--mood-anxious: #C2A08A;  /* 焦虑 · 灰赭 */
--mood-angry:   #BF8F84;  /* 愤怒 · 灰陶 */

/* 字体三段式 */
--font-emotion:  '演示悠然小楷', 'Noto Serif SC', serif;   /* 情感层·手写体 */
--font-decorate: 'Caveat', 'Patrick Hand', cursive;        /* 装饰层·手绘花体（英文） */
--font-sans:     'Noto Sans SC', 'PingFang SC', sans-serif; /* 功能层 */

/* 心情插画 */
--mood-size: 72px;
--mood-circle-size: 90px;

/* 动效曲线 */
--ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
--ease-spring:   cubic-bezier(0.34, 1.56, 0.64, 1);
--ease-decel:    cubic-bezier(0.16, 1, 0.3, 1);
```

**禁止**：暖黄/米黄大面积背景、马卡龙高饱和、荧光色、纯黑 `#000000`、高饱和原色。禁止元素：Emoji 作图标、拟物纹理、商业 SaaS 渐变按钮、任何容器圈住心情插画。

---

## 四、心叶叶子图标（LEAF_PATH，关键资产，勿改）

从 `brand/logo_leaf.png`（826×731，alpha 通道）抠图外轮廓，eps=8 简化 + Chaikin 平滑，归一化到 viewBox 24×24 的闭合 path：

```js
const LEAF_PATH = 'M17.21 1.00 L16.95 1.56 L16.92 2.54 L17.11 3.93 L17.07 4.77 L16.82 5.08 L16.04 5.50 L14.74 6.03 L13.69 6.64 L12.88 7.32 L12.21 7.26 L11.68 6.46 L10.95 6.08 L10.01 6.13 L8.93 6.71 L7.71 7.80 L6.51 8.71 L5.33 9.43 L4.44 10.13 L3.85 10.81 L3.47 11.43 L3.31 11.98 L3.55 12.05 L4.16 11.64 L4.64 11.53 L4.98 11.71 L5.09 11.71 L4.95 11.53 L5.09 11.64 L5.50 12.07 L5.74 13.32 L5.83 15.39 L6.21 17.43 L6.87 19.43 L7.14 20.81 L7.00 21.56 L6.39 20.46 L5.29 17.50 L4.68 16.46 L4.54 17.35 L4.65 18.12 L5.01 18.77 L4.79 18.94 L3.98 18.61 L3.41 18.26 L3.07 17.88 L3.14 18.17 L3.64 19.13 L4.34 19.86 L5.25 20.36 L5.92 21.20 L6.34 22.40 L6.81 23.00 L7.30 23.00 L7.64 22.61 L7.83 21.84 L8.18 21.23 L8.67 20.77 L10.37 20.05 L13.28 19.07 L15.23 18.28 L16.20 17.66 L17.23 16.81 L18.31 15.74 L19.38 14.09 L20.44 11.88 L20.93 10.00 L20.87 8.44 L20.63 7.04 L20.21 5.79 L19.60 4.48 L18.78 3.11 L18.23 2.41 L17.96 2.38 L17.70 1.95 L17.46 1.13 Z';
const LEAF_SVG = `<svg viewBox="0 0 24 24" aria-hidden="true"><path class="leaf-fill" d="${LEAF_PATH}"/></svg>`;
const LEAF_SVG_INNER = `<svg viewBox="0 0 24 24" aria-hidden="true" fill="currentColor"><path class="leaf-svg-path" d="${LEAF_PATH}"/></svg>`;
```

用法：
- 时间线 `.day-marker` 用 `LEAF_SVG`（`path.leaf-fill`，可填充可描边）。
- 周横条 `.dot .leaf-svg` 用 `LEAF_SVG_INNER`（`path.leaf-svg-path`，纯 `fill:currentColor`）。

---

## 五、心情配置（6 种，固定）

源码 `MOODS` 数组顺序：happy → calm → tired → sad → anxious → angry（网格渲染依此 3 列 × 2 行）。

| key | 名称 | 插图文件 | 颜色 |
|---|---|---|---|
| happy | 开心 | `mood-icons/01_开心_太阳小人_透明.png` | `#9BAE9A` |
| calm | 平静 | `mood-icons/02_平静_茶杯小人_透明.png` | `#8FA8B5` |
| tired | 疲惫 | `mood-icons/05_疲惫_云朵小人_透明.png` | `#A69CAE` |
| sad | 低落 | `mood-icons/06_低落_雨伞小人_透明.png` | `#7E8EA5` |
| anxious | 焦虑 | `mood-icons/03_焦虑_乱线小人_透明.png` | `#C2A08A` |
| angry | 愤怒 | `mood-icons/04_愤怒_闪电小人_透明.png` | `#BF8F84` |

标签集合 `TAGS`：`['工作', '生活', '灵感', '家人', '朋友', '健康']`。

---

## 六、数据模型（源码实际结构）

```js
const DEMO_DATASETS = {
  demo1: {
    today: '2026-08-02',
    records: [ /* 按时间倒序，多条同日期 */ ],
    statsByMonth: { '2026-08': { calm:12, happy:9, tired:7, anxious:5, sad:4, angry:3 }, '2026-07': {...} },
  },
  demo2: { today: '2026-08-02', records: [], statsByMonth: {} },
  demo3: { today: '2026-08-02', records: [/* 当天 5 条 + 昨日 3 条 */], statsByMonth: { '2026-08': {...} } },
};
let CURRENT_DEMO = 'demo1';
let CURRENT_DATA = DEMO_DATASETS[CURRENT_DEMO];

let userState = { signature: '亲爱的树洞听众', writeMood: null, writeTags: [], writeText: '' };
let CAL_STATE = { year: 2026, month: 8 };   // 抽屉月历
let TIME_RANGE = 'month';                   // 统计 'month' | 'all'
```

- 记录字段：`date`（'yyyy-MM-dd'）、`time`（'HH:mm'）、`mood`、`text`、`tags[]`。
- 快捷键函数 `mixWhite(hex, ratio)`：接近色与白色混合得淡色（`ratio:0.8`）用于卡片底色。

---

## 七、首页 · 时间线（v3.7 定稿布局）

### 7.1 顶部
- 顶部栏：左汉堡，右侧完全空白。
- **周横条 `.week-strip`**：`display:flex; gap:10px; padding:4px 24px 18px; overflow-x:auto`（隐藏滚动条）。最近 7 天（今天 ±3），每格 40px 宽：
  - `.dow`（日~六）11px 手写浅灰、`.dow-num`（几号）13px 手写墨色。
  - `.dot`：32×32 圆，默认 `--paper` 底 + `1.5px dashed rgba(155,174,154,0.4)` 边。
  - **有记录的天 `.has-record .dot`**：`background:var(--bg)` + `1.5px solid var(--brand)` 边，内嵌 `.leaf-svg`（`LEAF_SVG_INNER`，`color:var(--brand)`）。
  - **今天 `.today .dot`**：`background:var(--brand)`、无边框、浅绿投影；内嵌白色叶子（`color:#FFFFFF`）与白色加粗日期（`.dot-num` 白色 18px 字重 500）。注意今天始终显示叶子（同时拥有 today + 叶子逻辑）。
  - hover 放大 1.1、active 缩 0.95。
  - 点击某天 → `onclick="scrollToDate('${dateStr}')"`。

### 7.2 时间线主体
- 纵向 `.timeline`：`padding:0 16px 100px`；`::before` 竖线 `left:22px`、宽 1px、色 `--line`，`top:0; bottom:0`。
- 按日期分组、时间倒序展示，`day-group[data-date]`。
- `.day-date`：手写 15px、`--ink`，`padding:18px 0 4px 0`、左对齐、`margin-left:22px`；首组 `padding-top:8px`。
- **`.day-marker`（心叶 SVG）**：`position:absolute`，`left:14px; top:46px`（**首组 `.day-group:first-child .day-marker` 用 `top:36px`**），16×16；`path .leaf-fill` 默认 `fill:var(--bg); stroke:currentColor; stroke-width:1.6`（空心白底描边）；`.day-group.today .day-marker` → `color:var(--brand)` 且 `fill/stroke:var(--brand)`（实心绿）。竖线中心 x=22，marker 中心 x=14+8=22 对齐。
- `.record-entry`：`margin:0 0 16px 34px`（**整条左缩进 34px**）。
- `.record-time`：12px、`--ink-soft`、`padding:0 0 4px 2px`。

**卡片硬规则**：
- `.record-card`：**整圈** `border:1.5px solid var(--mood-line)`（心情色，内联变量）**+ 大圆角 12px + 无阴影** + `padding:12px 14px`；**背景为更淡的心情色 `var(--mood-bg)`（JS 用 `mixWhite(color, 0.8)` 计算）**。
- `.record-mood-row`：`display:flex; align-items:center; justify-content:flex-start; gap:10px`——心情图片与心情名**靠左且紧挨同一行**（禁止时间/心情换行列）。
  - `.record-mood-icon`：40×40，透明 PNG，`flex-shrink:0`。
  - `.record-mood-name`：手写（emotion）15px、`--ink`、字重 500。
- `.record-text`（正文）：12.5px、字重 300、色 `#8A867F`（灰度低于顶部行）、行高 1.6。
- `.record-tags`：`margin-top:6px`，chip 11px、`--ink-soft`、`rgba(0,0,0,0.04)` 底、`padding:2px 8px`、圆角 8px。

### 7.3 空状态
- 无记录：`.empty-state`，手绘 `✿` + "还没有故事" + "要不，今天就开始？"。

---

## 八、写记录弹层（交互硬规则见「〇」）

- **仅 FAB 能打开**（openWriteModalFromFab）。
- 结构：`.modal-overlay`（点击关闭）+ `.modal`（底部弹层，`transform:translateY(100%)→0`）。
- `.modal-header`：左"取消"、右保存 **「写好了 ♡」**（无心情且无正文时 `.disabled` 禁用）。
- 日期区：`.modal-date`（`2026 年 8 月 2 日 · 周{日}`）+ `.modal-date-en`（如 "Saturday, a soft day"）。
- 「现在的心情」：6 心情裸插画网格 3 列 × 2 行，插画 72px（`--mood-size`），无容器框。选中态：SVG 手绘圈画出 + 心情名变粗 + 右上 ✓ 弹性现身。
- 「加上标签」：chip 多选（0~3 个）。
- 「写点什么」：大虚线输入框 `.write-input`（虚线边 --line-dashed），占位三段治愈文字。
- 照片上传框 `.photo-upload-box`：点击 toast「这里是照片入口（demo）」。
- 保存 `saveRecord()`：`date` 用 `CURRENT_DATA.today`、`time` 当前 HH:mm；插入 records 顶部；累加当月 `statsByMonth`；关闭弹层 + 重渲 时间线/周横条/统计/月历；Toast「写好了。抱抱今天的自己 ♡」。

---

## 九、抽屉（日历）

- 左滑抽屉 `.drawer`（320px、350ms `cubic-bezier(0.32,0.72,0,1)`）+ 遮罩 `.drawer-overlay`点击关闭。
- 头部：`hi, {signature}`。
- 月份切换 `.cal-month-nav`：‹›（`calPrevMonth`/`calNextMonth`，下月按钮到当前月禁用）+ 中文年月 + 英文月。
- 月历 `.cal-grid`：今天绿实心高亮，有记录日期下方品牌绿圆点，未来日期置灰；点击 → `handleCalDay`（滚动跳转时间线，绝不弹写弹层）。
- 「我的本子」两本月度手绘本（August / July），点击 `goToMonth(year, month)`。
- v3.1 起无角色小传。

---

## 十、统计页

- 顶部右「本月/全部」切换（`.time-range-toggle` → `setTimeRange`）。
- 饼图（SVG 圆环）+ 图例：`selectSlice` 高亮 + tooltip；各心情百分比条形图；统计数据大数字。
- 每月正向统计卡片 `statsByMonth[y-m][mood]`。
- 空状态："还没有记录"。

---

## 十一、我的页 / 设置

- 头像卡（点按改署名→ edit-signature）、语录「给无处安放的情绪，一片心形的叶子」。
- 菜单顺序：关于心叶 → 意见反馈 → 清空所有记录 → 设置（均无数量角标）。
- 设置页：首页用输入页（toggle）、iCloud 同步（默认 on）、通知、小组件、编辑署名、退出登录（墨标胶囊按钮 toast）。
- 编辑署名页：返回 + 输入框 `signature-input`（maxlength 20）+ 保存 → 更新 me-name / signature-preview / drawer-hi，goto('me')。

---

## 十二、动效与微交互

- 卡片进入淡入上移 250-300ms `--ease-decel`；心情选中手绘圈画出 700ms `--ease-spring`；FAB hover 1.05 / active 0.95；抽屉 350ms 滑入；Toast 2s 自动消失。
- **禁止**：弹跳、旋转 loading、全屏过场、超 400ms 过渡（手绘圈除外）、震动反馈。

---

## 十三、无障碍 & 兼容

- 交互元素 ≥44×44；文字对比 ≥4.5:1；心情三重编码（图 + 字 + 色）；竖屏 iPhone 形态；桌面居中手机预览（390×844）。
- 横以上自动隐藏 `.fab.hidden`。
- 滑动隐藏滚动条，隐藏 `.view` 页滚动条。

---

## 十四、调试钩子（必须暴露）

```js
window.heartLeaf = {
  goto, switchDemo, openWriteModalFromFab, closeWriteModal, toggleDrawer, showToast,
  calPrevMonth, calNextMonth, calJumpToday, goToMonth,
  setTimeRange, renderStats, selectSlice, clearSliceSelection,
  data: () => CURRENT_DATA,
  setRecord: (rec) => CURRENT_DATA.records.unshift(rec),
  state: () => ({ userState, CAL_STATE, TIME_RANGE }),
};
```

---

## 十五、产物要求（修改完成后必须执行）

1. **语法校验**：提取 `<script>` 运行 `node --check`，保证 JS 无语法错误。
2. **HTML 标签平衡校验**：运行标签平衡检查脚本，保证开闭标签匹配。
3. **守卫回归测试**（用 headless Chrome 注入脚本）：
   - 直接调用 `openWriteModal()` → 不弹层（`directOpen blocked=true`）；
   - 点击周横条 `.day[data-date]` / 月历 `.cal-day` → modal 不弹；
   - 模拟点击 FAB → 弹层正常出现。
4. **叶子验证**：页面 `<svg>` 中存在 `class="leaf-fill"` / `class="leaf-svg-path"` 且 `d="${LEAF_PATH}"`，无 `<img>` 引用 `logo_leaf.png`。
5. **几何验证**（headless）：竖线 22px 与 marker 14+8 对齐；首组 marker top 36px；marker 中心 Y ≈ 首条 `record-time` 中心 Y。
6. **同步部署**：将生成文件同步到 `prototype/heartleaf-prototype.html` 与 `prototype/index.html`（预览 + GitHub Pages）。

---

## 十六、交付物

- 源文件：`web/index.html`（心叶 logo 版，v3.7 最终定稿，单一 HTML）。
- 预览：`web/index.html`，文档本源 `docs/PRD.md`、`docs/TECH_DESIGN.md`、`design/design-spec.md`。