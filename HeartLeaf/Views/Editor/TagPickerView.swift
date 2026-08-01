import SwiftUI

struct TagPickerView: View {
    @Binding var selectedTags: Set<String>

    var body: some View {
        HStack(spacing: 10) {
            ForEach(TagCatalog.all) { tag in
                let isSelected = selectedTags.contains(tag.name)
                Button {
                    if isSelected {
                        selectedTags.remove(tag.name)
                    } else {
                        selectedTags.insert(tag.name)
                    }
                } label: {
                    Text(tag.name)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(isSelected ? .white : AppTheme.leafDark)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? AppTheme.matcha : AppTheme.cardCream)
                        )
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.matcha, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
