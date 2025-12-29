import Foundation

enum HabitCategory: String, Codable, CaseIterable {
    case life = "Life"
    case fitness = "Fitness"
    case nutrition = "Nutrition"
    case health = "Health"
    case work = "Work"
    case supplementsRecovery = "Supplements & Recovery"
    case custom = "Custom"
}

enum HabitInputType: String, Codable {
    case boolean
    case numeric
    case duration
    case note
}

enum HabitFrequency: String, Codable {
    case daily
    case weekly
    case custom
}

struct HabitTemplate: Codable, Identifiable {
    let id: UUID
    var title: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var inputType: HabitInputType
    var isActive: Bool
    var isCoreHabit: Bool
    var targetValue: Double?
    var unit: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        category: HabitCategory,
        frequency: HabitFrequency = .daily,
        inputType: HabitInputType = .boolean,
        isActive: Bool = true,
        isCoreHabit: Bool = false,
        targetValue: Double? = nil,
        unit: String? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.frequency = frequency
        self.inputType = inputType
        self.isActive = isActive
        self.isCoreHabit = isCoreHabit
        self.targetValue = targetValue
        self.unit = unit
    }
}

struct HabitLog: Codable, Identifiable {
    let id: UUID
    let habitId: UUID
    let date: Date
    var completed: Bool
    var value: Double?
    var note: String?
    
    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date = Date(),
        completed: Bool = false,
        value: Double? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.completed = completed
        self.value = value
        self.note = note
    }
}
