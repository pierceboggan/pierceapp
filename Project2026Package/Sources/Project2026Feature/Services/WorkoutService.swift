//
//  WorkoutService.swift
//  Project2026
//
//  Service for tracking workouts and mobility sessions
//

import SwiftUI

/// Manages workout logging and mobility session tracking.
/// Provides weekly statistics and supports future TrainerRoad integration.
@MainActor
public class WorkoutService: ObservableObject {
    @Published public var workouts: [Workout] = []
    @Published public var mobilityLogs: [MobilityLog] = []
    @Published public var isLoading = false
    
    private let persistence = PersistenceManager.shared
    
    public init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    public func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            workouts = try await persistence.load([Workout].self, from: StorageKey.workouts)
        } catch {
            workouts = []
        }
        
        do {
            mobilityLogs = try await persistence.load([MobilityLog].self, from: StorageKey.mobilityLogs)
        } catch {
            mobilityLogs = []
        }
    }
    
    // MARK: - Workout Management
    
    public func addWorkout(_ workout: Workout) async {
        workouts.append(workout)
        workouts.sort { $0.date > $1.date }
        await saveWorkouts()
    }
    
    public func updateWorkout(_ workout: Workout) async {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            await saveWorkouts()
        }
    }
    
    public func deleteWorkout(_ workout: Workout) async {
        workouts.removeAll { $0.id == workout.id }
        await saveWorkouts()
    }
    
    // MARK: - Mobility Management
    
    public func logMobilitySession(
        durationMinutes: Int,
        exercisesCompleted: Int,
        totalExercises: Int,
        notes: String? = nil
    ) async {
        let log = MobilityLog(
            durationMinutes: durationMinutes,
            exercisesCompleted: exercisesCompleted,
            totalExercises: totalExercises,
            notes: notes
        )
        mobilityLogs.append(log)
        mobilityLogs.sort { $0.date > $1.date }
        await saveMobilityLogs()
    }
    
    public func deleteMobilityLog(_ log: MobilityLog) async {
        mobilityLogs.removeAll { $0.id == log.id }
        await saveMobilityLogs()
    }
    
    // MARK: - Today's Data
    
    public func workoutsForToday() -> [Workout] {
        let today = Calendar.current.startOfDay(for: Date())
        return workouts.filter { $0.date == today }
    }
    
    public func didWorkoutToday() -> Bool {
        !workoutsForToday().isEmpty
    }
    
    public func mobilityLogForToday() -> MobilityLog? {
        let today = Calendar.current.startOfDay(for: Date())
        return mobilityLogs.first { $0.date == today }
    }
    
    public func didMobilityToday() -> Bool {
        mobilityLogForToday() != nil
    }
    
    // MARK: - Weekly Statistics
    
    public func workoutsForWeek(containing date: Date = Date()) -> [Workout] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? date
        
        return workouts.filter { $0.date >= weekStart && $0.date < weekEnd }
    }
    
    public func mobilityLogsForWeek(containing date: Date = Date()) -> [MobilityLog] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? date
        
        return mobilityLogs.filter { $0.date >= weekStart && $0.date < weekEnd }
    }
    
    public func weeklySummary(for date: Date = Date()) -> WeeklyWorkoutSummary {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        
        let weekWorkouts = workoutsForWeek(containing: date)
        let weekMobility = mobilityLogsForWeek(containing: date)
        
        var workoutsByType: [WorkoutType: Int] = [:]
        for workout in weekWorkouts {
            workoutsByType[workout.type, default: 0] += 1
        }
        
        return WeeklyWorkoutSummary(
            weekStartDate: weekStart,
            totalWorkouts: weekWorkouts.count,
            totalDurationMinutes: weekWorkouts.reduce(0) { $0 + $1.durationMinutes },
            totalTSS: weekWorkouts.reduce(0) { $0 + $1.estimatedTSS },
            workoutsByType: workoutsByType,
            mobilitySessionsCompleted: weekMobility.count
        )
    }
    
    public var workoutsThisWeek: Int {
        workoutsForWeek().count
    }
    
    public var mobilityThisWeek: Int {
        mobilityLogsForWeek().count
    }
    
    // MARK: - Streaks
    
    public func workoutStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while workouts.contains(where: { $0.date == currentDate }) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    public func mobilityStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while mobilityLogs.contains(where: { $0.date == currentDate }) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    // MARK: - History
    
    public func workoutsForDate(_ date: Date) -> [Workout] {
        let targetDate = Calendar.current.startOfDay(for: date)
        return workouts.filter { $0.date == targetDate }
    }
    
    public func recentWorkouts(limit: Int = 10) -> [Workout] {
        Array(workouts.prefix(limit))
    }
    
    // MARK: - Persistence
    
    private func saveWorkouts() async {
        do {
            try await persistence.save(workouts, to: StorageKey.workouts)
        } catch {
            print("Failed to save workouts: \(error)")
        }
    }
    
    private func saveMobilityLogs() async {
        do {
            try await persistence.save(mobilityLogs, to: StorageKey.mobilityLogs)
        } catch {
            print("Failed to save mobility logs: \(error)")
        }
    }
}
