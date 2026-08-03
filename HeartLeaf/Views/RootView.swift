import SwiftUI

struct RootView: View {
    @State private var selectedTab: Tab = .timeline

    enum Tab {
        case timeline, calendar, stats, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label("记录", systemImage: "note.text")
                }
                .tag(Tab.timeline)

            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.pie")
                }
                .tag(Tab.stats)

            SettingsView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(Tab.settings)
        }
        .tint(AppTheme.matcha)
        .toolbarBackground(AppTheme.bgBeige, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
