//
//  TodayView.swift
//  Project2026
//
//  Main Today dashboard showing daily progress
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var daySummaryService: DaySummaryService
    
    @State private var showingAddWater = false
    @State private var showingLogReading = false
    @State private var showingReflection = false
    @State private var showingMobilityRoutine = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Days Left in 2026 Countdown
                    DaysLeftCountdownCard()
                    
                    // Score Card
                    DailyScoreCard(score: calculateScore())
                    
                    // Water Tracker
                    WaterTrackerCard(
                        current: waterService.todayTotal,
                        target: waterService.dailyTarget,
                        onAddWater: { showingAddWater = true }
                    )
                    
                    // Reading Progress
                    if let book = readingService.primaryBook {
                        ReadingProgressCard(
                            book: book,
                            pagesReadToday: readingService.pagesReadToday(),
                            onLogReading: { showingLogReading = true }
                        )
                    } else {
                        AddBookPromptCard()
                    }
                    
                    // Today's Habits
                    TodayHabitsCard()
                    
                    // Today's Cleaning
                    TodayCleaningCard()
                    
                    // Mobility Routine
                    MobilityRoutineCard(onTap: { showingMobilityRoutine = true })
                    
                    // Reflection
                    ReflectionCard(onTap: { showingReflection = true })
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingAddWater) {
                AddWaterSheet()
            }
            .sheet(isPresented: $showingLogReading) {
                LogReadingSheet()
            }
            .sheet(isPresented: $showingReflection) {
                ReflectionSheet()
            }
            .fullScreenCover(isPresented: $showingMobilityRoutine) {
                MobilityRoutineView()
            }
            .task {
                await updateDaySummary()
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private func calculateScore() -> Double {
        let habitCompletion = habitService.completionRate(for: Date())
        let cleaningCompletion = cleaningService.completionRate(for: Date())
        let waterCompletion = waterService.todayProgress
        let didRead = readingService.didReadToday()
        
        return DaySummary.calculateScore(
            habitCompletion: habitCompletion,
            cleaningCompletion: cleaningCompletion,
            waterCompletion: waterCompletion,
            didRead: didRead
        )
    }
    
    private func updateDaySummary() async {
        await daySummaryService.updateSummary(
            for: Date(),
            habitService: habitService,
            cleaningService: cleaningService,
            waterService: waterService,
            readingService: readingService
        )
    }
}

// MARK: - Daily Score Card

/// Displays the number of days remaining in 2026 as a countdown timer.
struct DaysLeftCountdownCard: View {
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    /// Calculates the number of days remaining in 2026.
    private var daysLeftIn2026: Int {
        let calendar = Calendar.current
        let now = Date()
        
        // End of 2026 (December 31, 2026 at 23:59:59)
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        guard let endOf2026 = calendar.date(from: components) else {
            return 0
        }
        
        // If we're past 2026, return 0
        if now > endOf2026 {
            return 0
        }
        
        // If we're before 2026, calculate days from start of 2026
        var startComponents = DateComponents()
        startComponents.year = 2026
        startComponents.month = 1
        startComponents.day = 1
        
        guard let startOf2026 = calendar.date(from: startComponents) else {
            return 0
        }
        
        // If we're before 2026, show full year
        if now < startOf2026 {
            return 365
        }
        
        // Calculate days remaining from today until end of 2026
        let daysRemaining = calendar.dateComponents([.day], from: now, to: endOf2026).day ?? 0
        return max(0, daysRemaining + 1) // +1 to include today
    }
    
