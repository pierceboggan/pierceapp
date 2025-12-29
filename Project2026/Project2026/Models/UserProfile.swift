import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var dailyWaterTarget: Int // in oz
    var goals: [Goal]
    var kpis: [KPI]
    
    init(id: UUID = UUID(), dailyWaterTarget: Int = 100, goals: [Goal] = [], kpis: [KPI] = []) {
        self.id = id
        self.dailyWaterTarget = dailyWaterTarget
        self.goals = goals
        self.kpis = kpis
    }
}

struct Goal: Codable, Identifiable {
    let id: UUID
    var title: String
    var isActive: Bool
    
    init(id: UUID = UUID(), title: String, isActive: Bool = true) {
        self.id = id
        self.title = title
        self.isActive = isActive
    }
}

struct KPI: Codable, Identifiable {
    let id: UUID
    var title: String
    var target: String
    var currentValue: String?
    
    init(id: UUID = UUID(), title: String, target: String, currentValue: String? = nil) {
        self.id = id
        self.title = title
        self.target = target
        self.currentValue = currentValue
    }
}
