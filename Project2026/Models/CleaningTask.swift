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
    var area: String
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
        area: String = "Main Level",
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
        self.area = area
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
            // Never completed - due today (start of day)
            return Calendar.current.startOfDay(for: Date())
        }
        return recurrence.nextDate(from: lastCompleted)
    }
    
    var isOverdue: Bool {
        guard let dueDate = nextDueDate else { return false }
        // Only overdue if the due date is before the start of today
        let todayStart = Calendar.current.startOfDay(for: Date())
        return dueDate < todayStart
    }
    
    var isDueToday: Bool {
        guard let dueDate = nextDueDate else { return true }
        let todayStart = Calendar.current.startOfDay(for: Date())
        let tomorrowStart = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        // Due today if the due date falls within today OR is overdue
        return (dueDate >= todayStart && dueDate < tomorrowStart) || isOverdue
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
    /// Helper to create a date offset by days from now.
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
    
    static let defaultTasks: [CleaningTask] = [
        // Main Level - Daily
        CleaningTask(
            title: "Start robot vacuum",
            area: "Main Level",
            recurrence: .daily,
            estimatedMinutes: 2
        ),
        CleaningTask(
            title: "Pick up toys",
            area: "Main Level",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        
        // Dining Room - Daily
        CleaningTask(
            title: "Wipe down countertops",
            area: "Dining Room",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        
        // Kitchen - Daily
        CleaningTask(
            title: "Wipe countertops",
            area: "Kitchen",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        
        // Living Room
        CleaningTask(
            title: "Pick up toys",
            area: "Living Room",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        // Offset by 1 day so it doesn't overlap with Downstairs vacuum
        CleaningTask(
            title: "Vacuum",
            area: "Living Room",
            recurrence: .custom(days: 2),
            estimatedMinutes: 15,
            lastCompletedDate: daysAgo(1)
        ),
        
        // Basement - Daily
        CleaningTask(
            title: "Clean desk",
            area: "Basement",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        
        // Downstairs
        CleaningTask(
            title: "Do one load of laundry",
            area: "Downstairs",
            recurrence: .daily,
            estimatedMinutes: 10
        ),
        // No offset - will alternate with Living Room vacuum
        CleaningTask(
            title: "Vacuum",
            area: "Downstairs",
            recurrence: .custom(days: 2),
            estimatedMinutes: 15,
            lastCompletedDate: daysAgo(2)
        ),
        
        // Bathrooms
        CleaningTask(
            title: "Wipe countertops",
            area: "Bathrooms",
            recurrence: .daily,
            estimatedMinutes: 5
        ),
        // Weekly task offset by 3 days to spread out
        CleaningTask(
            title: "Clean toilet",
            area: "Bathrooms",
            recurrence: .weekly,
            estimatedMinutes: 10,
            lastCompletedDate: daysAgo(4)
        )
    ]
}
