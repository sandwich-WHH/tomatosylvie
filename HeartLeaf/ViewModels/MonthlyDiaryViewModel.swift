import Foundation
import Combine

final class MonthlyDiaryViewModel: ObservableObject {
    @Published var month: Date
    @Published var records: [Record] = []

    private var cancellables = Set<AnyCancellable>()

    init(month: Date = Date()) {
        self.month = month
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func reload() {
        let key = Formatters.monthKey.string(from: month)
        records = DataService.shared.records(inMonth: key)
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: month)
    }

    var hasRecords: Bool { !records.isEmpty }

    func monthSummary() -> String {
        let moods = records.map { $0.moodValue }
        let top = Dictionary(grouping: moods, by: { $0 })
            .sorted { $0.value.count > $1.value.count }
            .first?.key
        return "本月共 \(records.count) 篇\(top.map { " · 心情多为「\($0.title)」" } ?? "")"
    }
}
