import Foundation

enum CleaningRecurrence: String, Codable {
    case daily
    case weekly
    case monthly
    case custom
}

struct CleaningTask: Codable, Identifiable {
    let id: UUID
    var title: String
    var recurrence: CleaningRecurrence
    var estimatedMinutes: Int?
    var isActive: Bool
    var lastCompletedDate: Date?
    var nextDueDate: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        recurrence: CleaningRecurrence,
        estimatedMinutes: Int? = nil,
        isActive: Bool = true,
        lastCompletedDate: Date? = nil,
        nextDueDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.recurrence = recurrence
        self.estimatedMinutes = estimatedMinutes
        self.isActive = isActive
        self.lastCompletedDate = lastCompletedDate
        self.nextDueDate = nextDueDate
    }
    
    var isOverdue: Bool {
        return nextDueDate < Date()
    }
}

struct CleaningLog: Codable, Identifiable {
    let id: UUID
    let taskId: UUID
    let completedDate: Date
    var actualMinutes: Int?
    var note: String?
    
    init(
        id: UUID = UUID(),
        taskId: UUID,
        completedDate: Date = Date(),
        actualMinutes: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.completedDate = completedDate
        self.actualMinutes = actualMinutes
        self.note = note
    }
}
