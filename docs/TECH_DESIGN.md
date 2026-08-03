# 心叶（Heart Leaf）技术方案

> 版本：v1.0  
> 关联文档：`docs/PRD.md`（需求定稿）  
> 技术栈：Swift 5.9+ / SwiftUI / Core Data / iOS 16+ / iPhone only

---

## 1. 架构总览

### 1.1 分层架构（MVVM + 分层服务）

```
┌─────────────────────────────────────────────┐
│ View（SwiftUI View）                         │  纯展示、无业务逻辑
├─────────────────────────────────────────────┤
│ ViewModel（@ObservableObject）              │  状态管理、数据绑定
├─────────────────────────────────────────────┤
│ Service（DataService / ExportService ...）  │  业务逻辑、数据访问入口
├─────────────────────────────────────────────┤
│ Model（Core Data 实体 / 枚举 / 值对象）      │  数据结构
└─────────────────────────────────────────────┘
```

**依赖方向**：View → ViewModel → Service → Model。禁止反向调用、禁止跨层直跳。

### 1.2 关键设计决策
| 决策 | 结论 | 理由 |
|---|---|---|
| SwiftUI + Core Data | 采用 | iOS 16 无 SwiftData；Core Data 后续平滑接 iCloud |
| 数据层抽象 | 封装 `DataService`，View/VM 不直接碰 NSManagedObjectContext | 未来可替换实现，单功能可独立修改 |
| 零第三方依赖 | 坚持 | 聚焦原生能力，简历更亮 |
| 异步 | MainActor + async/await | 数据量小，避免过度工程 |

---

## 2. 工程目录结构

```
HeartLeaf/
├── HeartLeafApp.swift              # App 入口
├── Views/
│   ├── RootView.swift              # TabView（记录/日历/统计/我的）
│   ├── Timeline/                   # F10 时间线 + F6 随机
│   │   ├── TimelineView.swift
│   │   ├── RecordCardView.swift    # 手账卡片
│   │   └── RandomMemoryView.swift
│   ├── Editor/                     # F1 记录编辑
│   │   ├── RecordEditorView.swift
│   │   ├── MoodPickerView.swift    # F2
│   │   └── TagPickerView.swift     # F3
│   ├── Calendar/                   # F4 日历 + F5 月记
│   │   ├── CalendarView.swift
│   │   ├── DayRecordsView.swift
│   │   └── MonthlyDiaryView.swift  # 翻页册
│   ├── Stats/                      # F7 统计
│   │   ├── StatsView.swift
│   │   ├── HeatmapView.swift
│   │   ├── TagRatioView.swift
│   │   └── MoodRingView.swift
│   ├── Detail/                     # 记录详情 + F9 导出
│   │   ├── RecordDetailView.swift
│   │   └── ShareSheet.swift
│   └── Settings/                   # 我的
│       └── SettingsView.swift
├── ViewModels/
│   ├── TimelineViewModel.swift
│   ├── RecordEditorViewModel.swift
│   ├── CalendarViewModel.swift
│   ├── StatsViewModel.swift
│   └── MonthlyDiaryViewModel.swift
├── Services/
│   ├── DataService.swift           # Core Data 统一入口
│   ├── ImageStore.swift            # 图片沙盒存取
│   └── PDFExportService.swift      # F9 导出
├── Models/
│   ├── Record+CoreDataClass.swift
│   ├── Mood.swift                  # 心情枚举 + 颜色
│   ├── Tag.swift
│   └── AppTheme.swift              # 设计 Token（颜色/字体）
├── Resources/
│   ├── Assets.xcassets             # 图标/图片
│   └── Theme/                      # 色板、手绘描边资源
├── HeartLeaf.xcdatamodeld/         # Core Data 模型
└── Supporting/
    ├── HeartLeaf.entitlements
    └── Info.plist
```

**命名约定**：View 后缀 `View`、ViewModel 后缀 `ViewModel`、Service 后缀 `Service`、枚举单数名词（`Mood`、`Tag`）。

---

## 3. 数据模型（Core Data）

### 3.1 实体定义
**Record**
| 属性 | 类型 | 约束/说明 |
|---|---|---|
| id | UUID | 主键 |
| text | String | 正文 |
| mood | Int16 | 枚举原始值，见 3.2 |
| tags | String? | 逗号分隔的标签名（v1.0 简化） |
| photoPath | String? | 沙盒相对路径 |
| createdAt | Date | 创建时间 |
| dateKey | String | `yyyy-MM-dd`，建索引 |

### 3.2 Mood 枚举
```swift
enum Mood: Int16, CaseIterable, Identifiable {
    case happy, calm, tired, down, anxious, angry
}
```
颜色映射见 PRD 4.2，收敛在 `Mood` 的 `color` 计算属性，不散落各处。

### 3.3 索引
`dateKey` 建索引（高频按月/日查询）；`createdAt` 排序。

---

