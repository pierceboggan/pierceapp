//
//  Habit.swift
//  Project2026
//
//  Habit template and log models
//

import Foundation

// MARK: - Habit Template

struct HabitTemplate: Codable, Identifiable {
    let id: UUID
    var title: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var inputType: HabitInputType
    var targetValue: Double? // For numeric habits
    var unit: String? // For numeric habits (oz, g, min, etc.)
    var isCore: Bool // Core habits are hardcoded
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        category: HabitCategory,
        frequency: HabitFrequency = .daily,
        inputType: HabitInputType = .boolean,
        targetValue: Double? = nil,
        unit: String? = nil,
        isCore: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.frequency = frequency
        self.inputType = inputType
        self.targetValue = targetValue
        self.unit = unit
        self.isCore = isCore
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Habit Log

struct HabitLog: Codable, Identifiable {
    let id: UUID
    let habitId: UUID
    let date: Date
    var completed: Bool
    var numericValue: Double?
    var durationMinutes: Int?
    var note: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date = Date(),
        completed: Bool = false,
        numericValue: Double? = nil,
        durationMinutes: Int? = nil,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
        self.completed = completed
        self.numericValue = numericValue
        self.durationMinutes = durationMinutes
        self.note = note
        self.createdAt = createdAt
    }
}

// MARK: - Enums

enum HabitCategory: String, Codable, CaseIterable {
    case life = "Life"
    case fitness = "Fitness"
    case nutrition = "Nutrition"
    case health = "Health"
    case work = "Work"
    case supplements = "Supplements & Recovery"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .life: return "person.fill"
        case .fitness: return "figure.run"
        case .nutrition: return "fork.knife"
        case .health: return "heart.fill"
        case .work: return "briefcase.fill"
        case .supplements: return "pills.fill"
        case .custom: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .life: return "blue"
        case .fitness: return "orange"
        case .nutrition: return "green"
        case .health: return "red"
        case .work: return "purple"
        case .supplements: return "teal"
        case .custom: return "yellow"
        }
    }
}

enum HabitFrequency: Codable, Equatable {
    case daily
    case weekly(daysPerWeek: Int)
    case specificDays(days: [Int]) // 1 = Sunday, 7 = Saturday
    case custom(description: String)
    
    var displayText: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly(let days):
            return "\(days)x/week"
        case .specificDays(let days):
            let dayNames = days.map { Calendar.current.shortWeekdaySymbols[$0 - 1] }
            return dayNames.joined(separator: ", ")
        case .custom(let description):
            return description
        }
    }
    
    func isActiveOn(date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        switch self {
        case .daily:
            return true
        case .weekly:
            return true // Weekly habits show every day, tracked by count
        case .specificDays(let days):
            return days.contains(weekday)
        case .custom:
            return true
        }
    }
}

enum HabitInputType: String, Codable, CaseIterable {
    case boolean = "Boolean"
    case numeric = "Numeric"
    case duration = "Duration"
    case note = "Note"
    
    var icon: String {
        switch self {
        case .boolean: return "checkmark.circle"
        case .numeric: return "number"
        case .duration: return "clock"
        case .note: return "note.text"
        }
    }
}

// MARK: - Core Habits

extension HabitTemplate {
    static let coreHabits: [HabitTemplate] = [
        // Life
        HabitTemplate(
            title: "Brick phone 5–8pm",
            category: .life,
            isCore: true
        ),
        HabitTemplate(
            title: "Read a chapter a day",
            category: .life,
            isCore: true
        ),
        
        // Fitness
        HabitTemplate(
            title: "Workout",
            category: .fitness,
            frequency: .weekly(daysPerWeek: 6),
            isCore: true
        ),
        HabitTemplate(
            title: "Mobility",
            category: .fitness,
            frequency: .weekly(daysPerWeek: 6),
            isCore: true
        ),
        
        // Nutrition
        HabitTemplate(
            title: "Drink 100oz of water",
            category: .nutrition,
            inputType: .numeric,
            targetValue: 100,
            unit: "oz",
            isCore: true
        ),
        HabitTemplate(
            title: "Minimize processed foods",
            category: .nutrition,
            isCore: true
        ),
        HabitTemplate(
            title: "No liquid calories",
            category: .nutrition,
            isCore: true
        ),
        HabitTemplate(
            title: "Only 2 cups of coffee",
            category: .nutrition,
            inputType: .numeric,
            targetValue: 2,
            unit: "cups",
            isCore: true
        ),
        HabitTemplate(
            title: "Hit 145g of protein",
            category: .nutrition,
            inputType: .numeric,
            targetValue: 145,
            unit: "g",
            isCore: true
        ),
        
        // Health
        HabitTemplate(
            title: "Lights out by 10pm",
            category: .health,
            isCore: true
        ),
        HabitTemplate(
            title: "Track HRV daily",
            category: .health,
            isCore: true
        ),
        HabitTemplate(
            title: "Meditate daily",
            category: .health,
            inputType: .duration,
            isCore: true
        ),
        
        // Work
        HabitTemplate(
            title: "Work 9–5:30",
            category: .work,
            isCore: true
        ),
        HabitTemplate(
            title: "Limit social media to 15 min",
            category: .work,
            inputType: .duration,
            targetValue: 15,
            unit: "min",
            isCore: true
        ),
        
        // Supplements & Recovery
        HabitTemplate(
            title: "Wake up 5:30am",
            category: .supplements,
            isCore: true
        ),
        HabitTemplate(
            title: "Multivitamin",
            category: .supplements,
            isCore: true
        ),
        HabitTemplate(
            title: "Recovery vitamin",
            category: .supplements,
            isCore: true
        ),
        HabitTemplate(
            title: "Anti-sickness vitamin",
            category: .supplements,
            isCore: true
        ),
        HabitTemplate(
            title: "10 min in hot tub",
            category: .supplements,
            inputType: .duration,
            targetValue: 10,
            unit: "min",
            isCore: true
        ),
        HabitTemplate(
            title: "Daily mobility",
            category: .supplements,
            isCore: true
        )
    ]
}