    /// Progress through the year (0.0 to 1.0).
    private var yearProgress: Double {
        let calendar = Calendar.current
        let now = Date()
        
        var startComponents = DateComponents()
        startComponents.year = 2026
        startComponents.month = 1
        startComponents.day = 1
        
        var endComponents = DateComponents()
        endComponents.year = 2026
        endComponents.month = 12
        endComponents.day = 31
        
        guard let startOf2026 = calendar.date(from: startComponents),
              let endOf2026 = calendar.date(from: endComponents) else {
            return 0
        }
        
        if now < startOf2026 { return 0 }
        if now > endOf2026 { return 1.0 }
        
        let totalDays = calendar.dateComponents([.day], from: startOf2026, to: endOf2026).day ?? 365
        let daysPassed = calendar.dateComponents([.day], from: startOf2026, to: now).day ?? 0
        
        return Double(daysPassed) / Double(totalDays)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(theme.primary)
                
                Text("Days Left in 2026")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(daysLeftIn2026)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(theme.primary)
            
            // Progress bar showing year completion
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.primary.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.primary)
                        .frame(width: geometry.size.width * yearProgress, height: 10)
                        .animation(.easeInOut, value: yearProgress)
                }
            }
            .frame(height: 10)
            
            Text(motivationalMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    /// Returns a motivational message based on remaining days.
    private var motivationalMessage: String {
        switch daysLeftIn2026 {
        case 0:
            return "2026 is complete! 🎉"
        case 1...7:
            return "Final stretch! Make every day count! 🏁"
        case 8...30:
            return "Less than a month left! Stay focused! 💪"
        case 31...90:
            return "Keep the momentum going! 🚀"
        case 91...180:
            return "Halfway there! You've got this! ⭐"
        case 181...270:
            return "Building great habits! 📈"
        case 271...365:
            return "A new year of possibilities! 🌟"
        default:
            return "Make 2026 your best year! ✨"
        }
    }
}

// MARK: - Daily Score Card

struct DailyScoreCard: View {
    let score: Double
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Daily Score")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(theme.background, lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: score)
                
