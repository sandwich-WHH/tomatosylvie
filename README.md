# 心叶 Heart Leaf

给无处安放的情绪，一片心形的叶子。

**心叶** 是一款面向高压人群的「减压倾诉」手账式日记 App。工作、生活压力大的人，在无法及时找到人倾诉时，可以在这里安静地记录碎碎念、灵感和情绪。

本项目包含两种交付形态：
1. **可交互 HTML 高保真原型**（`web/index.html`，PWA 就绪，打开即用）——所有布局、动效、交互规则已在其中定稿写死。
2. **iOS 原生 App**（`HeartLeaf/`，SwiftUI + Core Data）——最终产品。

---

## ✨ 功能亮点

| 功能 | 说明 |
|---|---|
| 📝 碎碎念记录 | 打开就写，一个词、一句话都算记录 |
| 🎭 心情选择 | 6 种心情（开心/平静/疲惫/低落/焦虑/愤怒），手写风表达 |
| 🏷️ 分类标签 | 工作 / 生活 / 灵感 / 家人 / 朋友 / 健康 |
| 📅 日历视图 | 抽屉月历，有记录日期一目了然 |
| 📖 月度日记 | 「我的本子」August / July 手绘月度册 |
| 📊 数据统计 | 心情圆环图 + 占比条形图 + 本月/全部 |
| 🍃 心叶品牌 | logo 抠图内联 SVG，时间线叶子标记 |
| 📱 PWA 就绪 | `manifest.webmanifest` + 图标，可添加到主屏 |

---

## 🎨 设计风格

莫兰迪克制 × HEYTEA 艺术家拙趣 × 手写字体温度

- 纯白背景（`#FFFFFF`）+ 鼠尾草绿主色（`#7E9280`）+ 墨黑 FAB（`#2B2826`）
- 6 种心情莫兰迪低饱和色，配透明 PNG 裸插画
- 时间线式首页：左侧叶子日期节点 + 竖线 + 心情色卡片
- 顶部周横条，有记录的日子显示叶子
- 大量留白、低饱和配色，减少倾诉心理压力

完整设计系统见 `design/design-spec.md`，AI 重建提示词见 `docs/heartleaf-prompt.md`。

---

## 📁 仓库结构

```
heart leaf APP/
├── web/                   # 可交互 HTML 原型（PWA 预览）
│   ├── index.html         # 最终定稿
│   ├── manifest.webmanifest
│   ├── icons/             # PWA 图标
│   └── mood-icons/        # 6 张心情裸插画 + logo_leaf.png
├── prototype/             # 原型资源（字体 / 心情图标 / 同步版 HTML）
├── HeartLeaf/             # iOS 原生 App（SwiftUI + Core Data）
├── design/                # 设计系统（色彩/字体/组件/插画提示词/抠图脚本）
├── references/            # 风格参考图
├── docs/
│   ├── PRD.md             # 产品需求文档
│   ├── TECH_DESIGN.md     # 技术方案
│   └── heartleaf-prompt.md # AI 重建/维护提示词（交互规则写死）
└── .github/workflows/     # CI（iOS 编译验证）
```

---

## 🚀 快速预览（HTML 原型）

直接用浏览器打开 `web/index.html`，或在 `web/` 目录起本地静态服务：

```bash
cd web
python -m http.server 8080
# 浏览器访问 http://localhost:8080
```

---

## 🛠️ 技术栈（iOS 原生）

- **语言**：Swift 5.9+
- **UI**：SwiftUI
- **数据**：Core Data（`dateKey` 索引优化）
- **架构**：MVVM + 分层服务（View → ViewModel → Service → Model）
- **依赖**：零第三方（PDFKit / PhotosPicker 系统框架）
- **工程生成**：XcodeGen（`project.yml`）

### 运行方式
1. 安装 XcodeGen：`brew install xcodegen`
2. `cd HeartLeaf && xcodegen generate`
3. 打开 `HeartLeaf.xcodeproj`，⌘R 运行（iOS 16+ 模拟器/真机）

---

## 🔒 交互硬规则

- 写记录弹层**只允许右下角记录笔 FAB 打开**，点击任何日期只滚动跳转、绝不弹层。
- 顶部栏与底部 Tab 栏**永远固定**，只有中部内容滚动。
- 详见 `docs/heartleaf-prompt.md` 〇 节。

---

## 🗺️ 后续规划

- [ ] 随机回忆
- [ ] 导出 PDF
- [ ] 照片真实选图
- [ ] 云同步（iCloud）
- [ ] 生物识别锁
- [ ] 每日提醒推送
- [ ] 语音转文字
- [ ] 多语言（英文）

---

## 📄 文档

- [产品需求文档 PRD](docs/PRD.md)
- [技术方案](docs/TECH_DESIGN.md)
- [AI 重建提示词](docs/heartleaf-prompt.md)

© 2026 心叶 Heart Leaf · 数据仅保存在用户设备
