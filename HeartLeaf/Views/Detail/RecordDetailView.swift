import SwiftUI

struct RecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var exportedURL: URL?

    let record: Record

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: record.moodValue.icon)
                                .font(.system(size: 18))
                                .foregroundColor(record.moodValue.color)
                            Text(record.moodValue.title)
                                .font(AppTheme.subtitleFont)
                                .foregroundColor(AppTheme.ink)
                            Spacer()
                            Text(Formatters.friendlyDateTime.string(from: record.displayDate))
                                .font(AppTheme.smallFont)
                                .foregroundColor(AppTheme.sketch)
                        }

                        Text(record.displayText)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.ink)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let photoPath = record.photoPath,
                           let image = ImageStore.shared.loadImage(at: photoPath) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if !record.tagNames.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(record.tagNames, id: \.self) { name in
                                    Text(name)
                                        .font(AppTheme.smallFont)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().stroke(AppTheme.matcha, lineWidth: 1))
                                        .foregroundColor(AppTheme.leafDark)
                                }
                            }
                        }

                        Button {
                            exportPDF()
                        } label: {
                            Label("导出为 PDF", systemImage: "square.and.arrow.up")
                                .font(AppTheme.subtitleFont)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.matcha, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(AppTheme.leafDark)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportedURL {
                    ShareSheet(items: [exportedURL])
                }
            }
        }
    }

    private func exportPDF() {
        let dateString = Formatters.dateKey.string(from: record.displayDate)
        let title = "记录_\(dateString)"
        if let url = PDFExportService.fileURL(records: [record], title: title) {
            exportedURL = url
            showingShareSheet = true
        }
    }
}
