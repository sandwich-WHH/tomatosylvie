import SwiftUI

struct TagRatioView: View {
    let distribution: [(name: String, count: Int)]

    private var total: Int {
        distribution.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("标签占比")
                .font(AppTheme.subtitleFont)
                .foregroundColor(AppTheme.ink)

            if distribution.isEmpty {
                Text("还没有标签记录")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.sketch)
            } else {
                ForEach(distribution, id: \.name) { item in
                    let colors = TagCatalog.colors(for: item.name)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.name)
                                .font(AppTheme.smallFont)
                                .foregroundColor(AppTheme.ink)
                            Spacer()
                            Text("\(item.count) 篇 · \(percentage(item.count))")
                                .font(AppTheme.smallFont)
                                .foregroundColor(AppTheme.sketch)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppTheme.bgBeige)
                                Capsule()
                                    .fill(colors.first ?? AppTheme.matcha)
                                    .frame(width: geo.size.width * ratio(item.count))
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
        )
    }

    private func ratio(_ count: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(count) / CGFloat(total)
    }

    private func percentage(_ count: Int) -> String {
        guard total > 0 else { return "0%" }
        return "\(Int(round(Double(count) / Double(total) * 100)))%"
    }
}
