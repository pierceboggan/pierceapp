//
//  MacServices.swift
//  Project2026Mac
//
//  Service classes for macOS app (mirrors iOS services)
//

import SwiftUI
import Foundation

// MARK: - Theme

struct AppTheme: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let accentColorHex: String
    let isDark: Bool?
    
    var colorScheme: ColorScheme? {
        guard let isDark = isDark else { return nil }
        return isDark ? .dark : .light
    }
    
    static let `default` = AppTheme(
        id: UUID(),
        name: "System",
        accentColorHex: "#007AFF",
        isDark: nil
    )
    
    static let allThemes: [AppTheme] = [
        .default,
        AppTheme(id: UUID(), name: "Light", accentColorHex: "#007AFF", isDark: false),
        AppTheme(id: UUID(), name: "Dark", accentColorHex: "#007AFF", isDark: true),
        AppTheme(id: UUID(), name: "Ocean", accentColorHex: "#34C759", isDark: true),
        AppTheme(id: UUID(), name: "Sunset", accentColorHex: "#FF9500", isDark: false)
    ]
}

// MARK: - Theme Service

@MainActor
class ThemeServiceMac: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet { saveTheme() }
    }
    @Published var availableThemes: [AppTheme]
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    init() {
        self.availableThemes = AppTheme.allThemes
        if let data = userDefaults.data(forKey: themeKey),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .default
        }
    }
    
    func selectTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    private func saveTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            userDefaults.set(data, forKey: themeKey)
        }
    }
}

// MARK: - Habit

struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var frequency: HabitFrequency
    var createdAt: Date
    var completedDates: [Date]
    var currentStreak: Int?
    
    init(id: UUID = UUID(), title: String, frequency: HabitFrequency, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.frequency = frequency
        self.createdAt = createdAt
        self.completedDates = []
        self.currentStreak = 0
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily
    case weekdays
    case weekends
    case weekly
    
    var description: String {
        switch self {
        case .daily: return "Daily"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .weekly: return "Weekly"
        }
    }
}

// MARK: - Habit Service

@MainActor
class HabitServiceMac: ObservableObject {
    @Published var allHabits: [Habit] = []
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "habits"
    
    init() {
        loadHabits()
    }
    
    func habitsForToday() -> [Habit] {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let isWeekend = weekday == 1 || weekday == 7
        
        return allHabits.filter { habit in
            switch habit.frequency {
            case .daily: return true
            case .weekdays: return !isWeekend
            case .weekends: return isWeekend
            case .weekly: return weekday == 2 // Monday
            }
        }
    }
    
    func completedCount(for date: Date) -> Int {
        habitsForToday().filter { isCompleted($0, on: date) }.count
    }
    
    func completionRate(for date: Date) -> Double {
        let todayHabits = habitsForToday()
        guard !todayHabits.isEmpty else { return 1.0 }
        return Double(completedCount(for: date)) / Double(todayHabits.count)
    }
    
    func isCompleted(_ habit: Habit, on date: Date) -> Bool {
        habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func toggleCompletion(for habit: Habit, on date: Date) {
        guard let index = allHabits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        if isCompleted(habit, on: date) {
            allHabits[index].completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
        } else {
            allHabits[index].completedDates.append(date)
        }
        saveHabits()
    }
    
    func addHabit(title: String, frequency: HabitFrequency) {
        let habit = Habit(title: title, frequency: frequency)
        allHabits.append(habit)
        saveHabits()
    }
    
    private func loadHabits() {
        if let data = userDefaults.data(forKey: habitsKey),
           let habits = try? JSONDecoder().decode([Habit].self, from: data) {
            self.allHabits = habits
        }
    }
    
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(allHabits) {
            userDefaults.set(data, forKey: habitsKey)
        }
    }
}

// MARK: - Cleaning Task

struct CleaningTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var room: String
    var frequency: CleaningFrequency
    var completedDates: [Date]
    
    var roomDescription: String { room }
    
    init(id: UUID = UUID(), title: String, room: String, frequency: CleaningFrequency = .daily) {
        self.id = id
        self.title = title
        self.room = room
        self.frequency = frequency
        self.completedDates = []
    }
}

enum CleaningFrequency: String, Codable {
    case daily, weekly, monthly
}

