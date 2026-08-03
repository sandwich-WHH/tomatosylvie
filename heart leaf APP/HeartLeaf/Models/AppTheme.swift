import SwiftUI

enum AppTheme {
    // 基础色（v2.2）
    static let bgBeige   = Color(hex: 0xFFFFFF)  // 背景·纯白
    static let cardCream = Color(hex: 0xFFFFFF)  // 卡片·白
    static let surface   = Color(hex: 0xF6F5F3)  // 卡片/底板·暖白
    // 品牌色（v2.2）
    static let matcha    = Color(hex: 0x7E9280)  // 主色·鼠尾草绿
    static let leafDark  = Color(hex: 0x5C7060)  // 苔藓（FAB/深色标签）
    static let brandSoft = Color(hex: 0xC5D0BC)  // 嫩芽（虚线边框）
    // 文字与线（v2.2）
    static let ink       = Color(hex: 0x3E3A37)  // 墨褐·主文字
    static let sketch    = Color(hex: 0x9B9792)  // 浅灰褐·次要文字
    static let line      = Color(hex: 0xE8E6E2)  // 淡米·分隔线
    static let inkLine   = Color(hex: 0x2B2826)  // 墨黑·手绘线条（非纯黑）
    static let paperNote = Color(hex: 0xEDE6D6)  // 牛皮纸·小面积便签
    static let white     = Color(hex: 0xFFFFFF)

    static let cornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 3

    static let titleFont   = Font.system(size: 28, weight: .bold, design: .rounded)
    static let subtitleFont = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let bodyFont     = Font.system(size: 15, weight: .regular)
    static let smallFont    = Font.system(size: 12, weight: .regular)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
