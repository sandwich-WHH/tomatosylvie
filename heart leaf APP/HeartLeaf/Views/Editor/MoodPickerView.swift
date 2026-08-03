import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Mood.allCases) { mood in
                    let isSelected = selectedMood == mood
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMood = mood
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: mood.icon)
                            Text(mood.title)
                        }
                        .font(isSelected ? AppTheme.subtitleFont : AppTheme.bodyFont)
                        .foregroundColor(isSelected ? .white : AppTheme.ink)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(isSelected ? mood.color : AppTheme.cardCream)
                        )
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : AppTheme.sketch.opacity(0.25), lineWidth: 1)
                        )
                        .scaleEffect(isSelected ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