                VStack(spacing: 2) {
                    Text("\(Int(score))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(scoreMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var scoreColor: Color {
        if score >= 80 { return theme.positive }
        if score >= 50 { return theme.warning }
        return .red
    }
    
    private var scoreMessage: String {
        if score >= 90 { return "Outstanding! 🌟" }
        if score >= 80 { return "Great progress! 💪" }
        if score >= 60 { return "Keep going! 👍" }
        if score >= 40 { return "Room to improve 📈" }
        return "Let's get started! 🚀"
    }
}

// MARK: - Water Tracker Card

struct WaterTrackerCard: View {
    let current: Double
    let target: Double
    let onAddWater: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var waterService: WaterService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var progress: Double { min(current / target, 1.0) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Water", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("\(Int(current))/\(Int(target))oz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 16)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 16)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 16)
            
            // Quick Add Buttons
            HStack(spacing: 8) {
                ForEach(WaterQuickAdd.allCases, id: \.rawValue) { option in
                    Button {
                        Task {
                            await waterService.addWater(quickAdd: option)
                        }
                    } label: {
                        Text(option.displayText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                Button(action: onAddWater) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Reading Progress Card

struct ReadingProgressCard: View {
    let book: Book
    let pagesReadToday: Int
    let onLogReading: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Reading", systemImage: "book.fill")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
                
                if pagesReadToday > 0 {
                    Label("\(pagesReadToday) pages today", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(theme.positive)
                }
            }
            
            HStack(spacing: 12) {
                // Book Cover Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 60, height: 90)
                    .overlay {
                        Image(systemName: "book.closed.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Progress
                    HStack {
                        ProgressView(value: book.progress)
                            .tint(.orange)
                        
                        Text("\(book.progressPercentage)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(book.pagesRemaining) pages left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 90)
            
            HStack(spacing: 12) {
                Button(action: onLogReading) {
                    Label("Log Reading", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
                
                OpenAudibleButton()
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Open Audible Button

/// Button that opens the Audible app or falls back to App Store.
struct OpenAudibleButton: View {
    @Environment(\.openURL) private var openURL
    
    private let audibleScheme = "audible://"
    private let audibleAppStore = URL(string: "https://apps.apple.com/app/audible/id379693831")!
    
    var body: some View {
        Button {
            openAudible()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "headphones")
                Text("Audible")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.purple.opacity(0.1))
            .foregroundColor(.purple)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func openAudible() {
        if let url = URL(string: audibleScheme),
           UIApplication.shared.canOpenURL(url) {
            openURL(url)
        } else {
            // Audible not installed, open App Store
            openURL(audibleAppStore)
        }
    }
}

// MARK: - Add Book Prompt Card

struct AddBookPromptCard: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var showingAddBook = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundColor(.orange.opacity(0.5))
            
            Text("No book in progress")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                showingAddBook = true
            } label: {
                Label("Add a Book", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingAddBook) {
            AddBookSheet()
        }
    }
}

// MARK: - Today Habits Card

struct TodayHabitsCard: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var habitService: HabitService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var todayHabits: [HabitTemplate] { habitService.habitsForToday() }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Habits", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(theme.primary)
                
                Spacer()
                
                Text("\(completedCount)/\(todayHabits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if todayHabits.isEmpty {
                Text("No habits for today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                // Group by category
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    let categoryHabits = todayHabits.filter { $0.category == category }
                    if !categoryHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            ForEach(categoryHabits) { habit in
                                HabitRowView(habit: habit)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var completedCount: Int {
        todayHabits.filter { habit in
            habitService.logForHabit(habit.id, on: Date())?.completed ?? false
        }.count
    }
}

// MARK: - Habit Row View

struct HabitRowView: View {
    let habit: HabitTemplate
    
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var log: HabitLog? { habitService.logForHabit(habit.id, on: Date()) }
    private var isCompleted: Bool { log?.completed ?? false }
    
    var body: some View {
        HStack {
            Button {
                Task {
                    await habitService.toggleHabitCompletion(habit)
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? theme.positive : .secondary)
            }
            
            Text(habit.title)
                .font(.subheadline)
                .strikethrough(isCompleted)
                .foregroundColor(isCompleted ? .secondary : .primary)
            
            Spacer()
            
            if habit.inputType == .numeric, let target = habit.targetValue, let unit = habit.unit {
                if let value = log?.numericValue {
                    Text("\(Int(value))/\(Int(target))\(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(Int(target))\(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if case .weekly(let days) = habit.frequency {
                let completed = habitService.weeklyCompletionCount(for: habit)
                Text("\(completed)/\(days)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Today Cleaning Card

struct TodayCleaningCard: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var cleaningService: CleaningService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var todayTasks: [CleaningTask] { cleaningService.tasksForToday() }
    
    /// Returns unique areas from today's tasks in order.
    private var areas: [String] {
        var seen = Set<String>()
        return todayTasks.compactMap { task in
            if seen.contains(task.area) { return nil }
            seen.insert(task.area)
            return task.area
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Cleaning", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text("\(completedCount)/\(todayTasks.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if todayTasks.isEmpty {
                Text("All caught up! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                // Group by area
                ForEach(areas, id: \.self) { area in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(area)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(todayTasks.filter { $0.area == area }) { task in
                            CleaningTaskRowView(task: task)
                        }
                    }
                }
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var completedCount: Int {
        todayTasks.filter { task in
            cleaningService.isTaskCompleted(task, on: Date())
        }.count
    }
}

// MARK: - Cleaning Task Row View

struct CleaningTaskRowView: View {
    let task: CleaningTask
    
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var isCompleted: Bool { cleaningService.isTaskCompleted(task, on: Date()) }
    
    var body: some View {
        HStack {
            Button {
                Task {
                    await cleaningService.completeTask(task)
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? theme.positive : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    if task.isOverdue {
                        Text("Overdue")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    
                    if let minutes = task.estimatedMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if !isCompleted {
                // Defer button - more visible than menu
                Button {
                    Task {
                        await cleaningService.snoozeTaskForOneDay(task)
                    }
                } label: {
                    Text("Defer")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Mobility Routine Card

struct MobilityRoutineCard: View {
    let onTap: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Bike Mobility Routine", systemImage: "figure.strengthtraining.traditional")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("10 exercises • ~12 minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(theme.card)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reflection Card

struct ReflectionCard: View {
    let onTap: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var daySummaryService: DaySummaryService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var todaySummary: DaySummary? { daySummaryService.todaySummary() }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Daily Reflection", systemImage: "pencil.and.outline")
                        .font(.headline)
                        .foregroundColor(.teal)
                    
                    if let note = todaySummary?.reflectionNote, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("Tap to add today's reflection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(theme.card)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environmentObject(ThemeService())
        .environmentObject(HabitService())
        .environmentObject(CleaningService())
        .environmentObject(WaterService())
        .environmentObject(ReadingService())
        .environmentObject(DaySummaryService())
}
