import SwiftUI

struct RandomMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var record: Record?
    @State private var showCard = false

    var body: some View {
        ZStack {
            AppTheme.bgBeige.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.sketch)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                Spacer()

                if let record {
                    if showCard {
                        RecordCardView(record: record)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.matcha)
                        Text("还没有可回忆的记录\n写下一篇，攒一段回忆吧")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.sketch)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                Button {
                    draw()
                } label: {
                    Label("再翻一张", systemImage: "dice.fill")
                        .font(AppTheme.subtitleFont)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppTheme.matcha, in: Capsule())
                }
                .disabled(record == nil)
                .opacity(record == nil ? 0.5 : 1)
            }
            .padding(.bottom, 40)
        }
        .onAppear { draw() }
    }

    private func draw() {
        let todayKey = Formatters.dateKey.string(from: Date())
        record = DataService.shared.randomHistoricalRecord(excludingTodayKey: todayKey)
        withAnimation(.easeInOut(duration: 0.4)) {
            showCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCard = true
            }
        }
    }
}
