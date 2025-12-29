//
//  WaterLog.swift
//  Project2026
//
//  Water tracking models
//

import Foundation

// MARK: - Water Entry

/// A single water intake entry with amount (in ounces) and timestamp.
/// Multiple entries combine into a WaterLog for daily tracking.
public struct WaterEntry: Codable, Identifiable, Sendable {
    public let id: UUID
    let amount: Double // in ounces
    let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        amount: Double,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
    }
}

// MARK: - Water Log (Daily Summary)

/// Aggregates all water entries for a single day with progress tracking.
/// Calculates total intake, remaining ounces, and completion percentage against daily target.
public struct WaterLog: Codable, Identifiable, Sendable {
    public let id: UUID
    let date: Date
    public var entries: [WaterEntry]
    public var targetOunces: Double
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        entries: [WaterEntry] = [],
        targetOunces: Double = 100
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.entries = entries
        self.targetOunces = targetOunces
    }
    
    public var totalOunces: Double {
        entries.reduce(0) { $0 + $1.amount }
    }
    
    public var progress: Double {
        guard targetOunces > 0 else { return 0 }
        return min(totalOunces / targetOunces, 1.0)
    }
    
    public var isComplete: Bool {
        totalOunces >= targetOunces
    }
    
    public var remainingOunces: Double {
        max(targetOunces - totalOunces, 0)
    }
}

// MARK: - Quick Add Options

public enum WaterQuickAdd: Int, CaseIterable {
    case small = 8
    case medium = 12
    case large = 16
    case extraLarge = 24
    case bottle = 32
    
    public var ounces: Double {
        Double(rawValue)
    }
    
    public var displayText: String {
        "+\(rawValue)oz"
    }
    
    public var icon: String {
        switch self {
        case .small: return "drop"
        case .medium: return "drop.fill"
        case .large: return "waterbottle"
        case .extraLarge: return "waterbottle.fill"
        case .bottle: return "cylinder"
        }
    }
}
