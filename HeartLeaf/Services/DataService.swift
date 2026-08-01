import Foundation
import CoreData

final class DataService {
    static let shared = DataService()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "HeartLeaf")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext { container.viewContext }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }

    // MARK: - Create

    func createRecord(text: String, mood: Mood, tags: [String], photoPath: String?) -> Record {
        let record = Record(context: context)
        record.id = UUID()
        record.text = text
        record.moodValue = mood
        record.tags = tags.joined(separator: ",")
        record.photoPath = photoPath
        record.createdAt = Date()
        record.dateKey = Formatters.dateKey.string(from: Date())
        save()
        return record
    }

    func updateRecord(_ record: Record, text: String, mood: Mood, tags: [String], photoPath: String?) {
        record.text = text
        record.moodValue = mood
        record.tags = tags.joined(separator: ",")

        let oldPath = record.photoPath
        if let path = photoPath {
            record.photoPath = path
        } else if oldPath != nil {
            ImageStore.shared.deleteImage(at: oldPath!)
            record.photoPath = nil
        }
        save()
    }

    func deleteRecord(_ record: Record) {
        if let path = record.photoPath {
            ImageStore.shared.deleteImage(at: path)
        }
        context.delete(record)
        save()
    }

    // MARK: - Query

    func recordsSortedDescending() -> [Record] {
        let request: NSFetchRequest<Record> = Record.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Record.createdAt, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func records(for dateKey: String) -> [Record] {
        let request: NSFetchRequest<Record> = Record.fetchRequest()
        request.predicate = NSPredicate(format: "dateKey == %@", dateKey)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Record.createdAt, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func records(inMonth monthKey: String) -> [Record] {
        let request: NSFetchRequest<Record> = Record.fetchRequest()
        request.predicate = NSPredicate(format: "dateKey BEGINSWITH %@", monthKey)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Record.createdAt, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func countByDateKey() -> [String: Int] {
        let all = recordsSortedDescending()
        var dict = [String: Int]()
        for record in all {
            guard let key = record.dateKey else { continue }
            dict[key, default: 0] += 1
        }
        return dict
    }

    func randomHistoricalRecord(excludingTodayKey: String) -> Record? {
        let all = recordsSortedDescending()
        let filtered = all.filter { $0.dateKey != excludingTodayKey }
        guard !filtered.isEmpty else { return nil }
        return filtered.randomElement()
    }
}

enum Formatters {
    static let dateKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    static let monthKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    static let friendlyDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    static let friendlyDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}
