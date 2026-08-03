import Foundation
import Combine

final class StatsViewModel: ObservableObject {
    @Published var isAllTime: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in self.objectWillChange.send() }
            .store(in: &cancellables)
    }

    private var baseRecords: [Record] {
        let all = DataService.shared.recordsSortedDescending()
        guard !isAllTime else { return all }
        let key = Formatters.monthKey.string(from: Date())
        return all.filter { ($0.dateKey ?? "").hasPrefix(key) }
    }

    var moodDistribution: [(mood: Mood, count: Int)] {
        var counts = Dictionary(uniqueKeysWithValues: Mood.allCases.map { ($0, 0) })
        for record in baseRecords {
            counts[record.moodValue, default: 0] += 1
        }
        return Mood.allCases.map { (mood: $0, count: counts[$0] ?? 0) }
    }

    var tagDistribution: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for record in baseRecords {
            for tag in record.tagNames {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }

    var heatmap: [String: Int] {
        let monthKey = Formatters.monthKey.string(from: Date())
        let monthRecords = DataService.shared.records(inMonth: monthKey)
        var dict = [String: Int]()
        for record in monthRecords {
            if let key = record.dateKey {
                dict[key, default: 0] += 1
            }
        }
        return dict
    }
}