## 4. 模块实现要点（对应 PRD 功能）

### F1 记录 / F10 时间线
- `TimelineViewModel` 按 `createdAt` 倒序分组（日期头 + 卡片）。
- 记录编辑用独立 Context + 自动草稿（Editor 退出未保存时，将草稿存 UserDefaults 或临时实体）。
- 卡片复用 `RecordCardView`，支持轻量差异化边框（信封/便签/邮票），由 `mood` 派生样式，保持规范内。

### F2 心情
- `MoodPickerView`：横向胶囊，选中放大+底色，保存 `Mood.rawValue`。

### F3 标签
- 固定三类：工作/生活/灵感；多选 0~3；以 `,` 拼接存储。

### F4 日历
- `CalendarView` 按月渲染网格；日期下方显示心情色点/数量。
- 点击日期 push `DayRecordsView`。
- 月份数据用 `dateKey` 前缀 `yyyy-MM` 谓词查询。

### F5 月度日记
- `MonthlyDiaryView`：左右翻页（TabView .page 样式或自定义动画），封面月+叶形，内页按日期倒序。
- 数据由 `MonthlyDiaryViewModel` 从当月 Record 组装。

### F6 随机回忆
- `RandomMemoryView`：随机取非今日一条，全屏卡片翻转入场；无记录时手绘空态。

### F7 统计
- `HeatmapView`：月历网格 + 颜色深浅（1→5+ 记录数）。
- `TagRatioView`：三类占比，环形或条形 + 百分比。
- `MoodRingView`：6 色圆环，颜色与 Mood 一致。
- 支持「本月 / 全部」切换。

### F8 照片
- 编辑器 `PhotosPicker`（iOS 16 支持）选一张；`ImageStore` 压缩存沙盒，`photoPath` 记录相对路径；删除记录级联删文件。

### F9 导出 PDF
- `PDFExportService` 用 PDFKit 生成：米色底、标题、正文、日期、心情色标注。
- 支持单条记录与整月日记；产出后走 `ShareSheet`（系统分享面板）。

---

## 5. 设计规范落地（代码层）

所有颜色/字体收敛在 `AppTheme.swift`：
```swift
enum AppTheme {
    static let bgBeige   = Color(hex: 0xFFFFFF)  // 背景·纯白
    static let cardCream = Color(hex: 0xFFFFFF)  // 卡片·白
    static let surface   = Color(hex: 0xF6F5F3)  // 卡片/底板·暖白
    static let matcha    = Color(hex: 0x7E9280)  // 主色·鼠尾草绿
    static let leafDark  = Color(hex: 0x5C7060)  // 苔藓
    static let brandSoft = Color(hex: 0xC5D0BC)  // 嫩芽
    static let ink       = Color(hex: 0x3E3A37)  // 墨褐
    static let sketch    = Color(hex: 0x9B9792)  // 浅灰褐
    static let line      = Color(hex: 0xE8E6E2)  // 淡米
    static let inkLine   = Color(hex: 0x2B2826)  // 墨黑·手绘线
    static let paperNote = Color(hex: 0xEDE6D6)  // 牛皮纸
}
```
- 禁止在 View 内硬编码色值/字号，一律取 Token。
- 手写感：情感文字用系统手写类字体 fallback + 版式/描边营造；正文系统字体。
- 6 心情色定义在 `Models/Mood.swift`（灰绿/灰蓝/灰紫/蓝灰/灰赭/灰陶），禁止散落硬编码。

---

## 6. 导航结构
```
RootView (TabView)
├── TimelineTab → TimelineView → push: Editor / Detail / RandomMemory
├── CalendarTab → CalendarView → push: DayRecordsView / MonthlyDiaryView
├── StatsTab    → StatsView
└── SettingsTab → SettingsView
```

---

## 7. 工程生成方式（待确认）
- 方式 A：用 `xcodegen` 生成 `project.pbxproj`（YAML 声明式，便于 review）。
- 方式 B：手动创建 Xcode 工程（需要 Xcode 环境）。
- 方式 C：Swift Package（无 App target，不适用于独立 App）。
- **推荐 A**：无 Mac 也能产出可提交的工程结构，README 说明在 Xcode 中如何打开运行。

> 注：当前开发环境为 Windows，无法编译运行 iOS。将通过 GitHub Actions 做 `xcodebuild` 编译验证（模拟器，不签名）。是否需要提供这一套 CI 在开发阶段确认。

---

## 8. 简历展示要点（开发时落实）
1. **架构亮点**：MVVM + Service 分层、Core Data 索引优化、图片生命周期管理。
2. **技术亮点**：PDFKit 导出、PhotosPicker 集成、热力图自绘（Canvas）、翻页动画。
3. **工程规范**：命名统一、Token 化设计系统、零第三方依赖。
4. **README**：简介 / 截图 / 技术栈 / 架构图 / 运行方式 / 后续规划。
