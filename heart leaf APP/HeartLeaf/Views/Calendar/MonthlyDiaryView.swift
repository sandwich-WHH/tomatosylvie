import SwiftUI

struct MonthlyDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MonthlyDiaryViewModel

    init(month: Date = Date()) {
        _viewModel = StateObject(wrappedValue: MonthlyDiaryViewModel(month: month))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                if viewModel.hasRecords {
                    TabView {
                        coverPage
                            .tag(0)
                        ForEach(Array(viewModel.records.enumerated()), id: \.offset) { index, record in
                            diaryPage(record)
                                .tag(index + 1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.matcha.opacity(0.6))
                        Text("这个月还没有日记")
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.sketch)
                    }
                }
            }
            .navigationTitle("月度日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(AppTheme.leafDark)
                }
            }
        }
    }

    private var coverPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.matcha)
            Text(viewModel.monthTitle)
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.ink)
            Text(viewModel.monthSummary())
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.sketch)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.cardCream)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.matcha.opacity(0.4), lineWidth: 2)
        )
        .padding(24)
    }

    private func diaryPage(_ record: Record) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: record.moodValue.icon)
                        .foregroundColor(record.moodValue.color)
                    Text(record.moodValue.title)
                        .font(AppTheme.subtitleFont)
                        .foregroundColor(AppTheme.ink)
                    Spacer()
                    Text(Formatters.friendlyDateTime.string(from: record.displayDate))
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.sketch)
                }

                Text(record.displayText)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.ink)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let photoPath = record.photoPath,
                   let image = ImageStore.shared.loadImage(at: photoPath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
        .background(AppTheme.cardCream)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
        )
        .padding(24)
    }
}
