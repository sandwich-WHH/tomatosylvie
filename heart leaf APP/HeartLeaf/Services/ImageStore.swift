import UIKit

final class ImageStore {
    static let shared = ImageStore()

    private init() {}

    private var directoryURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = documents.appendingPathComponent("RecordImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func saveImage(_ image: UIImage) -> String? {
        let name = UUID().uuidString + ".jpg"
        let url = directoryURL.appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: url)
            return name
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }

    func loadImage(at relativePath: String) -> UIImage? {
        let url = directoryURL.appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: url.path)
    }

    func deleteImage(at relativePath: String) {
        let url = directoryURL.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
    }
}
