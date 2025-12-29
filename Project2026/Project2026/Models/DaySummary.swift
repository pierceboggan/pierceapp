import Foundation

struct DaySummary: Codable, Identifiable {
    let id: UUID
    let date: Date
    var habitsCompleted: Int
    var habitsTotal: Int
    var cleaningCompleted: Int
    var cleaningTotal: Int
    var waterConsumed: Int
    var waterTarget: Int
    var pagesRead: Int
    var score: Double
    var reflectionNotes: String?
    
    var completionPercentage: Double {
        guard habitsTotal > 0 else { return 0 }
        return Double(habitsCompleted) / Double(habitsTotal) * 100
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        habitsCompleted: Int = 0,
        habitsTotal: Int = 0,
        cleaningCompleted: Int = 0,
        cleaningTotal: Int = 0,
        waterConsumed: Int = 0,
        waterTarget: Int = 100,
        pagesRead: Int = 0,
        score: Double = 0,
        reflectionNotes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.habitsCompleted = habitsCompleted
        self.habitsTotal = habitsTotal
        self.cleaningCompleted = cleaningCompleted
        self.cleaningTotal = cleaningTotal
        self.waterConsumed = waterConsumed
        self.waterTarget = waterTarget
        self.pagesRead = pagesRead
        self.score = score
        self.reflectionNotes = reflectionNotes
    }
}
