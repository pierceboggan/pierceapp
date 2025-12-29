//
//  Goal.swift
//  Project2026
//
//  High-level goals and KPIs
//

import Foundation

/// Represents a high-level vision goal or measurable KPI.
/// Goals can track progress toward specific targets (e.g., "Reach 250 FTP") or serve as
/// aspirational statements (e.g., "Live a healthy life"). Used for the yearly vision board.
public struct Goal: Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var category: GoalCategory
    public var isHighLevel: Bool // true for vision goals, false for KPIs
    public var targetValue: Double?
    public var currentValue: Double?
    public var unit: String?
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
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
    
    public var progress: Double? {
        guard let target = targetValue, let current = currentValue, target > 0 else { return nil }
        return min(current / target, 1.0)
    }
}

public enum GoalCategory: String, Codable, CaseIterable, Sendable {
    case presence = "Presence"
    case health = "Health"
    case outdoors = "Outdoors"
    case fitness = "Fitness"
    case phone = "Phone"
    
    public var icon: String {
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
    public static let defaultHighLevelGoals: [Goal] = [
        Goal(title: "Be more present and enjoy the time I have", category: .presence),
        Goal(title: "Live a healthy life", category: .health),
        Goal(title: "Enjoy the outdoors and Utah more", category: .outdoors)
    ]
    
    public static let defaultKPIs: [Goal] = [
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
