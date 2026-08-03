import SwiftUI

struct RootView: View {
    @State private var selectedTab: Tab = .timeline
    @StateObject private var drawer = DrawerManager()

    enum Tab: Hashable {
        case timeline, stats, me
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TimelineView()
                    .tabItem {
                        Label("记录", systemImage: "note.text")
                    }
                    .tag(Tab.timeline)

                StatsView()
                    .tabItem {
                        Label("统计", systemImage: "chart.pie")
                    }
                    .tag(Tab.stats)

                MeView()
                    .tabItem {
                        Label("我的", systemImage: "person")
                    }
                    .tag(Tab.me)
            }
            .tint(AppTheme.matcha)
            .toolbarBackground(AppTheme.bgBeige, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)

            DrawerView()
        }
        .environmentObject(drawer)
    }
}
