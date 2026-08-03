import Foundation
import Combine
import CoreData

final class TimelineViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var filterTag: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func reload() {
        let all = DataService.shared.recordsSortedDescending()
        if let filterTag, !filterTag.isEmpty {
            records = all.filter { $0.tagNames.contains(filterTag) }
        } else {
            records = all
        }
    }

    var groupedRecords: [(date: Date, items: [Record])] {
        let calendar = Calendar.current
        var groups: [Date: [Record]] = [:]
        for record in records {
            let day = calendar.startOfDay(for: record.displayDate)
            groups[day, default: []].append(record)
        }
        return groups.sorted { $0.key > $1.key }
            .map { (date: $0.key, items: $0.value) }
    }

    func delete(_ record: Record) {
        DataService.shared.deleteRecord(record)
        reload()
    }
}
