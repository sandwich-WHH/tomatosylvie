import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var displayedMonth: Date = Date()
    @Published var selectedDate: Date?
    @Published var recordsByDate: [String: Int] = [:]

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func reload() {
        recordsByDate = DataService.shared.countByDateKey()
    }

    var monthKey: String {
        Formatters.monthKey.string(from: displayedMonth)
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: displayedMonth)
    }

    var days: [DayCell] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstDay = interval.start
        let numberOfDays = calendar.dateComponents([.day], from: firstDay, to: interval.end).day!

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var cells: [DayCell] = []
        for _ in 1..<firstWeekday {
            cells.append(DayCell(date: nil, isToday: false, count: 0))
        }
        for day in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: day, to: firstDay)!
            let isToday = calendar.isDateInToday(date)
            let key = Formatters.dateKey.string(from: date)
            cells.append(DayCell(date: date, isToday: isToday, count: recordsByDate[key] ?? 0))
        }
        return cells
    }

    func previousMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    func nextMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    func goToToday() {
        displayedMonth = Date()
    }
}

struct DayCell: Identifiable {
    let id = UUID()
    let date: Date?
    let isToday: Bool
    let count: Int
}
