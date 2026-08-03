import SwiftUI

struct MeView: View {
    @EnvironmentObject private var drawer: DrawerManager
    @State private var showingClearConfirm = false
    @State private var showingSignatureEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        signatureCard

                        meMenu
                    }
                    .padding(20)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    hamburgerButton
                }
            }
            .sheet(isPresented: $showingSignatureEditor) {
                SignatureEditorView()
            }
            .alert("确定清空所有记录吗？", isPresented: $showingClearConfirm) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) { clearAll() }
            } message: {
                Text("此操作不可恢复，所有碎碎念将被删除。")
            }
        }
    }

    private var hamburgerButton: some View {
        Button {
            drawer.toggle()
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.ink)
        }
    }

    private var signatureCard: some View {
        Button {
            showingSignatureEditor = true
        } label: {
            VStack(spacing: 8) {
                Text("HL")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.leafDark)
                    .frame(width: 72, height: 72)
                    .background(AppTheme.bgBeige, in: Circle())
                    .overlay(
                        Circle().stroke(AppTheme.brandSoft, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    )

                Text(drawer.signature)
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.ink)

                Text("给无处安放的情绪，一片心形的叶子")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
                    .italic()

                Text("点我修改署名")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.matcha)
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }

    private var meMenu: some View {
        VStack(spacing: 0) {
            Button {
                // 关于心叶
            } label: {
                menuRowLabel(icon: "info.circle", title: "关于心叶")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.sketch.opacity(0.15))

            Button {
                // 意见反馈
            } label: {
                menuRowLabel(icon: "bubble.left", title: "意见反馈")
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.sketch.opacity(0.15))

            Button {
                showingClearConfirm = true
            } label: {
                menuRowLabel(icon: "trash", title: "清空所有记录", color: Color(hex: 0xBF8F84), showChevron: false)
            }
            .buttonStyle(.plain)

            Divider().overlay(AppTheme.sketch.opacity(0.15))

            NavigationLink {
                SettingsView()
            } label: {
                menuRowLabel(icon: "gearshape", title: "设置")
            }
            .buttonStyle(.plain)
        }
        .background(AppTheme.bgBeige)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.line, lineWidth: 1)
        )
    }

    private func menuRowLabel(icon: String, title: String, color: Color = AppTheme.ink, showChevron: Bool = true) -> some View {
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

struct SignatureEditorView: View {
    @EnvironmentObject private var drawer: DrawerManager
    @State private var text = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                VStack(alignment: .leading) {
                    TextField("给自己起个名字", text: $text)
                        .font(AppTheme.bodyFont)
                        .padding(16)
                        .background(AppTheme.bgBeige, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.line, lineWidth: 1.5)
                        )
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("编辑署名")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(AppTheme.sketch)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        let v = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !v.isEmpty {
                            drawer.signature = v
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.matcha)
                }
            }
            .onAppear {
                text = drawer.signature
            }
        }
    }
}
