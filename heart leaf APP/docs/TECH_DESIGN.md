# 心叶（Heart Leaf）技术方案（TECH DESIGN）

> 版本：v3.7（对应最终交互原型）
> 关联文档：`docs/PRD.md`、`docs/PRD.md`（需求定稿）、`heartleaf-prompt.md`（AI 重建提示词）
> 技术栈：Swift 5.9+ / SwiftUI / Core Data / iOS 16+ / iPhone only；并附单文件 HTML 高保真原型（PWA 就绪）

---

## 1. 双形态交付

| 形态 | 位置 | 用途 |
|---|---|---|
| 可交互 HTML 高保真原型 | `web/index.html` | 视觉与交互定稿（评审 / 演示 / PWA 预览） |
| iOS 原生 App | `HeartLeaf/` | 最终产品（SwiftUI + Core Data） |

> 原型是需求的「可运行说明书」：所有布局、动效、交互规则在原型中写死并可直接体验；原生开发以原型为唯一视觉与交互基准。

---

## 2. 原生架构（MVVM + 分层服务）

```
View（SwiftUI）→ ViewModel（@ObservableObject）→ Service → Model（Core Data）
```

依赖方向单向，禁止反向与跨层。关键决策：
| 决策 | 结论 | 理由 |
|---|---|---|
| SwiftUI + Core Data | 采用 | iOS 16 兼容、后续平滑接 iCloud |
| 数据层抽象 | 封装 `DataService` | 可替换实现、单功能独立修改 |
| 零第三方依赖 | 坚持 | 聚焦原生能力 |

### 2.1 目录结构
```
HeartLeaf/
├── Sources/              # App 入口
├── Views/                # 按模块分目录（Root/Timeline/Editor/Calendar/Stats/Detail/Settings）
│   ├── Root/             # RootView + DrawerManager + DrawerView（3 Tab + 抽屉月历）
│   ├── Settings/         # MeView + SettingsView + SignatureEditorView
├── ViewModels/           # 状态管理
├── Services/             # DataService / ImageStore / PDFExportService
├── Models/               # Core Data 实体 / Mood / Tag / AppTheme
└── Resources/            # Assets.xcassets / Core Data 模型 / Info.plist
```

---

## 3. 原型实现要点（web/index.html，v3.7 定稿）

### 3.1 单文件结构
- 单个 HTML 内嵌全部 CSS + JS，无构建依赖；`window.heartLeaf` 暴露调试 API。
- 字体走 Google Fonts（Caveat / Noto Serif SC / Noto Sans SC）。
- PWA meta + `manifest.webmanifest` + `icons/` + `mood-icons/`。

### 3.2 布局骨架（写死）
```
.phone → .app
  ├─ section.view（flex column）
  │   ├─ .topbar（固定）
  │   ├─ .week-strip（固定，仅首页）
  │   └─ .view-scroll（flex:1; overflow-y:auto；唯一滚动区）
  ├─ .fab（唯一弹层入口，仅首页显示）
  ├─ nav.tab-bar（absolute 贴底，永不移动）
  ├─ .modal-overlay + .modal（写记录弹层）
  ├─ .drawer-overlay + .drawer（月历抽屉）
  └─ .toast
```

### 3.3 关键机制
- **弹层守卫**：`WRITE_MODAL_ALLOWED` 全局锁 + `openWriteModalFromFab()` 唯一入口 + `closeWriteModal()` 强制关闭。
- **弹层隐藏态**：`transform:translateY(100%)` + `visibility:hidden` + `pointer-events:none`，杜绝「露出半截」。
- **日期跳转**：只滚动 `.view-scroll`（计算 `day-group` 相对偏移后 `scrollTo`），顶/底栏不动。
- **心叶品牌**：`LEAF_PATH` 内联 SVG（24×24 viewBox），`LEAF_SVG`（描边/填充可切换）+ `LEAF_SVG_INNER`（纯 currentColor）。
- **卡片主题**：`--mood-line`（心情色整圈边框）+ `--mood-bg`（`mixWhite(color,0.8)` 淡色填充）内联变量。

### 3.4 数据结构（原型内存态）
```js
DEMO_DATASETS = { demo1, demo2, demo3 }   // 3 套演示数据
CURRENT_DATA = { today, records[], statsByMonth{} }
userState = { signature, writeMood, writeTags, writeText }
CAL_STATE  = { year, month }
TIME_RANGE = 'month' | 'all'
```

---

## 4. 原生数据模型（Core Data）

**Record**
| 属性 | 类型 | 说明 |
|---|---|---|
| id | UUID | 主键 |
| text | String | 正文 |
| mood | Int16 | 心情枚举原始值 |
| tags | String? | 逗号分隔 |
| photoPath | String? | 沙盒相对路径 |
| createdAt | Date | 创建时间 |
| dateKey | String | `yyyy-MM-dd`，建索引 |

