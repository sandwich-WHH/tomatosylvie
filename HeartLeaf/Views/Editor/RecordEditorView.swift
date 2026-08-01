import SwiftUI
import PhotosUI

struct RecordEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecordEditorViewModel

    @State private var photosPickerItem: PhotosPickerItem?
    @FocusState private var textFocused: Bool

    init(record: Record? = nil) {
        _viewModel = StateObject(wrappedValue: RecordEditorViewModel(record: record))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        moodPicker
                        tagPicker

                        TextEditor(text: $viewModel.text)
                            .focused($textFocused)
                            .frame(minHeight: 200)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(AppTheme.cardCream)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(AppTheme.sketch.opacity(0.25), lineWidth: 1)
                            )

                        photoPicker

                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(viewModel.editingRecord == nil ? "新记录" : "编辑")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        viewModel.cacheDraft()
                        dismiss()
                    }
                    .foregroundColor(AppTheme.sketch)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        viewModel.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                    .foregroundColor(viewModel.canSave ? AppTheme.leafDark : AppTheme.sketch.opacity(0.4))
                }
            }
            .onTapGesture {
                textFocused = false
            }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("此刻的心情")
                .font(AppTheme.smallFont)
                .foregroundColor(AppTheme.sketch)
            MoodPickerView(selectedMood: $viewModel.selectedMood)
        }
    }

    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("标签（可多选）")
                .font(AppTheme.smallFont)
                .foregroundColor(AppTheme.sketch)
            TagPickerView(selectedTags: $viewModel.selectedTags)
        }
    }

    @ViewBuilder
    private var photoPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("配一张照片（可选）")
                .font(AppTheme.smallFont)
                .foregroundColor(AppTheme.sketch)

            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        viewModel.selectedImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppTheme.sketch.opacity(0.8))
                            .background(.white, in: Circle())
                            .padding(8)
                    }
                }
            } else {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                        Text("从相册选择照片")
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.leafDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.cardCream)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.matcha.opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
        .onChange(of: photosPickerItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
    }
}
