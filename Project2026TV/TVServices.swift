import SwiftUI
import Observation

// MARK: - Models

/// A single mobility exercise for the TV routine.
struct TVMobilityExercise: Identifiable {
    let id = UUID()
    let name: String
    let instructions: String
    let durationSeconds: Int
    let iconName: String
    let targetArea: String
}

/// A complete mobility routine containing multiple exercises.
struct TVMobilityRoutine {
    let name: String
    let exercises: [TVMobilityExercise]
    
    var totalDurationMinutes: Int {
        exercises.reduce(0) { $0 + $1.durationSeconds } / 60
    }
    
    /// Standard bike-focused mobility routine.
    static let bikeRoutine = TVMobilityRoutine(
        name: "Bike Mobility",
        exercises: [
            TVMobilityExercise(
                name: "Neck Rolls",
                instructions: "Slowly roll your head in a circle, 5 times each direction. Keep shoulders relaxed and movements smooth.",
                durationSeconds: 60,
                iconName: "arrow.triangle.2.circlepath",
                targetArea: "Neck"
            ),
            TVMobilityExercise(
                name: "Shoulder Circles",
                instructions: "Roll shoulders forward 10 times, then backward 10 times. Keep arms relaxed at your sides.",
                durationSeconds: 60,
                iconName: "arrow.clockwise.circle",
                targetArea: "Shoulders"
            ),
            TVMobilityExercise(
                name: "Cat-Cow Stretch",
                instructions: "On hands and knees, alternate between arching your back up (cat) and dipping it down (cow). Move with your breath.",
                durationSeconds: 60,
                iconName: "figure.flexibility",
                targetArea: "Spine"
            ),
            TVMobilityExercise(
                name: "Hip Flexor Stretch - Left",
                instructions: "Kneel on left knee, right foot forward. Push hips forward gently. Keep torso upright.",
                durationSeconds: 60,
                iconName: "figure.stand",
                targetArea: "Hip Flexors"
            ),
            TVMobilityExercise(
                name: "Hip Flexor Stretch - Right",
                instructions: "Kneel on right knee, left foot forward. Push hips forward gently. Keep torso upright.",
                durationSeconds: 60,
                iconName: "figure.stand",
                targetArea: "Hip Flexors"
            ),
            TVMobilityExercise(
                name: "Quad Stretch - Left",
                instructions: "Standing, grab left ankle behind you. Pull heel toward glute. Keep knees together.",
                durationSeconds: 45,
                iconName: "figure.cooldown",
                targetArea: "Quadriceps"
            ),
            TVMobilityExercise(
                name: "Quad Stretch - Right",
                instructions: "Standing, grab right ankle behind you. Pull heel toward glute. Keep knees together.",
                durationSeconds: 45,
                iconName: "figure.cooldown",
                targetArea: "Quadriceps"
            ),
            TVMobilityExercise(
                name: "Hamstring Stretch - Left",
                instructions: "Extend left leg forward, heel on ground. Hinge at hips, reach toward toes. Keep back straight.",
                durationSeconds: 45,
                iconName: "figure.walk",
                targetArea: "Hamstrings"
            ),
            TVMobilityExercise(
                name: "Hamstring Stretch - Right",
                instructions: "Extend right leg forward, heel on ground. Hinge at hips, reach toward toes. Keep back straight.",
                durationSeconds: 45,
                iconName: "figure.walk",
                targetArea: "Hamstrings"
            ),
            TVMobilityExercise(
                name: "Figure Four Stretch",
                instructions: "Lying down, cross left ankle over right knee. Pull right thigh toward chest. Switch sides halfway.",
                durationSeconds: 90,
                iconName: "figure.mind.and.body",
                targetArea: "Glutes & Hips"
            )
        ]
    )
}

// MARK: - Services

/// Service to track mobility sessions and statistics on tvOS.
@Observable
final class TVMobilityService {
    var todayMinutes: Int = 0
    var currentStreak: Int = 3
    var totalSessions: Int = 12
    
    private let defaults = UserDefaults.standard
    
    init() {
        loadData()
    }
    
    func recordSession(minutes: Int) {
        todayMinutes += minutes
        totalSessions += 1
        currentStreak += 1
        saveData()
    }
    
    private func loadData() {
        todayMinutes = defaults.integer(forKey: "tv_todayMinutes")
        currentStreak = defaults.integer(forKey: "tv_currentStreak")
        totalSessions = defaults.integer(forKey: "tv_totalSessions")
        
        // Set defaults if first launch
        if totalSessions == 0 {
            currentStreak = 3
            totalSessions = 12
        }
    }
    
    private func saveData() {
        defaults.set(todayMinutes, forKey: "tv_todayMinutes")
        defaults.set(currentStreak, forKey: "tv_currentStreak")
        defaults.set(totalSessions, forKey: "tv_totalSessions")
    }
}

/// Service to track and display stats on tvOS.
@Observable
final class TVStatsService {
    var weeklyMinutes: Int = 45
    var monthlyMinutes: Int = 180
    var totalMinutes: Int = 720
    
    struct DayData {
        let day: String
        let minutes: Int
    }
    
    var weeklyData: [DayData] = [
        DayData(day: "Mon", minutes: 10),
        DayData(day: "Tue", minutes: 10),
        DayData(day: "Wed", minutes: 0),
        DayData(day: "Thu", minutes: 10),
        DayData(day: "Fri", minutes: 10),
        DayData(day: "Sat", minutes: 5),
        DayData(day: "Sun", minutes: 0)
    ]
    
    init() {
        loadData()
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        if defaults.integer(forKey: "tv_totalMinutes") > 0 {
            totalMinutes = defaults.integer(forKey: "tv_totalMinutes")
        }
    }
}
