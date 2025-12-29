//
//  DaySummary.swift
//  Project2026
//
//  Daily summary model for history and analytics
//

import Foundation

/// Captures all daily metrics and calculates an overall score for a single day.
/// Aggregates habits (50% weight), cleaning tasks (20%), water intake (15%), and reading (15%)
/// into a 0-100 score. Used for the history calendar and trend analysis.
public struct DaySummary: Codable, Identifiable, Sendable {
    public let id: UUID
    let date: Date
    
    // Habits
    public var habitsCompleted: Int
    public var habitsTotal: Int
    
    // Cleaning
    public var cleaningTasksCompleted: Int
    public var cleaningTasksTotal: Int
    
    // Water
    public var waterOunces: Double
    public var waterTarget: Double
    
    // Reading
    public var pagesRead: Int
    public var minutesRead: Int
    
    // Score
    public var score: Double
    
    // Notes
    public var reflectionNote: String?
    
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
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
    
    public var habitCompletionRate: Double {
        guard habitsTotal > 0 else { return 0 }
        return Double(habitsCompleted) / Double(habitsTotal)
    }
    
    public var cleaningCompletionRate: Double {
        guard cleaningTasksTotal > 0 else { return 1.0 }
        return Double(cleaningTasksCompleted) / Double(cleaningTasksTotal)
    }
    
    public var waterCompletionRate: Double {
        guard waterTarget > 0 else { return 0 }
        return min(waterOunces / waterTarget, 1.0)
    }
    
    public var didRead: Bool {
        pagesRead > 0
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    public var dayOfWeek: String {
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

/// Aggregates DaySummary records for a 7-day period.
/// Calculates average score, habit compliance rate, total water intake,
/// reading days, and pages read for the week.
public struct WeeklySummary {
    let startDate: Date
    let endDate: Date
    let days: [DaySummary]
    
    public var averageScore: Double {
        guard !days.isEmpty else { return 0 }
        return days.map { $0.score }.reduce(0, +) / Double(days.count)
    }
    
    public var totalHabitsCompleted: Int {
        days.map { $0.habitsCompleted }.reduce(0, +)
    }
    
    public var totalHabitsTotal: Int {
        days.map { $0.habitsTotal }.reduce(0, +)
    }
    
    public var habitComplianceRate: Double {
        guard totalHabitsTotal > 0 else { return 0 }
        return Double(totalHabitsCompleted) / Double(totalHabitsTotal)
    }
    
    public var cleaningComplianceRate: Double {
        let completed = days.map { $0.cleaningTasksCompleted }.reduce(0, +)
        let total = days.map { $0.cleaningTasksTotal }.reduce(0, +)
        guard total > 0 else { return 1.0 }
        return Double(completed) / Double(total)
    }
    
    public var averageWaterOunces: Double {
        guard !days.isEmpty else { return 0 }
        return days.map { $0.waterOunces }.reduce(0, +) / Double(days.count)
    }
    
    public var daysWithReading: Int {
        days.filter { $0.didRead }.count
    }
    
    public var totalPagesRead: Int {
        days.map { $0.pagesRead }.reduce(0, +)
    }
}