// MARK: - Cleaning Service

@MainActor
class CleaningServiceMac: ObservableObject {
    @Published var tasks: [CleaningTask] = []
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "cleaningTasks"
    
    init() {
        loadTasks()
        if tasks.isEmpty {
            tasks = defaultTasks()
            saveTasks()
        }
    }
    
    func tasksForToday() -> [CleaningTask] {
        tasks.filter { $0.frequency == .daily }
    }
    
    func completedCount(for date: Date) -> Int {
        tasksForToday().filter { isCompleted($0, on: date) }.count
    }
    
    func completionRate(for date: Date) -> Double {
        let todayTasks = tasksForToday()
        guard !todayTasks.isEmpty else { return 1.0 }
        return Double(completedCount(for: date)) / Double(todayTasks.count)
    }
    
    func isCompleted(_ task: CleaningTask, on date: Date) -> Bool {
        task.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func toggleCompletion(for task: CleaningTask, on date: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        if isCompleted(task, on: date) {
            tasks[index].completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
        } else {
            tasks[index].completedDates.append(date)
        }
        saveTasks()
    }
    
    private func defaultTasks() -> [CleaningTask] {
        [
            CleaningTask(title: "Make bed", room: "Bedroom"),
            CleaningTask(title: "Kitchen reset", room: "Kitchen"),
            CleaningTask(title: "Wipe counters", room: "Kitchen"),
            CleaningTask(title: "Quick tidy", room: "Living Room")
        ]
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let tasks = try? JSONDecoder().decode([CleaningTask].self, from: data) {
            self.tasks = tasks
        }
    }
    
    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            userDefaults.set(data, forKey: tasksKey)
        }
    }
}

// MARK: - Water Log

struct WaterLog: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let date: Date
    
    init(id: UUID = UUID(), amount: Double, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}

// MARK: - Water Service

@MainActor
class WaterServiceMac: ObservableObject {
    @Published var logs: [WaterLog] = []
    @Published var dailyTarget: Double = 100
    
    private let userDefaults = UserDefaults.standard
    private let logsKey = "waterLogs"
    
    var todayTotal: Double {
        logs.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var todayProgress: Double {
        min(todayTotal / dailyTarget, 1.0)
    }
    
    init() {
        loadLogs()
    }
    
    func logWater(amount: Double) {
        let log = WaterLog(amount: amount)
        logs.append(log)
        saveLogs()
    }
    
    private func loadLogs() {
        if let data = userDefaults.data(forKey: logsKey),
           let logs = try? JSONDecoder().decode([WaterLog].self, from: data) {
            self.logs = logs
        }
    }
    
    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            userDefaults.set(data, forKey: logsKey)
        }
    }
}

// MARK: - Reading Service

@MainActor
class ReadingServiceMac: ObservableObject {
    @Published var readDates: [Date] = []
    
    private let userDefaults = UserDefaults.standard
    private let readKey = "readDates"
    
    init() {
        loadData()
    }
    
    func didReadToday() -> Bool {
        readDates.contains { Calendar.current.isDateInToday($0) }
    }
    
    func markRead(for date: Date = Date()) {
        if !readDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            readDates.append(date)
            saveData()
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: readKey),
           let dates = try? JSONDecoder().decode([Date].self, from: data) {
            self.readDates = dates
        }
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(readDates) {
            userDefaults.set(data, forKey: readKey)
        }
    }
}

// MARK: - Day Summary

struct DaySummary: Identifiable, Codable {
    let id: UUID
    let date: Date
    var habitCompletionRate: Double
    var cleaningCompletionRate: Double
    var waterCompletionRate: Double
    var didRead: Bool
    var reflection: String?
    
    var overallScore: Double {
        DaySummary.calculateScore(
            habitCompletion: habitCompletionRate,
            cleaningCompletion: cleaningCompletionRate,
            waterCompletion: waterCompletionRate,
            didRead: didRead
        )
    }
    
    static func calculateScore(habitCompletion: Double, cleaningCompletion: Double, waterCompletion: Double, didRead: Bool) -> Double {
        let habitWeight = 0.4
        let cleaningWeight = 0.2
        let waterWeight = 0.2
        let readingWeight = 0.2
        
        let readingScore = didRead ? 1.0 : 0.0
        
        return (habitCompletion * habitWeight +
                cleaningCompletion * cleaningWeight +
                waterCompletion * waterWeight +
                readingScore * readingWeight) * 100
    }
}

