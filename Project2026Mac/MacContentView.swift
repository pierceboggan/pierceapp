//
//  MacContentView.swift
//  Project2026Mac
//
//  Main macOS content view with sidebar navigation
//

import SwiftUI

/// Main content view for macOS with sidebar navigation
struct MacContentView: View {
    @EnvironmentObject var themeService: ThemeServiceMac
    @EnvironmentObject var habitService: HabitServiceMac
    @EnvironmentObject var cleaningService: CleaningServiceMac
    @EnvironmentObject var waterService: WaterServiceMac
    @EnvironmentObject var readingService: ReadingServiceMac
    @EnvironmentObject var daySummaryService: DaySummaryServiceMac
    @EnvironmentObject var workoutService: WorkoutServiceMac
    
    @State private var selectedSection: NavigationSection? = .today
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum NavigationSection: String, CaseIterable, Identifiable {
        case today = "Today"
        case fitness = "Fitness"
        case habits = "Habits"
        case cleaning = "Cleaning"
        case history = "History"
        case settings = "Settings"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .fitness: return "figure.run"
            case .habits: return "checkmark.circle.fill"
            case .cleaning: return "sparkles"
            case .history: return "calendar"
            case .settings: return "gear"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List(NavigationSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.rawValue, systemImage: section.icon)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Project 2026")
            .frame(minWidth: 200)
        } detail: {
            // Main content
            Group {
                switch selectedSection {
                case .today:
                    MacTodayView()
                case .fitness:
                    MacFitnessView()
                case .habits:
                    MacHabitsView()
                case .cleaning:
                    MacCleaningView()
                case .history:
                    MacHistoryView()
                case .settings:
                    MacSettingsView()
                case .none:
                    MacTodayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// MARK: - Today View

struct MacTodayView: View {
    @EnvironmentObject var habitService: HabitServiceMac
    @EnvironmentObject var waterService: WaterServiceMac
    @EnvironmentObject var readingService: ReadingServiceMac
    @EnvironmentObject var cleaningService: CleaningServiceMac
    @EnvironmentObject var daySummaryService: DaySummaryServiceMac
    
    @State private var showingAddWater = false
    @State private var showingReflection = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with date and score
                headerSection
                
                // Quick stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    QuickStatCard(
                        title: "Habits",
                        value: "\(habitService.completedCount(for: Date()))/\(habitService.habitsForToday().count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    QuickStatCard(
                        title: "Water",
                        value: "\(Int(waterService.todayTotal))oz",
                        icon: "drop.fill",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        title: "Reading",
                        value: readingService.didReadToday() ? "Done" : "Not yet",
                        icon: "book.fill",
                        color: .orange
                    )
                    
                    QuickStatCard(
                        title: "Cleaning",
                        value: "\(cleaningService.completedCount(for: Date()))/\(cleaningService.tasksForToday().count)",
                        icon: "sparkles",
                        color: .purple
                    )
                }
                
                // Today's habits
                GroupBox("Today's Habits") {
                    LazyVStack(spacing: 8) {
                        ForEach(habitService.habitsForToday()) { habit in
                            HabitRowMac(habit: habit, habitService: habitService)
                        }
                        
                        if habitService.habitsForToday().isEmpty {
                            Text("No habits scheduled for today")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                }
                
                // Quick actions
                HStack(spacing: 16) {
                    Button {
                        showingAddWater = true
                    } label: {
                        Label("Log Water", systemImage: "drop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        showingReflection = true
                    } label: {
                        Label("Daily Reflection", systemImage: "pencil.and.outline")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
        .navigationTitle("Today")
        .sheet(isPresented: $showingAddWater) {
            AddWaterSheetMac(waterService: waterService)
        }
        .sheet(isPresented: $showingReflection) {
            ReflectionSheetMac(daySummaryService: daySummaryService)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Date(), format: .dateTime.weekday(.wide).month().day())
                    .font(.title)
                    .fontWeight(.bold)
                Text("Keep up the great work!")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: currentScore / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(currentScore))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
    
    private var currentScore: Double {
        DaySummary.calculateScore(
            habitCompletion: habitService.completionRate(for: Date()),
            cleaningCompletion: cleaningService.completionRate(for: Date()),
            waterCompletion: waterService.todayProgress,
            didRead: readingService.didReadToday()
        )
    }
    
    private var scoreColor: Color {
        if currentScore >= 80 { return .green }
        if currentScore >= 50 { return .orange }
        return .red
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Habit Row

struct HabitRowMac: View {
    let habit: Habit
    let habitService: HabitServiceMac
    
    var body: some View {
        HStack {
            Button {
                habitService.toggleCompletion(for: habit, on: Date())
            } label: {
                Image(systemName: habitService.isCompleted(habit, on: Date()) ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habitService.isCompleted(habit, on: Date()) ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(habit.title)
                .strikethrough(habitService.isCompleted(habit, on: Date()))
            
            Spacer()
            
            if let streak = habit.currentStreak, streak > 0 {
                Label("\(streak)", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Fitness View

struct MacFitnessView: View {
    @EnvironmentObject var workoutService: WorkoutServiceMac
    @State private var showingMobilityRoutine = false
    @State private var showingAddWorkout = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Mobility section
                GroupBox("Mobility Routine") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bike-Mobility & Knee Health")
                                .font(.headline)
                            Text("10 exercises • ~12 minutes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Start Routine") {
                            showingMobilityRoutine = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
                
                // Workouts section
                GroupBox("Recent Workouts") {
                    LazyVStack(spacing: 8) {
                        ForEach(workoutService.recentWorkouts(limit: 10)) { workout in
                            WorkoutRowMac(workout: workout)
                        }
                        
                        if workoutService.recentWorkouts(limit: 10).isEmpty {
                            Text("No workouts logged yet")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                }
                
                Button {
                    showingAddWorkout = true
                } label: {
                    Label("Log Workout", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
        }
        .navigationTitle("Fitness")
        .sheet(isPresented: $showingMobilityRoutine) {
            MacMobilityRoutineView()
                .frame(minWidth: 600, minHeight: 500)
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutSheetMac(workoutService: workoutService)
        }
    }
}

struct WorkoutRowMac: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.type.icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(workout.type.rawValue)
                    .fontWeight(.medium)
                Text(workout.date, format: .dateTime.month().day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let duration = workout.duration {
                Text("\(Int(duration)) min")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Habits View

struct MacHabitsView: View {
    @EnvironmentObject var habitService: HabitServiceMac
    @State private var showingAddHabit = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Today's habits
                GroupBox("Today's Habits") {
                    LazyVStack(spacing: 8) {
                        ForEach(habitService.habitsForToday()) { habit in
                            HabitRowMac(habit: habit, habitService: habitService)
                        }
                    }
                }
                
                // All habits
                GroupBox("All Habits") {
                    LazyVStack(spacing: 8) {
                        ForEach(habitService.allHabits) { habit in
                            HStack {
                                Text(habit.title)
                                Spacer()
                                Text(habit.frequency.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Button {
                    showingAddHabit = true
                } label: {
                    Label("Add Habit", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
        }
        .navigationTitle("Habits")
        .sheet(isPresented: $showingAddHabit) {
            AddHabitSheetMac(habitService: habitService)
        }
    }
}

// MARK: - Cleaning View

struct MacCleaningView: View {
    @EnvironmentObject var cleaningService: CleaningServiceMac
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GroupBox("Today's Tasks") {
                    LazyVStack(spacing: 8) {
                        ForEach(cleaningService.tasksForToday()) { task in
                            HStack {
                                Button {
                                    cleaningService.toggleCompletion(for: task, on: Date())
                                } label: {
                                    Image(systemName: cleaningService.isCompleted(task, on: Date()) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(cleaningService.isCompleted(task, on: Date()) ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                Text(task.title)
                                    .strikethrough(cleaningService.isCompleted(task, on: Date()))
                                
                                Spacer()
                                
                                Text(task.roomDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if cleaningService.tasksForToday().isEmpty {
                            Text("No cleaning tasks for today")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Cleaning")
    }
}

// MARK: - History View

struct MacHistoryView: View {
    @EnvironmentObject var daySummaryService: DaySummaryServiceMac
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GroupBox("Recent Days") {
                    LazyVStack(spacing: 8) {
                        ForEach(daySummaryService.recentSummaries(limit: 30)) { summary in
                            HStack {
                                Text(summary.date, format: .dateTime.weekday().month().day())
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Label("\(Int(summary.habitCompletionRate * 100))%", systemImage: "checkmark.circle")
                                        .foregroundStyle(.green)
                                    
                                    Label("\(Int(summary.waterCompletionRate * 100))%", systemImage: "drop.fill")
                                        .foregroundStyle(.blue)
                                    
                                    Image(systemName: summary.didRead ? "book.fill" : "book")
                                        .foregroundStyle(summary.didRead ? .orange : .secondary)
                                }
                                .font(.caption)
                                
                                // Score
                                Text("\(Int(summary.overallScore))%")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(summary.overallScore >= 80 ? .green : summary.overallScore >= 50 ? .orange : .red)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if daySummaryService.recentSummaries(limit: 30).isEmpty {
                            Text("No history yet")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("History")
    }
}

// MARK: - Settings View

struct MacSettingsView: View {
    @EnvironmentObject var themeService: ThemeServiceMac
    
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: Binding(
                    get: { themeService.currentTheme },
                    set: { themeService.selectTheme($0) }
                )) {
                    ForEach(themeService.availableThemes) { theme in
                        Text(theme.name).tag(theme)
                    }
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "1")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(minWidth: 400, minHeight: 300)
    }
}

// MARK: - Sheet Views

struct AddWaterSheetMac: View {
    @ObservedObject var waterService: WaterServiceMac
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double = 8
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log Water")
                .font(.title2)
                .fontWeight(.bold)
            
            Stepper("Amount: \(Int(amount)) oz", value: $amount, in: 1...64)
            
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Log") {
                    waterService.logWater(amount: amount)
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 300)
    }
}

struct ReflectionSheetMac: View {
    @ObservedObject var daySummaryService: DaySummaryServiceMac
    @Environment(\.dismiss) private var dismiss
    @State private var reflection: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Daily Reflection")
                .font(.title2)
                .fontWeight(.bold)
            
            TextEditor(text: $reflection)
                .frame(height: 150)
                .border(Color.gray.opacity(0.3))
            
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Save") {
                    daySummaryService.saveReflection(reflection, for: Date())
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}

struct AddHabitSheetMac: View {
    @ObservedObject var habitService: HabitServiceMac
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var frequency: HabitFrequency = .daily
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Habit")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Habit name", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Picker("Frequency", selection: $frequency) {
                ForEach(HabitFrequency.allCases, id: \.self) { freq in
                    Text(freq.description).tag(freq)
                }
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Add") {
                    habitService.addHabit(title: title, frequency: frequency)
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 350)
    }
}

struct AddWorkoutSheetMac: View {
    @ObservedObject var workoutService: WorkoutServiceMac
    @Environment(\.dismiss) private var dismiss
    @State private var type: WorkoutType = .cycling
    @State private var duration: Double = 30
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log Workout")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Type", selection: $type) {
                ForEach(WorkoutType.allCases, id: \.self) { t in
                    Label(t.rawValue, systemImage: t.icon).tag(t)
                }
            }
            
            Stepper("Duration: \(Int(duration)) min", value: $duration, in: 5...300, step: 5)
            
            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Log") {
                    workoutService.logWorkout(type: type, duration: duration, notes: notes.isEmpty ? nil : notes)
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 350)
    }
}

#Preview {
    MacContentView()
        .environmentObject(ThemeServiceMac())
        .environmentObject(HabitServiceMac())
        .environmentObject(CleaningServiceMac())
        .environmentObject(WaterServiceMac())
        .environmentObject(ReadingServiceMac())
        .environmentObject(DaySummaryServiceMac())
        .environmentObject(WorkoutServiceMac())
}
