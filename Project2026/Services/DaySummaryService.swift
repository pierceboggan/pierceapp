//
//  DaySummaryService.swift
//  Project2026
//
//  Service for managing daily summaries and history
//

import SwiftUI

@MainActor
class DaySummaryService: ObservableObject {
    @Published var summaries: [DaySummary] = []
    @Published var isLoading = false
    
    private let persistence = PersistenceManager.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            summaries = try await persistence.load([DaySummary].self, from: StorageKey.daySummaries)
        } catch {
            summaries = []
        }
    }
    
    // MARK: - Summary Management
    
    func summaryForDate(_ date: Date) -> DaySummary? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return summaries.first { $0.date == dayStart }
    }
    
    func todaySummary() -> DaySummary? {
        summaryForDate(Date())
    }
    
    func updateSummary(
        for date: Date,
        habitService: HabitService,
        cleaningService: CleaningService,
        waterService: WaterService,
        readingService: ReadingService
    ) async {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        let todayHabits = habitService.habitsForToday()
        let completedHabits = todayHabits.filter { habit in
            habitService.logForHabit(habit.id, on: date)?.completed ?? false
        }.count
        
        let todayCleaningTasks = cleaningService.tasksForToday()
        let completedCleaning = todayCleaningTasks.filter { task in
            cleaningService.isTaskCompleted(task, on: date)
        }.count
        
        let waterLog = waterService.waterLog(for: date)
        let readingSessions = readingService.sessionsForToday()
        
        let score = DaySummary.calculateScore(
            habitCompletion: todayHabits.isEmpty ? 0 : Double(completedHabits) / Double(todayHabits.count),
            cleaningCompletion: todayCleaningTasks.isEmpty ? 1.0 : Double(completedCleaning) / Double(todayCleaningTasks.count),
            waterCompletion: waterLog?.progress ?? 0,
            didRead: !readingSessions.isEmpty
        )
        
        if let index = summaries.firstIndex(where: { $0.date == dayStart }) {
            summaries[index].habitsCompleted = completedHabits
            summaries[index].habitsTotal = todayHabits.count
            summaries[index].cleaningTasksCompleted = completedCleaning
            summaries[index].cleaningTasksTotal = todayCleaningTasks.count
            summaries[index].waterOunces = waterLog?.totalOunces ?? 0
            summaries[index].waterTarget = waterService.dailyTarget
            summaries[index].pagesRead = readingSessions.reduce(0) { $0 + $1.pagesRead }
            summaries[index].minutesRead = readingSessions.compactMap { $0.durationMinutes }.reduce(0, +)
            summaries[index].score = score
            summaries[index].updatedAt = Date()
        } else {
            let summary = DaySummary(
                date: date,
                habitsCompleted: completedHabits,
                habitsTotal: todayHabits.count,
                cleaningTasksCompleted: completedCleaning,
                cleaningTasksTotal: todayCleaningTasks.count,
                waterOunces: waterLog?.totalOunces ?? 0,
                waterTarget: waterService.dailyTarget,
                pagesRead: readingSessions.reduce(0) { $0 + $1.pagesRead },
                minutesRead: readingSessions.compactMap { $0.durationMinutes }.reduce(0, +),
                score: score
            )
            summaries.append(summary)
        }
        
        await save()
    }
    
    func updateReflection(for date: Date, note: String) async {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        if let index = summaries.firstIndex(where: { $0.date == dayStart }) {
            summaries[index].reflectionNote = note
            summaries[index].updatedAt = Date()
        } else {
            var summary = DaySummary(date: date)
            summary.reflectionNote = note
            summaries.append(summary)
        }
        
        await save()
    }
    
    // MARK: - History Queries
    
    func summariesForWeek(containing date: Date) -> [DaySummary] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return []
        }
        
        var result: [DaySummary] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            if let summary = summaryForDate(day) {
                result.append(summary)
            }
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    func weeklySummary(for date: Date) -> WeeklySummary {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return WeeklySummary(startDate: date, endDate: date, days: [])
        }
        
        let days = summariesForWeek(containing: date)
        return WeeklySummary(startDate: weekStart, endDate: weekEnd, days: days)
    }
    
    func summariesForMonth(year: Int, month: Int) -> [DaySummary] {
        let calendar = Calendar.current
        
        return summaries.filter { summary in
            let components = calendar.dateComponents([.year, .month], from: summary.date)
            return components.year == year && components.month == month
        }.sorted { $0.date < $1.date }
    }
    
    func recentSummaries(count: Int = 30) -> [DaySummary] {
        summaries
            .sorted { $0.date > $1.date }
            .prefix(count)
            .map { $0 }
    }
    
    // MARK: - Statistics
    
    func averageScore(lastDays: Int = 7) -> Double {
        let recent = recentSummaries(count: lastDays)
        guard !recent.isEmpty else { return 0 }
        return recent.map { $0.score }.reduce(0, +) / Double(recent.count)
    }
    
    func currentStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while let summary = summaryForDate(currentDate), summary.score >= 50 {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    func bestStreak() -> Int {
        let sortedSummaries = summaries.sorted { $0.date < $1.date }
        var bestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for summary in sortedSummaries {
            if summary.score >= 50 {
                if let last = lastDate {
                    let dayDiff = Calendar.current.dateComponents([.day], from: last, to: summary.date).day ?? 0
                    if dayDiff == 1 {
                        currentStreak += 1
                    } else {
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            lastDate = summary.date
        }
        
        return bestStreak
    }
    
    // MARK: - Persistence
    
    private func save() async {
        do {
            try await persistence.save(summaries, to: StorageKey.daySummaries)
        } catch {
            print("Failed to save day summaries: \(error)")
        }
    }
}
