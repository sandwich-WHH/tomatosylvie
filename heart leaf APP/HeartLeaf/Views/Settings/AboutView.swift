import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            AppTheme.bgBeige.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 72))
                        .foregroundColor(AppTheme.matcha)
                        .padding(.top, 32)

                    Text("心叶")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.ink)

                    Text("给无处安放的情绪，一片心形的叶子。")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.sketch)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(alignment: .leading, spacing: 12) {
                        aboutRow(icon: "note.text", text: "记录每一次碎碎念与灵感")
                        aboutRow(icon: "calendar", text: "日历同步每一天的心情")
                        aboutRow(icon: "book.closed", text: "每月自动生成一本日记")
                        aboutRow(icon: "dice", text: "随机翻开一段被遗忘的时光")
                        aboutRow(icon: "lock.shield", text: "数据只保存在你的设备上")
                    }
                    .padding(20)
                    .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    Text("心叶 v1.0\n用 SwiftUI 原生构建")
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.sketch)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("关于心叶")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func aboutRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.matcha)
            Text(text)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.ink)
            Spacer()
        }
    }
}
