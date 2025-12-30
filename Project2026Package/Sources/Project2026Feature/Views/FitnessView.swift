//
//  FitnessView.swift
//  Project2026
//
//  Dedicated view for Workouts and Mobility tracking
//

import SwiftUI

/// Main fitness tab combining workout tracking and mobility routines.
public struct FitnessView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var workoutService: WorkoutService
    
    @State private var showingAddWorkout = false
    @State private var showingMobilityRoutine = false
    @State private var selectedSegment = 0
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Summary Card
                    WeeklySummaryCard()
                    
                    // Quick Actions
                    HStack(spacing: 12) {
                        QuickActionButton(
                            title: "Log Workout",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            showingAddWorkout = true
                        }
                        
                        QuickActionButton(
                            title: "Start Mobility",
                            icon: "figure.strengthtraining.traditional",
                            color: .orange
                        ) {
                            showingMobilityRoutine = true
                        }
                    }
                    
                    // Segment Picker
                    Picker("View", selection: $selectedSegment) {
                        Text("Workouts").tag(0)
                        Text("Mobility").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content based on segment
                    if selectedSegment == 0 {
                        WorkoutsListSection()
                    } else {
                        MobilitySection()
                    }
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Fitness")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutSheet()
            }
            .fullScreenCover(isPresented: $showingMobilityRoutine) {
                MobilityRoutineView()
                    .onDisappear {
                        // Log mobility completion when view is dismissed
                        // This could be enhanced to only log if actually completed
                    }
            }
        }
    }
    
    public init() {}
}

// MARK: - Weekly Summary Card

public struct WeeklySummaryCard: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var workoutService: WorkoutService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var summary: WeeklyWorkoutSummary { workoutService.weeklySummary() }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.headline)
                Spacer()
                Text(weekDateRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 24) {
                StatItem(
                    value: "\(summary.totalWorkouts)",
                    label: "Workouts",
                    target: "/ 6",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatItem(
                    value: "\(summary.mobilitySessionsCompleted)",
                    label: "Mobility",
                    target: "/ 6",
                    icon: "figure.flexibility",
                    color: .purple
                )
                
                StatItem(
                    value: summary.formattedTotalDuration,
                    label: "Duration",
                    target: nil,
                    icon: "clock.fill",
                    color: .blue
                )
                
                if summary.totalTSS > 0 {
                    StatItem(
                        value: "\(summary.totalTSS)",
                        label: "TSS",
                        target: nil,
                        icon: "bolt.fill",
                        color: .yellow
                    )
                }
            }
            
            // Progress bars
            VStack(spacing: 8) {
                ProgressRow(
                    label: "Workout Goal",
                    current: summary.totalWorkouts,
                    target: 6,
                    color: .orange
                )
                
                ProgressRow(
                    label: "Mobility Goal",
                    current: summary.mobilitySessionsCompleted,
                    target: 6,
                    color: .purple
                )
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? Date()
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let value: String
    let label: String
    let target: String?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                if let target = target {
                    Text(target)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Progress Row

struct ProgressRow: View {
    let label: String
    let current: Int
    let target: Int
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(current)/\(target)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.card)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workouts List Section

struct WorkoutsListSection: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var workoutService: WorkoutService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Workouts")
                .font(.headline)
                .padding(.horizontal)
            
            if workoutService.workouts.isEmpty {
                EmptyWorkoutsView()
            } else {
                ForEach(workoutService.recentWorkouts(limit: 10)) { workout in
                    WorkoutRowView(workout: workout)
                }
            }
        }
    }
}

// MARK: - Empty Workouts View

struct EmptyWorkoutsView: View {
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No workouts yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Log your first workout to start tracking")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(theme.card)
        .cornerRadius(12)
    }
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
    let workout: Workout
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Icon
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: workout.type.icon)
                    .font(.title3)
                    .foregroundColor(typeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label(workout.formattedDuration, systemImage: "clock")
                    
                    Label(workout.intensity.rawValue, systemImage: workout.intensity.icon)
                    
                    if let tss = workout.tss {
                        Label("\(tss) TSS", systemImage: "bolt.fill")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(workout.type.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(typeColor.opacity(0.1))
                    .foregroundColor(typeColor)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(12)
    }
    
    private var typeColor: Color {
        switch workout.type.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "cyan": return .cyan
        case "brown": return .brown
        case "mint": return .mint
        default: return .gray
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(workout.date) {
            return "Today"
        } else if calendar.isDateInYesterday(workout.date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: workout.date)
        }
    }
}

