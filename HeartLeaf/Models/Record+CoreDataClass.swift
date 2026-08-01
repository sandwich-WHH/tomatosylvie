import Foundation
import CoreData

@objc(Record)
public class Record: NSManagedObject {
}

extension Record {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var mood: Int16
    @NSManaged public var tags: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var dateKey: String?
}

extension Record {
    var moodValue: Mood {
        get { Mood.from(mood) }
        set { mood = newValue.rawValue }
    }

    var tagNames: [String] {
        guard let tags else { return [] }
        return tags.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
    }

    var displayText: String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var displayDate: Date {
        createdAt ?? Date()
    }
}
