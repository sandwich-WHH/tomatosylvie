import SwiftUI

struct RecordCardView: View {
    let record: Record

    private var cardStyle: CardStyle {
        switch record.moodValue {
        case .happy: return .envelope
        case .calm: return .note
        case .tired: return .stamp
        case .down: return .postcard
        case .anxious: return .ticket
        case .angry: return .note
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: record.moodValue.icon)
                    .font(.system(size: 14))
                    .foregroundColor(record.moodValue.color)
                Text(record.moodValue.title)
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
                Spacer()
                Text(timeString)
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
            }

            if !record.displayText.isEmpty {
                Text(record.displayText)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.ink)
                    .lineLimit(4)
            }

            if let photoPath = record.photoPath,
               let image = ImageStore.shared.loadImage(at: photoPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if !record.tagNames.isEmpty {
                HStack(spacing: 6) {
                    ForEach(record.tagNames, id: \.self) { name in
                        Text(name)
                            .font(AppTheme.smallFont)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .stroke(AppTheme.matcha, lineWidth: 1)
                            )
                            .foregroundColor(AppTheme.leafDark)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.sketch.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: AppTheme.sketch.opacity(0.08), radius: AppTheme.cardShadowRadius, x: 0, y: 2)
        .padding(.horizontal, 20)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.displayDate)
    }

    @ViewBuilder
    private var cardBackground: some View {
        switch cardStyle {
        case .envelope:
            ZStack(alignment: .bottomTrailing) {
                AppTheme.cardCream
                Image(systemName: "seal.fill")
                    .font(.system(size: 24))
                    .foregroundColor(record.moodValue.color.opacity(0.5))
                    .padding(12)
                    .rotationEffect(.degrees(-12))
            }
        case .stamp:
            ZStack(alignment: .topTrailing) {
                AppTheme.cardCream
                Image(systemName: "bird.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.matcha.opacity(0.6))
                    .padding(12)
                    .rotationEffect(.degrees(12))
            }
        case .postcard:
            AppTheme.cardCream.opacity(0.9)
        case .ticket:
            AppTheme.cardCream
        case .note:
            AppTheme.cardCream
        }
    }

    private enum CardStyle {
        case envelope, note, stamp, postcard, ticket
    }
}