// MARK: - Mobility Section

struct MobilitySection: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var workoutService: WorkoutService
    
    @State private var showingMobilityRoutine = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Mobility Routine Card
            MobilityRoutineInfoCard(onStart: { showingMobilityRoutine = true })
            
            // Recent Mobility Sessions
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal)
            
            if workoutService.mobilityLogs.isEmpty {
                EmptyMobilityView()
            } else {
                ForEach(workoutService.mobilityLogs.prefix(10)) { log in
                    MobilityLogRow(log: log)
                }
            }
        }
        .fullScreenCover(isPresented: $showingMobilityRoutine) {
            MobilityRoutineView()
        }
    }
}

// MARK: - Mobility Routine Info Card

struct MobilityRoutineInfoCard: View {
    let onStart: () -> Void
    
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var workoutService: WorkoutService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bike-Mobility & Knee Health")
                        .font(.headline)
                    
                    Text("10 exercises • ~12 minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if workoutService.didMobilityToday() {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(theme.positive)
                }
            }
            
            // Exercise preview
            HStack(spacing: 8) {
                ForEach(["Cat-Cow", "Hip Flexor", "Hamstring", "Glute Med"], id: \.self) { name in
                    Text(name)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            
            Button(action: onStart) {
                Label(workoutService.didMobilityToday() ? "Do Again" : "Start Routine", systemImage: "play.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Empty Mobility View

struct EmptyMobilityView: View {
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.flexibility")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No mobility sessions yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Complete your first routine above")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(theme.card)
        .cornerRadius(12)
    }
}

// MARK: - Mobility Log Row

struct MobilityLogRow: View {
    let log: MobilityLog
    
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "figure.flexibility")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.routineName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label("\(log.durationMinutes) min", systemImage: "clock")
                    
                    Label("\(log.exercisesCompleted)/\(log.totalExercises)", systemImage: "checkmark.circle")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if log.isComplete {
                    Text("Complete")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.positive.opacity(0.1))
                        .foregroundColor(theme.positive)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(theme.card)
        .cornerRadius(12)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(log.date) {
            return "Today"
        } else if calendar.isDateInYesterday(log.date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: log.date)
        }
    }
}

// MARK: - Add Workout Sheet

public struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workoutService: WorkoutService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var type: WorkoutType = .cycling
    @State private var title: String = ""
    @State private var durationMinutes: String = ""
    @State private var intensity: WorkoutIntensity = .moderate
    @State private var tss: String = ""
    @State private var notes: String = ""
    @State private var selectedDate: Date = Date()
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Workout Type") {
                    Picker("Type", selection: $type) {
                        ForEach(WorkoutType.allCases, id: \.self) { workoutType in
                            Label(workoutType.rawValue, systemImage: workoutType.icon)
                                .tag(workoutType)
                        }
                    }
                    .onChange(of: type) { _, newType in
                        if title.isEmpty || WorkoutType.allCases.map(\.rawValue).contains(title) {
                            title = newType.rawValue
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        TextField("60", text: $durationMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Intensity", selection: $intensity) {
                        ForEach(WorkoutIntensity.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                if type == .cycling {
                    Section("Cycling Metrics (Optional)") {
                        HStack {
                            Text("TSS")
                            Spacer()
                            TextField("0", text: $tss)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                        }
                        
                        Text("TSS will be estimated from duration & intensity if not provided")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("How did it feel?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                title = type.rawValue
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && (Int(durationMinutes) ?? 0) > 0
    }
    
    private func saveWorkout() {
        guard let duration = Int(durationMinutes), duration > 0 else { return }
        
        let workout = Workout(
            type: type,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: selectedDate,
            durationMinutes: duration,
            intensity: intensity,
            notes: notes.isEmpty ? nil : notes,
            tss: Int(tss)
        )
        
        Task {
            await workoutService.addWorkout(workout)
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    FitnessView()
        .environmentObject(ThemeService())
        .environmentObject(WorkoutService())
}
