import SwiftUI

struct DayRecordsView: View {
    @State private var records: [Record] = []
    let date: Date

    private var dateTitle: String {
        Formatters.friendlyDate.string(from: date)
    }

    var body: some View {
        ZStack {
            AppTheme.bgBeige.ignoresSafeArea()

            if records.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "leaf")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.matcha.opacity(0.6))
                    Text("这一天还没有记录")
                        .font(AppTheme.subtitleFont)
                        .foregroundColor(AppTheme.sketch)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(records) { record in
                            RecordCardView(record: record)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle(dateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { reload() }
    }

    private func reload() {
        let key = Formatters.dateKey.string(from: date)
        records = DataService.shared.records(for: key)
    }
}
