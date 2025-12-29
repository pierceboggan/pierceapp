//
//  Goal.swift
//  Project2026
//
//  High-level goals and KPIs
//

import Foundation

struct Goal: Codable, Identifiable {
    let id: UUID
    var title: String
    var category: GoalCategory
    var isHighLevel: Bool // true for vision goals, false for KPIs
    var targetValue: Double?
    var currentValue: Double?
    var unit: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        category: GoalCategory,
        isHighLevel: Bool = true,
        targetValue: Double? = nil,
        currentValue: Double? = nil,
        unit: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.isHighLevel = isHighLevel
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var progress: Double? {
        guard let target = targetValue, let current = currentValue, target > 0 else { return nil }
        return min(current / target, 1.0)
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case presence = "Presence"
    case health = "Health"
    case outdoors = "Outdoors"
    case fitness = "Fitness"
    case phone = "Phone"
    
    var icon: String {
        switch self {
        case .presence: return "heart.fill"
        case .health: return "figure.walk"
        case .outdoors: return "mountain.2.fill"
        case .fitness: return "bicycle"
        case .phone: return "iphone"
        }
    }
}

// MARK: - Default Goals

extension Goal {
    static let defaultHighLevelGoals: [Goal] = [
        Goal(title: "Be more present and enjoy the time I have", category: .presence),
        Goal(title: "Live a healthy life", category: .health),
        Goal(title: "Enjoy the outdoors and Utah more", category: .outdoors)
    ]
    
    static let defaultKPIs: [Goal] = [
        Goal(
            title: "Reach 250 FTP",
            category: .fitness,
            isHighLevel: false,
            targetValue: 250,
            currentValue: 0,
            unit: "FTP"
        ),
        Goal(
            title: "Ski every SLC resort",
            category: .outdoors,
            isHighLevel: false,
            targetValue: 7, // Approximate number of SLC resorts
            currentValue: 0,
            unit: "resorts"
        ),
        Goal(
            title: "Ski 50 days",
            category: .outdoors,
            isHighLevel: false,
            targetValue: 50,
            currentValue: 0,
            unit: "days"
        ),
        Goal(
            title: "Phone under 1 hour/day",
            category: .phone,
            isHighLevel: false,
            targetValue: 60,
            currentValue: 0,
            unit: "min/day avg"
        )
    ]
}