// MARK: - Day Summary Service

@MainActor
class DaySummaryServiceMac: ObservableObject {
    @Published var summaries: [DaySummary] = []
    
    private let userDefaults = UserDefaults.standard
    private let summariesKey = "daySummaries"
    
    init() {
        loadSummaries()
    }
    
    func recentSummaries(limit: Int) -> [DaySummary] {
        Array(summaries.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    func saveReflection(_ reflection: String, for date: Date) {
        if let index = summaries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            summaries[index].reflection = reflection
        } else {
            let summary = DaySummary(
                id: UUID(),
                date: date,
                habitCompletionRate: 0,
                cleaningCompletionRate: 0,
                waterCompletionRate: 0,
                didRead: false,
                reflection: reflection
            )
            summaries.append(summary)
        }
        saveSummaries()
    }
    
    private func loadSummaries() {
        if let data = userDefaults.data(forKey: summariesKey),
           let summaries = try? JSONDecoder().decode([DaySummary].self, from: data) {
            self.summaries = summaries
        }
    }
    
    private func saveSummaries() {
        if let data = try? JSONEncoder().encode(summaries) {
            userDefaults.set(data, forKey: summariesKey)
        }
    }
}

// MARK: - Workout

struct Workout: Identifiable, Codable {
    let id: UUID
    let type: WorkoutType
    let date: Date
    var duration: Double?
    var distance: Double?
    var notes: String?
    
    init(id: UUID = UUID(), type: WorkoutType, date: Date = Date(), duration: Double? = nil, distance: Double? = nil, notes: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.duration = duration
        self.distance = distance
        self.notes = notes
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case cycling = "Cycling"
    case running = "Running"
    case swimming = "Swimming"
    case strength = "Strength"
    case yoga = "Yoga"
    case mobility = "Mobility"
    case walking = "Walking"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .cycling: return "bicycle"
        case .running: return "figure.run"
        case .swimming: return "figure.pool.swim"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .mobility: return "figure.flexibility"
        case .walking: return "figure.walk"
        case .other: return "sportscourt.fill"
        }
    }
}

// MARK: - Workout Service

@MainActor
class WorkoutServiceMac: ObservableObject {
    @Published var workouts: [Workout] = []
    
    private let userDefaults = UserDefaults.standard
    private let workoutsKey = "workouts"
    
    init() {
        loadWorkouts()
    }
    
