//
//  HabitService.swift
//  Project2026
//
//  Service for managing habits and habit logs
//

import SwiftUI

/// Manages all habit templates and their completion logs.
/// Handles daily/weekly habit filtering, completion toggling, compliance rate calculation,
/// and weekly progress tracking. Persists data locally with automatic loading on init.
@MainActor
public class HabitService: ObservableObject {
    @Published var habitTemplates: [HabitTemplate] = []
    @Published var habitLogs: [HabitLog] = []
    @Published var isLoading = false
    
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
        
        // Load habit templates
        do {
            habitTemplates = try await persistence.load([HabitTemplate].self, from: StorageKey.habitTemplates)
        } catch {
            // Initialize with core habits if no data exists
            habitTemplates = HabitTemplate.coreHabits
            await saveTemplates()
        }
        
        // Load habit logs
        do {
            habitLogs = try await persistence.load([HabitLog].self, from: StorageKey.habitLogs)
        } catch {
            habitLogs = []
        }
    }
    
    // MARK: - Habit Templates
    
    public var activeHabits: [HabitTemplate] {
        habitTemplates.filter { $0.isActive }
    }
    
    public var coreHabits: [HabitTemplate] {
        habitTemplates.filter { $0.isCore }
    }
    
    public var customHabits: [HabitTemplate] {
        habitTemplates.filter { !$0.isCore }
    }
    
    public func habitsByCategory(_ category: HabitCategory) -> [HabitTemplate] {
        activeHabits.filter { $0.category == category }
    }
    
    public func addHabit(_ habit: HabitTemplate) async {
        habitTemplates.append(habit)
        await saveTemplates()
    }
    
    public func updateHabit(_ habit: HabitTemplate) async {
        if let index = habitTemplates.firstIndex(where: { $0.id == habit.id }) {
            habitTemplates[index] = habit
            await saveTemplates()
        }
    }
    
    public func toggleHabit(_ habit: HabitTemplate) async {
        if let index = habitTemplates.firstIndex(where: { $0.id == habit.id }) {
            habitTemplates[index].isActive.toggle()
            await saveTemplates()
        }
    }
    
    public func archiveHabit(_ habit: HabitTemplate) async {
        if let index = habitTemplates.firstIndex(where: { $0.id == habit.id }) {
            habitTemplates[index].isActive = false
            await saveTemplates()
        }
    }
    
    public func deleteHabit(_ habit: HabitTemplate) async {
        guard !habit.isCore else { return } // Can't delete core habits
        habitTemplates.removeAll { $0.id == habit.id }
        await saveTemplates()
    }
    
    // MARK: - Habit Logs
    
    public func habitsForToday() -> [HabitTemplate] {
        let today = Date()
        return activeHabits.filter { $0.frequency.isActiveOn(date: today) }
    }
    
    /// Returns habits that are active on the given date
    public func habitsFor(date: Date) -> [HabitTemplate] {
        return activeHabits.filter { $0.frequency.isActiveOn(date: date) }
    }
    
    public func logForHabit(_ habitId: UUID, on date: Date) -> HabitLog? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return habitLogs.first { $0.habitId == habitId && $0.date == dayStart }
    }
    
    public func toggleHabitCompletion(_ habit: HabitTemplate, on date: Date = Date()) async {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        if let index = habitLogs.firstIndex(where: { $0.habitId == habit.id && $0.date == dayStart }) {
            habitLogs[index].completed.toggle()
        } else {
            let log = HabitLog(habitId: habit.id, date: date, completed: true)
            habitLogs.append(log)
        }
        
        await saveLogs()
    }
    
    public func updateHabitLog(_ habit: HabitTemplate, value: Double?, duration: Int?, note: String?, on date: Date = Date()) async {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        if let index = habitLogs.firstIndex(where: { $0.habitId == habit.id && $0.date == dayStart }) {
            if let value = value {
                habitLogs[index].numericValue = value
                // Auto-complete if target is met
                if let target = habit.targetValue, value >= target {
                    habitLogs[index].completed = true
                }
            }
            if let duration = duration {
                habitLogs[index].durationMinutes = duration
            }
            if let note = note {
                habitLogs[index].note = note
            }
        } else {
            let completed = (value ?? 0) >= (habit.targetValue ?? 0)
            let log = HabitLog(
                habitId: habit.id,
                date: date,
                completed: completed,
                numericValue: value,
                durationMinutes: duration,
                note: note
            )
            habitLogs.append(log)
        }
        
        await saveLogs()
    }
    
    // MARK: - Statistics
    
    public func completionRate(for date: Date) -> Double {
        let habits = habitsForToday()
        guard !habits.isEmpty else { return 0 }
        
        let completed = habits.filter { habit in
            logForHabit(habit.id, on: date)?.completed ?? false
        }.count
        
        return Double(completed) / Double(habits.count)
    }
    
    public func completedCount(for date: Date) -> Int {
        let habits = habitsForToday()
        return habits.filter { habit in
            logForHabit(habit.id, on: date)?.completed ?? false
        }.count
    }
    
    public func streak(for habit: HabitTemplate) -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while let log = logForHabit(habit.id, on: currentDate), log.completed {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    public func weeklyCompletionCount(for habit: HabitTemplate) -> Int {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return 0 }
        
        var count = 0
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            if let log = logForHabit(habit.id, on: date), log.completed {
                count += 1
            }
        }
        
        return count
    }
    
    // MARK: - Persistence
    
    private func saveTemplates() async {
        do {
            try await persistence.save(habitTemplates, to: StorageKey.habitTemplates)
        } catch {
            print("Failed to save habit templates: \(error)")
        }
    }
    
    private func saveLogs() async {
        do {
            try await persistence.save(habitLogs, to: StorageKey.habitLogs)
        } catch {
            print("Failed to save habit logs: \(error)")
        }
    }
}
