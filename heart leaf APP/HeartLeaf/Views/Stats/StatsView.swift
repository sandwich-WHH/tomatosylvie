import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var drawer: DrawerManager
    @StateObject private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        periodPicker

                        HeatmapView(heatmap: viewModel.heatmap, month: Date())

                        HStack(spacing: 20) {
                            MoodRingView(distribution: viewModel.moodDistribution)
                                .frame(width: 170, height: 170)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("心情占比")
                                    .font(AppTheme.smallFont)
                                    .foregroundColor(AppTheme.sketch)
                                ForEach(viewModel.moodDistribution, id: \.mood) { item in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(item.mood.color)
                                            .frame(width: 8, height: 8)
                                        Text(item.mood.title)
                                            .font(AppTheme.smallFont)
                                            .foregroundColor(AppTheme.ink)
                                        Spacer()
                                        Text("\(item.count)")
                                            .font(AppTheme.smallFont)
                                            .foregroundColor(AppTheme.sketch)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
                        )

                        TagRatioView(distribution: viewModel.tagDistribution)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        drawer.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(AppTheme.ink)
                    }
                }
            }
        }
    }

    private var periodPicker: some View {
        HStack {
            periodButton(title: "本月", isSelected: !viewModel.isAllTime) {
                viewModel.isAllTime = false
            }
            periodButton(title: "全部", isSelected: viewModel.isAllTime) {
                viewModel.isAllTime = true
            }
        }
        .padding(6)
        .background(AppTheme.cardCream, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1))
    }

    private func periodButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.bodyFont)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppTheme.ink)
                .padding(.horizontal, 28)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.matcha : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
