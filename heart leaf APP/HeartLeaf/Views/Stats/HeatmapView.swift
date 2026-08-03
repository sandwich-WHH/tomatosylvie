import SwiftUI

struct HeatmapView: View {
    let heatmap: [String: Int]
    let month: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var cells: [HeatCell] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = interval.start
        let numberOfDays = calendar.dateComponents([.day], from: firstDay, to: interval.end).day!
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        var result: [HeatCell] = []
        for _ in 1..<firstWeekday {
            result.append(HeatCell(count: 0))
        }
        for day in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: day, to: firstDay)!
            let key = Formatters.dateKey.string(from: date)
            result.append(HeatCell(count: heatmap[key] ?? 0))
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("记录热力图")
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.ink)
                Spacer()
                HStack(spacing: 4) {
                    Text("少")
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.sketch)
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(levelColor(level))
                            .frame(width: 12, height: 12)
                    }
                    Text("多")
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.sketch)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(cells) { cell in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cell.count == 0 ? AppTheme.bgBeige : levelColor(min(cell.count, 5)))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
        )
    }

    private func levelColor(_ level: Int) -> Color {
        let intensity = Double(level) / 5.0
        return AppTheme.matcha.opacity(0.25 + intensity * 0.75)
    }
}

struct HeatCell: Identifiable {
    let id = UUID()
    let count: Int
}
