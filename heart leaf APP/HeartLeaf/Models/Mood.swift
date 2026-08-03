import SwiftUI

enum Mood: Int16, CaseIterable, Identifiable {
    case happy
    case calm
    case tired
    case down
    case anxious
    case angry

    var id: Int16 { rawValue }

    var title: String {
        switch self {
        case .happy: return "开心"
        case .calm: return "平静"
        case .tired: return "疲惫"
        case .down: return "低落"
        case .anxious: return "焦虑"
        case .angry: return "愤怒"
        }
    }

    var color: Color {
        switch self {
        case .happy: return Color(hex: 0x9BAE9A)  // 灰绿（嫩芽/初春）
        case .calm: return Color(hex: 0x8FA8B5)   // 灰蓝
        case .tired: return Color(hex: 0xA69CAE)  // 灰紫
        case .down: return Color(hex: 0x7E8EA5)   // 蓝灰
        case .anxious: return Color(hex: 0xC2A08A) // 灰赭
        case .angry: return Color(hex: 0xBF8F84)  // 灰陶
        }
    }

    var icon: String {
        switch self {
        case .happy: return "smiley"
        case .calm: return "waveform.path.ecg"
        case .tired: return "person.crop.circle.badge.exclamationmark"
        case .down: return "cloud.rain"
        case .anxious: return "bolt"
        case .angry: return "flame"
        }
    }

    static func from(_ raw: Int16) -> Mood {
        Mood(rawValue: raw) ?? .calm
    }
}
