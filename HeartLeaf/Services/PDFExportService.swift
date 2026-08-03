import UIKit
import PDFKit

enum PDFExportService {
    static func pdfData(records: [Record], title: String) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()

            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 6

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor(red: CGFloat(0x5C)/255, green: CGFloat(0x6B)/255, blue: CGFloat(0x46)/255, alpha: 1),
            ]
            (title as NSString).draw(at: CGPoint(x: 48, y: 48), withAttributes: titleAttrs)

            var y: CGFloat = 110
            let contentWidth = pageRect.width - 96

            for record in records {
                if y > pageRect.height - 160 {
                    context.beginPage()
                    y = 48
                }

                let moodText = "心情：\(record.moodValue.title)"
                let moodAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor(red: CGFloat(0x8A)/255, green: CGFloat(0x9B)/255, blue: CGFloat(0x6E)/255, alpha: 1),
                ]
                (moodText as NSString).draw(at: CGPoint(x: 48, y: y), withAttributes: moodAttrs)
                y += 24

                let dateText = record.displayDate.formatted(date: .abbreviated, time: .shortened)
                let dateAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray,
                ]
                (dateText as NSString).draw(at: CGPoint(x: 48, y: y), withAttributes: dateAttrs)
                y += 30

                let body = record.displayText as NSString
                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: paragraph,
                ]
                let rect = body.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: bodyAttrs,
                    context: nil
                )
                body.draw(with: CGRect(x: 48, y: y, width: contentWidth, height: rect.height), options: [.usesLineFragmentOrigin], attributes: bodyAttrs, context: nil)
                y += rect.height + 36

                let dividerRect = CGRect(x: 48, y: y, width: contentWidth, height: 1)
                UIColor(red: CGFloat(0x6B)/255, green: CGFloat(0x66)/255, blue: CGFloat(0x57)/255, alpha: 0.4).setFill()
                UIRectFill(dividerRect)
                y += 30
            }
        }
        return data
    }

    static func fileURL(records: [Record], title: String) -> URL? {
        guard let data = pdfData(records: records, title: title) else { return nil }
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(title).pdf")
        try? data.write(to: temp)
        return temp
    }
}
