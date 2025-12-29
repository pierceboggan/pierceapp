//
//  CleaningTask.swift
//  Project2026
//
//  Cleaning task and log models
//

import Foundation

// MARK: - Cleaning Task

/// Represents a household cleaning task with configurable recurrence patterns.
/// Supports daily, weekly, biweekly, monthly, or custom day intervals. Tasks can be
/// snoozed to delay their due date and track completion history.
public struct CleaningTask: Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var recurrence: CleaningRecurrence
    public var estimatedMinutes: Int?
    public var isActive: Bool
    public var lastCompletedDate: Date?
    public var snoozedUntil: Date?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        recurrence: CleaningRecurrence,
        estimatedMinutes: Int? = nil,
        isActive: Bool = true,
        lastCompletedDate: Date? = nil,
        snoozedUntil: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.recurrence = recurrence
        self.estimatedMinutes = estimatedMinutes
        self.isActive = isActive
        self.lastCompletedDate = lastCompletedDate
        self.snoozedUntil = snoozedUntil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var nextDueDate: Date? {
        guard let lastCompleted = lastCompletedDate else {
            return createdAt // Due immediately if never completed
        }
        return recurrence.nextDate(from: lastCompleted)
    }
    
    public var isOverdue: Bool {
        guard let dueDate = nextDueDate else { return true }
        return dueDate < Date()
    }
    
    public var isDueToday: Bool {
        guard let dueDate = nextDueDate else { return true }
        return Calendar.current.isDateInToday(dueDate) || isOverdue
    }
    
    public var isSnoozed: Bool {
        guard let snoozedUntil = snoozedUntil else { return false }
        return snoozedUntil > Date()
    }
    
    public var daysUntilDue: Int? {
        guard let dueDate = nextDueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }
}

// MARK: - Cleaning Log

public struct CleaningLog: Codable, Identifiable, Sendable {
    public let id: UUID
    let taskId: UUID
    let completedDate: Date
    public var durationMinutes: Int?
    public var note: String?
    
    public init(
        id: UUID = UUID(),
        taskId: UUID,
        completedDate: Date = Date(),
        durationMinutes: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.completedDate = completedDate
        self.durationMinutes = durationMinutes
        self.note = note
    }
}

// MARK: - Cleaning Recurrence

public enum CleaningRecurrence: Codable, Equatable, Hashable, Sendable {
    case daily
    case weekly
    case biweekly
    case monthly
    case custom(days: Int)
    
    public var displayText: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Every 2 weeks"
        case .monthly: return "Monthly"
        case .custom(let days): return "Every \(days) days"
        }
    }
    
    public var intervalDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .custom(let days): return days
        }
    }
    
    public func nextDate(from date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: intervalDays, to: date) ?? date
    }
}

// MARK: - Default Cleaning Tasks

extension CleaningTask {
    public static let defaultTasks: [CleaningTask] = [
        CleaningTask(
            title: "Kitchen reset",
            recurrence: .daily,
            estimatedMinutes: 15
        ),
        CleaningTask(
            title: "Floors",
            recurrence: .weekly,
            estimatedMinutes: 30
        ),
        CleaningTask(
            title: "Bathrooms",
            recurrence: .weekly,
            estimatedMinutes: 20
        ),
        CleaningTask(
            title: "Laundry",
            recurrence: .weekly,
            estimatedMinutes: 60
        ),
        CleaningTask(
            title: "Fridge clean-out",
            recurrence: .weekly,
            estimatedMinutes: 15
        ),
        CleaningTask(
            title: "Bedding",
            recurrence: .biweekly,
            estimatedMinutes: 30
        ),
        CleaningTask(
            title: "Car clean",
            recurrence: .monthly,
            estimatedMinutes: 45
        ),
        CleaningTask(
            title: "Garage/Gear tidy",
            recurrence: .monthly,
            estimatedMinutes: 60
        )
    ]
}
