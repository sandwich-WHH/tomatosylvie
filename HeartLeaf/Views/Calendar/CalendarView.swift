import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date?
    @State private var showingMonthlyDiary = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgBeige.ignoresSafeArea()

                VStack(spacing: 16) {
                    monthHeader

                    weekdayHeader

                    calendarGrid

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("日历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingMonthlyDiary = true
                    } label: {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(AppTheme.leafDark)
                    }
                }
            }
            .navigationDestination(item: $selectedDate) { date in
                DayRecordsView(date: date)
            }
            .sheet(isPresented: $showingMonthlyDiary) {
                MonthlyDiaryView(month: viewModel.displayedMonth)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                viewModel.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.leafDark)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.monthTitle)
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.ink)
                if !Calendar.current.isDate(viewModel.displayedMonth, equalTo: Date(), toGranularity: .month) {
                    Button("回到今天") { viewModel.goToToday() }
                        .font(AppTheme.smallFont)
                        .foregroundColor(AppTheme.matcha)
                }
            }

            Spacer()

            Button {
                viewModel.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.leafDark)
            }
        }
        .padding(.horizontal, 4)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                Text(day)
                    .font(AppTheme.smallFont)
                    .foregroundColor(AppTheme.sketch)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.days) { cell in
                if let date = cell.date {
                    dayCell(cell, date: date)
                } else {
                    Color.clear
                        .frame(height: 48)
                }
            }
        }
        .padding(12)
        .background(AppTheme.cardCream, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.sketch.opacity(0.2), lineWidth: 1)
        )
    }

    private func dayCell(_ cell: DayCell, date: Date) -> some View {
        Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(cell.isToday ? .white : AppTheme.ink)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(cell.isToday ? AppTheme.matcha : Color.clear)
                    )
                    .overlay(
                        Circle()
                            .stroke(cell.isToday ? Color.clear : AppTheme.sketch.opacity(0.2), lineWidth: 1)
                    )

                HStack(spacing: 3) {
                    ForEach(0..<min(cell.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(AppTheme.matcha.opacity(0.8))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 6)
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
    }
}
