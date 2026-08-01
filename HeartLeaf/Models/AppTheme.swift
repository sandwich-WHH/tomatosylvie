import SwiftUI

enum AppTheme {
    static let bgBeige   = Color(hex: 0xFFFFFF)  // 纯白底
    static let cardCream = Color(hex: 0xFFFFFF)  // 卡片白
    static let surface   = Color(hex: 0xF6F5F3)  // 输入/底板浅灰
    static let matcha    = Color(hex: 0x7E9280)  // 莫兰迪鼠尾草绿
    static let leafDark  = Color(hex: 0x5E7060)
    static let ink       = Color(hex: 0x3E3A37)
    static let sketch    = Color(hex: 0x9B9792)  // 次要文字
    static let line      = Color(hex: 0xE8E6E2)  // 分隔线
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
