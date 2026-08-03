import Foundation
import UIKit
import SwiftUI

final class RecordEditorViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var selectedMood: Mood = .calm
    @Published var selectedTags: Set<String> = []
    @Published var selectedImage: UIImage?

    let editingRecord: Record?
    private let draftKey = "heartleaf.draft"

    init(record: Record? = nil) {
        editingRecord = record
        if let record {
            text = record.displayText
            selectedMood = record.moodValue
            selectedTags = Set(record.tagNames)
            if let path = record.photoPath {
                selectedImage = ImageStore.shared.loadImage(at: path)
            }
        } else {
            restoreDraft()
        }
    }

    var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = Array(selectedTags)

        if let record = editingRecord {
            var photoPath = record.photoPath
            if selectedImage != nil {
                if let path = record.photoPath {
                    ImageStore.shared.deleteImage(at: path)
                }
                photoPath = ImageStore.shared.saveImage(selectedImage!)
            } else {
                photoPath = nil
            }
            DataService.shared.updateRecord(record, text: trimmed, mood: selectedMood, tags: tags, photoPath: photoPath)
        } else {
            let photoPath = selectedImage.flatMap { ImageStore.shared.saveImage($0) }
            DataService.shared.createRecord(text: trimmed, mood: selectedMood, tags: tags, photoPath: photoPath)
        }
        clearDraft()
    }

    func cacheDraft() {
        if editingRecord == nil {
            let dict: [String: Any] = [
                "text": text,
                "mood": selectedMood.rawValue,
                "tags": Array(selectedTags),
            ]
            UserDefaults.standard.set(dict, forKey: draftKey)
        }
    }

    func restoreDraft() {
        guard let dict = UserDefaults.standard.dictionary(forKey: draftKey) else { return }
        text = dict["text"] as? String ?? ""
        if let raw = (dict["mood"] as? NSNumber)?.int16Value {
            selectedMood = Mood.from(raw)
        }
        if let tags = dict["tags"] as? [String] {
            selectedTags = Set(tags)
        }
    }

    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftKey)
    }
}
