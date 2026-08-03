import SwiftUI

struct MoodRingView: View {
    let distribution: [(mood: Mood, count: Int)]

    private var total: Int {
        distribution.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        ZStack {
            ForEach(Array(distribution.enumerated()), id: \.offset) { index, item in
                if total > 0 {
                    PieSliceShape(
                        startAngle: startAngle(index),
                        endAngle: endAngle(index)
                    )
                    .fill(item.mood.color)
                }
            }

            Circle()
                .fill(AppTheme.cardCream)
                .frame(width: 90, height: 90)

            VStack(spacing: 2) {
                Text("\(total)")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.ink)
                Text("条记录")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
            }
        }
    }

    private func startAngle(_ index: Int) -> Angle {
        guard total > 0 else { return .degrees(-90) }
        let consumed = distribution.prefix(index).reduce(0) { $0 + $1.count }
        return .degrees(Double(consumed) / Double(total) * 360 - 90)
    }

    private func endAngle(_ index: Int) -> Angle {
        guard total > 0 else { return .degrees(-90) }
        let consumed = distribution.prefix(index + 1).reduce(0) { $0 + $1.count }
        return .degrees(Double(consumed) / Double(total) * 360 - 90)
    }
}

struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
