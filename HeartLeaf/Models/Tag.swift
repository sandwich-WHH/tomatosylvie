import SwiftUI

struct Tag: Identifiable, Hashable {
    let name: String
    var id: String { name }
}

enum TagCatalog {
    static let all: [Tag] = [
        Tag(name: "工作"),
        Tag(name: "生活"),
        Tag(name: "灵感"),
    ]

    static func colors(for tags: String?) -> [Color] {
        guard let tags else { return [] }
        return tags.split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .map { name in
                switch name {
                case "工作": return AppTheme.leafDark
                case "生活": return AppTheme.matcha
                case "灵感": return Color(hex: 0xC2A08A)
                default: return AppTheme.sketch
                }
            }
    }
}
