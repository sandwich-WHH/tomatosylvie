import SwiftUI

struct DrawerView: View {
    @EnvironmentObject private var drawer: DrawerManager
    @StateObject private var calendarVM = CalendarViewModel()
    @State private var showingMonthlyDiary = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        ZStack {
            if drawer.isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { drawer.close() }
                    .transition(.opacity)
            }

            HStack(spacing: 0) {
                drawerPanel
                    .frame(width: 320)
                    .offset(x: drawer.isOpen ? 0 : -320)
                    .animation(.easeOut(duration: 0.35), value: drawer.isOpen)

                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.35), value: drawer.isOpen)
        .allowsHitTesting(drawer.isOpen)
    }

    private var drawerPanel: some View {
        ZStack {
            AppTheme.bgBeige.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("hi, \(drawer.signature)")
                        .font(AppTheme.subtitleFont)
                        .foregroundColor(AppTheme.ink)
                        .padding(.top, 20)
                        .padding(.bottom, 18)

                    monthNav

                    calendarGrid

                    notebooksSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 24, x: 4, y: 0)
    }

    private var monthNav: some View {
        HStack {
            Button {
                calendarVM.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.sketch)
            }

            Spacer()

            Text(calendarVM.monthTitle)
                .font(AppTheme.subtitleFont)
                .foregroundColor(AppTheme.ink)

            Spacer()

            Button {
                calendarVM.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        Calendar.current.isDate(calendarVM.displayedMonth, equalTo: Date(), toGranularity: .month)
                            ? AppTheme.line : AppTheme.sketch
                    )
            }
            .disabled(Calendar.current.isDate(calendarVM.displayedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private var calendarGrid: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.sketch)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendarVM.days) { cell in
                    if let date = cell.date {
                        dayCell(cell, date: date)
                    } else {
                        Color.clear
                            .frame(height: 34)
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
        .padding(.vertical, 12)
    }

    private func dayCell(_ cell: DayCell, date: Date) -> some View {
        VStack(spacing: 3) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(AppTheme.bodyFont)
                .foregroundColor(cell.isToday ? .white : AppTheme.ink)
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(cell.isToday ? AppTheme.matcha : Color.clear)
                )

            Circle()
                .fill(AppTheme.matcha.opacity(0.8))
                .frame(width: 4, height: 4)
                .opacity(cell.count > 0 && !cell.isToday ? 1 : 0)
        }
        .frame(height: 38)
        .onTapGesture {
            drawer.close()
        }
    }

    private var notebooksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我的本子")
                .font(AppTheme.subtitleFont)
                .foregroundColor(AppTheme.ink)
                .padding(.top, 10)

            HStack(spacing: 10) {
                notebookCard(title: "August", color: Color(hex: 0xD9C8A8)) {
                    showingMonthlyDiary = true
                }
                notebookCard(title: "July", color: Color(hex: 0xC4CFA8)) {
                    showingMonthlyDiary = true
                }
            }
        }
        .sheet(isPresented: $showingMonthlyDiary) {
            MonthlyDiaryView(month: calendarVM.displayedMonth)
        }
    }

    private func notebookCard(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.ink)
                Text("diary ✿ leaf")
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(3 / 4, contentMode: .fit)
            .padding(10)
            .background(
                LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(AppTheme.matcha)
                    .frame(width: 18, height: 26)
            }
        }
        .buttonStyle(.plain)
    }
}