**Mood** 枚举：`happy / calm / tired / down / anxious / angry`（颜色收敛在 `Models/Mood.swift`）。
索引：`dateKey` 高频按月/日查询；`createdAt` 排序。

---

## 5. 设计 Token（原生层与原型层一一对应）

所有颜色/字体收敛在 `AppTheme.swift`，View 禁止硬编码：
```swift
enum AppTheme {
    static let bg        = Color(hex: 0xFFFFFF)  // 背景
    static let paper     = Color(hex: 0xF6F5F3)  // 卡片底
    static let ink       = Color(hex: 0x3E3A37)  // 正文
    static let inkSoft   = Color(hex: 0x9B9792)  // 次要
    static let line      = Color(hex: 0xE8E6E2)  // 分隔
    static let brand     = Color(hex: 0x7E9280)  // 鼠尾草绿
    static let brandDark = Color(hex: 0x5C7060)
    static let brandSoft = Color(hex: 0xC5D0BC)
    static let inkLine   = Color(hex: 0x2B2826)  // FAB
}
```
心情色（灰绿/灰蓝/灰紫/蓝灰/灰赭/灰陶）定义在 `Models/Mood.swift`。

---

## 6. 原生模块实现要点

### 导航结构（v3.7，与原型一致）
- `RootView` 仅 3 个 Tab：`记录(TimelineView)` / `统计(StatsView)` / `我的(MeView)`。
- `DrawerManager`（@StateObject 注入 environment）控制左滑抽屉；`DrawerView` 内含月历 + 「我的本子」，由各页顶栏汉堡按钮 `toggle()` 打开。
- 日历不再是独立 Tab（与 v3.7 原型一致），月历移入抽屉。

### F1/F10 记录与时间线
- `TimelineViewModel` 按 `dateKey` 倒序分组；卡片复用 `RecordCardView`（心情色描边 + 淡色填充 + 心情图 + 心情名同行 + 正文层级下沉）。
- FAB 仅首页显示；写记录弹层仅由 FAB 触发（守卫同原型）。

### F2 心情
- `MoodPickerView` 6 宫格裸插画；选中手绘圈 + ✓。

### F3 标签
- 固定 6 类，0~n 多选，`,` 拼接存储。

### F4 日历（抽屉内）
- `DrawerView` 内 `CalendarViewModel` 按月渲染（复用原 `CalendarView` 逻辑）；`dateKey` 前缀谓词查询；点击日期关闭抽屉并跳转时间线滚动。

### F5 月度日记
- 月度手绘本（翻页 TabView），封面月 + 叶形；抽屉「我的本子」入口直达。

### F7 统计
- 饼图 + 条形图 + 「本月/全部」切换（`TIME_RANGE`）。
- `MoodRingView`/`HeatmapView`/`TagRatioView` 自绘。

### F8 照片
- `PhotosPicker` 选一张；`ImageStore` 压缩沙盒存储，删除级联清理。

### F9 导出 PDF
- `PDFExportService` 用 PDFKit：米色底 + 手写标题 + 正文 + 心情色标注；`ShareSheet` 分享。

### F11/F12/F13 我的 / 设置 / 编辑署名
- `MeView`：署名卡（点按进 `SignatureEditorView`，`@AppStorage("signature")` 持久化）+ 菜单（关于/意见反馈/清空记录/设置）。
- `SettingsView` 为「我的 → 设置」二级页（toggle 开关 + 退出登录）。

---

## 7. 工程生成与 CI
- 用 `xcodegen`（`project.yml`）生成工程，便于 review。
- GitHub Actions：macOS 14 + Xcode 15.2 → `xcodegen generate` → 模拟器 `xcodebuild`（不签名）编译验证。
- 无 Mac 也能提交可编译验证的工程结构。

---

## 8. 验证清单（每次改动必须执行）
1. JS 语法校验（`node --check`）。
2. HTML 标签平衡校验。
3. headless Chrome e2e：直接调用 `openWriteModal()` 被阻止；点日期不弹层；FAB 可打开；顶/底栏固定；`.modal` 默认不可见；叶子 SVG 存在。
4. 同步 `web/index.html` / `prototype/heartleaf-prototype.html`。

---

## 9. 简历展示要点
1. 架构：MVVM + Service 分层、Core Data 索引优化。
2. 技术：PDFKit、PhotosPicker、热力图/圆环自绘、翻页动画、PWA 原型。
3. 工程：Token 化设计系统、单文件原型 + 原生双形态、零第三方依赖、CI 编译验证。
4. README：简介 / 截图 / 架构 / 运行方式。