    func recentWorkouts(limit: Int) -> [Workout] {
        Array(workouts.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    func logWorkout(type: WorkoutType, duration: Double?, notes: String?) {
        let workout = Workout(type: type, duration: duration, notes: notes)
        workouts.append(workout)
        saveWorkouts()
    }
    
    private func loadWorkouts() {
        if let data = userDefaults.data(forKey: workoutsKey),
           let workouts = try? JSONDecoder().decode([Workout].self, from: data) {
            self.workouts = workouts
        }
    }
    
    private func saveWorkouts() {
        if let data = try? JSONEncoder().encode(workouts) {
            userDefaults.set(data, forKey: workoutsKey)
        }
    }
}

// MARK: - Mobility Exercise (shared)

struct MobilityExercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let why: String
    let howToDoIt: [String]
    let cues: [String]
    let durationSeconds: Int
    let repsOrHoldDescription: String?
    
    init(id: UUID = UUID(), name: String, why: String, howToDoIt: [String], cues: [String], durationSeconds: Int, repsOrHoldDescription: String? = nil) {
        self.id = id
        self.name = name
        self.why = why
        self.howToDoIt = howToDoIt
        self.cues = cues
        self.durationSeconds = durationSeconds
        self.repsOrHoldDescription = repsOrHoldDescription
    }
}

struct MobilityRoutine {
    let title: String
    let exercises: [MobilityExercise]
    
    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.durationSeconds }
    }
    
    static let bikeRoutine = MobilityRoutine(
        title: "Bike-Mobility & Knee Health Routine",
        exercises: [
            MobilityExercise(
                name: "Cat–Cow + Thoracic Reach",
                why: "Mobilizes spine for better aero position and breathing.",
                howToDoIt: ["On hands & knees", "Cow: Inhale, drop belly, lift chest", "Cat: Exhale, round spine up", "Repeat 6 slow cycles"],
                cues: ["Move from mid-back", "Keep core engaged", "Move fluidly"],
                durationSeconds: 90,
                repsOrHoldDescription: "6 cycles + 3 reps per side"
            ),
            MobilityExercise(
                name: "Hip Flexor / Psoas Lunge Stretch",
                why: "Releases tight hip flexors for better posture.",
                howToDoIt: ["Step into half-kneeling lunge", "Tuck pelvis, squeeze glute", "Lean forward gently", "Hold 30 sec each side"],
                cues: ["Keep spine neutral", "Glutes squeezed", "Avoid over-arching"],
                durationSeconds: 60,
                repsOrHoldDescription: "30 sec each side"
            ),
            MobilityExercise(
                name: "Hamstring Glide",
                why: "Encourages posterior chain mobility.",
                howToDoIt: ["Sit tall with one leg straight", "Keep spine long", "Slowly bend and straighten knee", "10 slow reps each leg"],
                cues: ["Move from hips", "Don't round back", "Gentle sliding motion"],
                durationSeconds: 60,
                repsOrHoldDescription: "10 reps each leg"
            ),
            MobilityExercise(
                name: "Sciatic-Nerve Floss",
                why: "Helps relieve neural tension.",
                howToDoIt: ["Lie on back, lift one leg", "Hands behind thigh", "Straighten knee + flex foot", "Then bend knee + point toes"],
                cues: ["Control the movement", "Stop if sharp pain"],
                durationSeconds: 60,
                repsOrHoldDescription: "10-12 reps per leg"
            ),
            MobilityExercise(
                name: "Adductor Rock-Backs",
                why: "Opens inner hips and improves mobility.",
                howToDoIt: ["On hands & knees", "Extend one leg sideways", "Sink hips back toward heel", "Rock back and forth"],
                cues: ["Keep chest up", "Avoid rounding back", "Move from hips"],
                durationSeconds: 60,
                repsOrHoldDescription: "10-12 reps each side"
            ),
            MobilityExercise(
                name: "Glute-Med Activation",
                why: "Activates glutes for knee stability.",
                howToDoIt: ["Lie on one side", "Top leg straight, toe angled down", "Lift leg 12-18 inches slowly", "12-15 reps per side"],
                cues: ["Don't let hips rock", "Focus on side-butt"],
                durationSeconds: 60,
                repsOrHoldDescription: "12-15 reps per side"
            ),
            MobilityExercise(
                name: "Calf + Tibialis Wall Stretch",
                why: "Reduces strain on knees.",
                howToDoIt: ["Face wall, hands on wall", "Ball of foot on wall, heel down", "Lean forward for calf stretch", "Bend knee for soleus"],
                cues: ["Keep heel pinned", "Spine neutral"],
                durationSeconds: 60,
                repsOrHoldDescription: "30 sec + 30 sec each side"
            ),
            MobilityExercise(
                name: "Thoracic Bench Stretch",
                why: "Opens upper back and lats.",
                howToDoIt: ["Kneel in front of bench", "Place elbows on surface", "Hands clasped", "Sink chest toward floor"],
                cues: ["Relax lower back", "Focus on rib expansion"],
                durationSeconds: 60,
                repsOrHoldDescription: "Hold 1 minute"
            ),
            MobilityExercise(
                name: "Pelvic Tilt Cycling Drill",
                why: "Helps find optimal pelvic position.",
                howToDoIt: ["Sit or stand", "Posterior tilt: tuck butt under", "Anterior tilt: stick butt out", "End in neutral-anterior"],
                cues: ["Keep spine straight", "Move from hips"],
                durationSeconds: 45,
                repsOrHoldDescription: "10 slow cycles"
            ),
            MobilityExercise(
                name: "Monster Walk",
                why: "Activates hip abductors for knee stability.",
                howToDoIt: ["Mini-band above ankles or knees", "Semi-squat position", "Step sideways keeping tension", "Small, controlled steps"],
                cues: ["Maintain band tension", "Knees over toes", "Feel glutes working"],
                durationSeconds: 90,
                repsOrHoldDescription: "2-3 sets of ~20 steps"
            )
        ]
    )
}
