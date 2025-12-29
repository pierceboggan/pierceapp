//
//  CleaningTask.swift
//  Project2026
//
//  Cleaning task and log models
//

import Foundation

// MARK: - Cleaning Task

struct CleaningTask: Codable, Identifiable {
    let id: UUID
    var title: String
    var recurrence: CleaningRecurrence
    var estimatedMinutes: Int?
    var isActive: Bool
    var lastCompletedDate: Date?
    var snoozedUntil: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(
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
    
    var nextDueDate: Date? {
        guard let lastCompleted = lastCompletedDate else {
            return createdAt // Due immediately if never completed
        }
        return recurrence.nextDate(from: lastCompleted)
    }
    
    var isOverdue: Bool {
        guard let dueDate = nextDueDate else { return true }
        return dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = nextDueDate else { return true }
        return Calendar.current.isDateInToday(dueDate) || isOverdue
    }
    
    var isSnoozed: Bool {
        guard let snoozedUntil = snoozedUntil else { return false }
        return snoozedUntil > Date()
    }
    
    var daysUntilDue: Int? {
        guard let dueDate = nextDueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }
}

// MARK: - Cleaning Log

struct CleaningLog: Codable, Identifiable {
    let id: UUID
    let taskId: UUID
    let completedDate: Date
    var durationMinutes: Int?
    var note: String?
    
    init(
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

enum CleaningRecurrence: Codable, Equatable, Hashable {
    case daily
    case weekly
    case biweekly
    case monthly
    case custom(days: Int)
    
    var displayText: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Every 2 weeks"
        case .monthly: return "Monthly"
        case .custom(let days): return "Every \(days) days"
        }
    }
    
    var intervalDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .custom(let days): return days
        }
    }
    
    func nextDate(from date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: intervalDays, to: date) ?? date
    }
}

// MARK: - Default Cleaning Tasks

extension CleaningTask {
    static let defaultTasks: [CleaningTask] = [
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
