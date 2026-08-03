import SwiftUI

struct SettingsView: View {
    @AppStorage("isHomeInputPage") private var isHomeInputPage = false
    @State private var showingClearConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        headerCard

                        VStack(spacing: 0) {
                            Toggle(isOn: $isHomeInputPage) {
                                Text("首页用输入页")
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.ink)
                            }
                            .tint(AppTheme.matcha)
                            .padding()

                            Divider().overlay(AppTheme.sketch.opacity(0.15))

                            NavigationLink {
                                AboutView()
                            } label: {
                                settingsRow(icon: "info.circle", title: "关于心叶", showChevron: true)
                            }
                            .buttonStyle(.plain)

                            Divider().overlay(AppTheme.sketch.opacity(0.15))

                            Button {
                                showingClearConfirm = true
                            } label: {
                                settingsRow(icon: "trash", title: "清空所有记录", color: Color(hex: 0xBF8F84), showChevron: false)
                            }
                            .buttonStyle(.plain)
                        }
                        .background(AppTheme.cardCream)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
                        )

                        Text("心叶 v3.7 · 数据仅保存在本机")
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.sketch)
                            .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .alert("确定清空所有记录吗？", isPresented: $showingClearConfirm) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) { clearAll() }
            } message: {
                Text("此操作不可恢复，所有碎碎念将被删除。")
            }
        }
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(AppTheme.matcha, in: RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text("心叶")
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.ink)
                Text("给无处安放的情绪，一片心形的叶子")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
            }
            Spacer()
        }
        .padding(16)
        .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.matcha.opacity(0.4), lineWidth: 1)
        )
    }

    private func settingsRow(icon: String, title: String, color: Color = AppTheme.ink, showChevron: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundColor(color)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.sketch.opacity(0.5))
            }
        }
        .padding()
        .contentShape(Rectangle())
    }

    private func clearAll() {
        let records = DataService.shared.recordsSortedDescending()
        for record in records {
            if let path = record.photoPath {
                ImageStore.shared.deleteImage(at: path)
            }
            DataService.shared.context.delete(record)
        }
        DataService.shared.save()
    }
}
