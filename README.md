# 心叶（Heart Leaf）

给无处安放的情绪，一片心形的叶子。

**心叶** 是一款面向高压人群的「减压倾诉」手账式日记 App。工作、生活压力大的人，在无法及时找到人倾诉时，可以在这里安静地记录碎碎念、灵感和情绪。

> 本项目为个人作品项目，用于展示 iOS 原生开发能力。

---

## ✨ 功能亮点

| 功能 | 说明 |
|---|---|
| 📝 碎碎念记录 | 打开就写，一个词、一句话都算记录，草稿自动保存 |
| 🎭 心情选择 | 6 种心情（开心/平静/疲惫/低落/焦虑/愤怒），彩色手写风表达 |
| 🏷️ 分类标签 | 工作 / 生活 / 灵感，可筛选 |
| 📅 日历视图 | 每条记录同步到对应日期，当天心情色点一目了然 |
| 📖 月度日记 | 每月自动生成一本可翻看的日记册 |
| 🎲 随机回忆 | 盲盒式随机翻开某一天的记录 |
| 📊 数据统计 | 记录热力图、心情占比圆环图、标签占比 |
| 📷 照片记录 | 每条记录可配一张照片 |
| 📄 导出 PDF | 单条记录 / 整月日记导出为 PDF |
| 🔒 隐私安全 | v1.0 数据仅保存在本机，无任何网络请求 |

---

## 🛠️ 技术栈

- **语言**：Swift 5.9+
- **UI 框架**：SwiftUI
- **数据持久化**：Core Data（含 `dateKey` 索引优化）
- **图片处理**：沙盒存储 + PhotosPicker
- **PDF 导出**：PDFKit
- **架构**：MVVM + 分层服务（View → ViewModel → Service → Model）
- **第三方依赖**：无（全部原生能力）

---

## 📁 架构说明

```
HeartLeaf/
├── Sources/          # App 入口
├── Views/            # SwiftUI 页面（按模块分目录）
│   ├── Timeline/     # 时间线 + 随机回忆
│   ├── Editor/       # 记录编辑 + 心情/标签选择
│   ├── Calendar/     # 日历 + 月度日记
│   ├── Stats/        # 统计（热力图/圆环/占比）
│   ├── Detail/       # 记录详情 + 分享
│   └── Settings/     # 我的 + 关于
├── ViewModels/       # 状态管理（ObservableObject）
├── Services/         # DataService / ImageStore / PDFExportService
├── Models/           # Core Data 实体 / Mood / Tag / AppTheme
└── Resources/        # Assets / Core Data 模型 / Info.plist
```

**设计规范**：颜色收敛在 `Models/AppTheme.swift`（暖米背景 + 抹茶绿主色），禁止在 View 内硬编码色值。

---

## 🚀 运行方式

### 前置要求
- macOS 12+（需安装 Xcode 15+）
- iOS 16+ 的 iPhone（真机）或 Xcode 模拟器

### 步骤
1. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)（可选，用于生成工程文件）
   ```bash
   brew install xcodegen
   ```
2. 生成 Xcode 工程
   ```bash
   cd HeartLeaf
   xcodegen generate
   ```
3. 打开 `HeartLeaf.xcodeproj`，选择目标设备，⌘R 运行

> 真机运行：免费 Apple ID 即可，证书 7 天有效期，需在 Xcode 的 Signing 中设置你的 Team。

---

## 🎨 设计风格

莫兰迪 · 纯净白 · 简洁现代

- 纯白背景（`#FFFFFF`）+ 莫兰迪鼠尾草绿主色（`#7E9280`）
- 6 种心情采用莫兰迪低饱和色（灰绿/灰蓝/灰紫/蓝灰/灰赭/灰陶）
- 时间线式首页：左侧日期节点 + 竖线，卡片内仅显示时间与心情符号
- 顶部周视图横条，有记录的日子显示当天心情
- 大量留白，低饱和配色，减少倾诉心理压力

---

## 🗺️ 后续规划

- [ ] 云同步（iCloud / 自建后端）
- [ ] 生物识别锁（Face ID 隐私保护）
- [ ] 自定义标签
- [ ] 每日提醒推送
- [ ] 语音转文字
- [ ] 桌面小组件

---

## 📄 文档

- [产品需求文档 PRD](docs/PRD.md)
- [技术方案](docs/TECH_DESIGN.md)

---

© 2026 心叶 Heart Leaf · 数据仅保存在用户设备
