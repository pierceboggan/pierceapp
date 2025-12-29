//
//  HistoryView.swift
//  Project2026
//
//  View for viewing history and analytics
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var selectedView: HistoryViewType = .list
    @State private var selectedDate: Date = Date()
    @State private var showingExport = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    enum HistoryViewType: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
        case stats = "Stats"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View Selector
                Picker("View", selection: $selectedView) {
                    ForEach(HistoryViewType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch selectedView {
                case .list:
                    HistoryListView(selectedDate: $selectedDate)
                case .calendar:
                    HistoryCalendarView(selectedDate: $selectedDate)
                case .stats:
                    HistoryStatsView()
                }
            }
            .background(theme.background)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingExport = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                ExportSheet()
            }
        }
    }
}

// MARK: - History List View

struct HistoryListView: View {
    @Binding var selectedDate: Date
    
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        List {
            // Weekly Summary Card
            Section {
                WeeklySummaryCard(
                    summary: daySummaryService.weeklySummary(for: selectedDate)
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Recent Days
            Section("Recent Days") {
                ForEach(daySummaryService.recentSummaries(count: 14)) { summary in
                    NavigationLink {
                        DayDetailView(summary: summary)
                    } label: {
                        DaySummaryRow(summary: summary)
                    }
                }
                
                if daySummaryService.recentSummaries().isEmpty {
                    Text("No history yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Weekly Summary Card

struct WeeklySummaryCard: View {
    let summary: WeeklySummary
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.headline)
                Spacer()
                Text("\(formatDate(summary.startDate)) - \(formatDate(summary.endDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatBox(
                    title: "Avg Score",
                    value: "\(Int(summary.averageScore))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: theme.primary
                )
                
                StatBox(
                    title: "Habits",
                    value: "\(Int(summary.habitComplianceRate * 100))%",
                    icon: "checkmark.circle",
                    color: theme.positive
                )
                
                StatBox(
                    title: "Cleaning",
                    value: "\(Int(summary.cleaningComplianceRate * 100))%",
                    icon: "sparkles",
                    color: .purple
                )
                
                StatBox(
                    title: "Water Avg",
                    value: "\(Int(summary.averageWaterOunces))oz",
                    icon: "drop.fill",
                    color: .blue
                )
                
                StatBox(
                    title: "Reading",
                    value: "\(summary.daysWithReading)/7",
                    icon: "book.fill",
                    color: .orange
                )
                
                StatBox(
                    title: "Pages",
                    value: "\(summary.totalPagesRead)",
                    icon: "doc.text",
                    color: .teal
                )
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Day Summary Row

struct DaySummaryRow: View {
    let summary: DaySummary
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        HStack {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(summary.dayOfWeek)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(summary.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick Stats
            HStack(spacing: 12) {
                // Habits
                Label("\(summary.habitsCompleted)/\(summary.habitsTotal)", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Water
                if summary.waterOunces > 0 {
                    Label("\(Int(summary.waterOunces))oz", systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Score
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: summary.score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(summary.score))")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
    
    private var scoreColor: Color {
        if summary.score >= 80 { return theme.positive }
        if summary.score >= 50 { return theme.warning }
        return .red
    }
}

// MARK: - History Calendar View

struct HistoryCalendarView: View {
    @Binding var selectedDate: Date
    
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            summary: daySummaryService.summaryForDate(date),
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)
            
            // Selected Day Summary
            if let summary = daySummaryService.summaryForDate(selectedDate) {
                NavigationLink {
                    DayDetailView(summary: summary)
                } label: {
                    DaySummaryRow(summary: summary)
                        .padding()
                        .background(theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthInterval.end || days.count % 7 != 0 {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let summary: DaySummary?
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 36, height: 36)
                } else if let summary = summary {
                    Circle()
                        .fill(scoreColor(summary.score).opacity(0.3))
                        .frame(width: 36, height: 36)
                }
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : (isToday ? theme.primary : .primary))
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return theme.positive }
        if score >= 50 { return theme.warning }
        return .red
    }
}

// MARK: - History Stats View

struct HistoryStatsView: View {
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        List {
            // Streaks
            Section("Streaks") {
                HStack {
                    Label("Current Streak", systemImage: "flame.fill")
                    Spacer()
                    Text("\(daySummaryService.currentStreak()) days")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Label("Best Streak", systemImage: "trophy.fill")
                    Spacer()
                    Text("\(daySummaryService.bestStreak()) days")
                        .fontWeight(.medium)
                        .foregroundColor(.yellow)
                }
                
                HStack {
                    Label("Reading Streak", systemImage: "book.fill")
                    Spacer()
                    Text("\(readingService.readingStreak()) days")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
            
            // Averages
            Section("Averages (Last 7 Days)") {
                HStack {
                    Label("Daily Score", systemImage: "chart.line.uptrend.xyaxis")
                    Spacer()
                    Text("\(Int(daySummaryService.averageScore(lastDays: 7)))%")
                        .foregroundColor(.secondary)
                }
            }
            
            // Reading
            Section("Reading") {
                HStack {
                    Label("Books Finished (2026)", systemImage: "books.vertical.fill")
                    Spacer()
                    Text("\(readingService.booksFinishedThisYear())")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Currently Reading", systemImage: "book.fill")
                    Spacer()
                    Text("\(readingService.currentlyReading.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Day Detail View

struct DayDetailView: View {
    let summary: DaySummary
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        List {
            // Score
            Section {
                HStack {
                    Spacer()
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(scoreColor.opacity(0.2), lineWidth: 12)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: summary.score / 100)
                                .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Text("\(Int(summary.score))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Daily Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            
            // Habits
            Section("Habits") {
                HStack {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                    Spacer()
                    Text("\(summary.habitsCompleted) / \(summary.habitsTotal)")
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: summary.habitCompletionRate)
                    .tint(theme.positive)
            }
            
            // Cleaning
            Section("Cleaning") {
                HStack {
                    Label("Tasks Done", systemImage: "sparkles")
                    Spacer()
                    Text("\(summary.cleaningTasksCompleted) / \(summary.cleaningTasksTotal)")
                        .foregroundColor(.secondary)
                }
            }
            
            // Water
            Section("Water") {
                HStack {
                    Label("Intake", systemImage: "drop.fill")
                    Spacer()
                    Text("\(Int(summary.waterOunces)) / \(Int(summary.waterTarget)) oz")
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: summary.waterCompletionRate)
                    .tint(.blue)
            }
            
            // Reading
            Section("Reading") {
                HStack {
                    Label("Pages Read", systemImage: "book.fill")
                    Spacer()
                    Text("\(summary.pagesRead)")
                        .foregroundColor(.secondary)
                }
                
                if summary.minutesRead > 0 {
                    HStack {
                        Label("Time", systemImage: "clock")
                        Spacer()
                        Text("\(summary.minutesRead) min")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Reflection
            if let note = summary.reflectionNote, !note.isEmpty {
                Section("Reflection") {
                    Text(note)
                        .font(.subheadline)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(summary.formattedDate)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var scoreColor: Color {
        if summary.score >= 80 { return theme.positive }
        if summary.score >= 50 { return theme.warning }
        return .red
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .environmentObject(DaySummaryService())
        .environmentObject(HabitService())
        .environmentObject(CleaningService())
        .environmentObject(WaterService())
        .environmentObject(ReadingService())
        .environmentObject(ThemeService())
}
