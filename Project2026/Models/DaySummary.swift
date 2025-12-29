//
//  DaySummary.swift
//  Project2026
//
//  Daily summary model for history and analytics
//

import Foundation

struct DaySummary: Codable, Identifiable {
    let id: UUID
    let date: Date
    
    // Habits
    var habitsCompleted: Int
    var habitsTotal: Int
    
    // Cleaning
    var cleaningTasksCompleted: Int
    var cleaningTasksTotal: Int
    
    // Water
    var waterOunces: Double
    var waterTarget: Double
    
    // Reading
    var pagesRead: Int
    var minutesRead: Int
    
    // Score
    var score: Double
    
    // Notes
    var reflectionNote: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        habitsCompleted: Int = 0,
        habitsTotal: Int = 0,
        cleaningTasksCompleted: Int = 0,
        cleaningTasksTotal: Int = 0,
        waterOunces: Double = 0,
        waterTarget: Double = 100,
        pagesRead: Int = 0,
        minutesRead: Int = 0,
        score: Double = 0,
        reflectionNote: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.habitsCompleted = habitsCompleted
        self.habitsTotal = habitsTotal
        self.cleaningTasksCompleted = cleaningTasksCompleted
        self.cleaningTasksTotal = cleaningTasksTotal
        self.waterOunces = waterOunces
        self.waterTarget = waterTarget
        self.pagesRead = pagesRead
        self.minutesRead = minutesRead
        self.score = score
        self.reflectionNote = reflectionNote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    var habitCompletionRate: Double {
        guard habitsTotal > 0 else { return 0 }
        return Double(habitsCompleted) / Double(habitsTotal)
    }
    
    var cleaningCompletionRate: Double {
        guard cleaningTasksTotal > 0 else { return 1.0 }
        return Double(cleaningTasksCompleted) / Double(cleaningTasksTotal)
    }
    
    var waterCompletionRate: Double {
        guard waterTarget > 0 else { return 0 }
        return min(waterOunces / waterTarget, 1.0)
    }
    
    var didRead: Bool {
        pagesRead > 0
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Score Calculation
    
    static func calculateScore(
        habitCompletion: Double,
        cleaningCompletion: Double,
        waterCompletion: Double,
        didRead: Bool
    ) -> Double {
        // Weights
        let habitWeight = 0.5
        let cleaningWeight = 0.2
        let waterWeight = 0.15
        let readingWeight = 0.15
        
        let habitScore = habitCompletion * habitWeight
        let cleaningScore = cleaningCompletion * cleaningWeight
        let waterScore = waterCompletion * waterWeight
        let readingScore = (didRead ? 1.0 : 0.0) * readingWeight
        
        return (habitScore + cleaningScore + waterScore + readingScore) * 100
    }
}

// MARK: - Weekly Summary

struct WeeklySummary {
    let startDate: Date
    let endDate: Date
    let days: [DaySummary]
    
    var averageScore: Double {
        guard !days.isEmpty else { return 0 }
        return days.map { $0.score }.reduce(0, +) / Double(days.count)
    }
    
    var totalHabitsCompleted: Int {
        days.map { $0.habitsCompleted }.reduce(0, +)
    }
    
    var totalHabitsTotal: Int {
        days.map { $0.habitsTotal }.reduce(0, +)
    }
    
    var habitComplianceRate: Double {
        guard totalHabitsTotal > 0 else { return 0 }
        return Double(totalHabitsCompleted) / Double(totalHabitsTotal)
    }
    
    var cleaningComplianceRate: Double {
        let completed = days.map { $0.cleaningTasksCompleted }.reduce(0, +)
        let total = days.map { $0.cleaningTasksTotal }.reduce(0, +)
        guard total > 0 else { return 1.0 }
        return Double(completed) / Double(total)
    }
    
    var averageWaterOunces: Double {
        guard !days.isEmpty else { return 0 }
        return days.map { $0.waterOunces }.reduce(0, +) / Double(days.count)
    }
    
    var daysWithReading: Int {
        days.filter { $0.didRead }.count
    }
    
    var totalPagesRead: Int {
        days.map { $0.pagesRead }.reduce(0, +)
    }
}
