import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showingEditor = false
    @State private var showingRandom = false
    @State private var selectedRecord: Record?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                if viewModel.records.isEmpty {
                    emptyState
                } else {
                    recordList
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingButton
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("心叶")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingRandom = true
                    } label: {
                        Image(systemName: "dice")
                            .foregroundColor(AppTheme.leafDark)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                RecordEditorView()
            }
            .fullScreenCover(isPresented: $showingRandom) {
                RandomMemoryView()
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundColor(AppTheme.matcha)
            Text("今天的心叶还空着")
                .font(AppTheme.subtitleFont)
                .foregroundColor(AppTheme.ink)
            Text("写点什么吧")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.sketch)
            Button {
                showingEditor = true
            } label: {
                Text("写第一篇")
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppTheme.matcha, in: Capsule())
            }
        }
    }

    private var recordList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24, pinnedViews: []) {
                ForEach(viewModel.groupedRecords, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Formatters.friendlyDate.string(from: group.date))
                            .font(AppTheme.smallFont)
                            .foregroundColor(AppTheme.sketch)
                            .padding(.horizontal, 20)

                        ForEach(group.items) { record in
                            Button {
                                selectedRecord = record
                            } label: {
                                RecordCardView(record: record)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.delete(record)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }

    private var floatingButton: some View {
        Button {
            showingEditor = true
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.leafDark, in: Circle())
                .shadow(color: AppTheme.leafDark.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

extension Record: Identifiable {}
