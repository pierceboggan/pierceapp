//
//  WaterLog.swift
//  Project2026
//
//  Water tracking models
//

import Foundation

// MARK: - Water Entry

struct WaterEntry: Codable, Identifiable {
    let id: UUID
    let amount: Double // in ounces
    let timestamp: Date
    
    init(
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

struct WaterLog: Codable, Identifiable {
    let id: UUID
    let date: Date
    var entries: [WaterEntry]
    var targetOunces: Double
    
    init(
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
    
    var totalOunces: Double {
        entries.reduce(0) { $0 + $1.amount }
    }
    
    var progress: Double {
        guard targetOunces > 0 else { return 0 }
        return min(totalOunces / targetOunces, 1.0)
    }
    
    var isComplete: Bool {
        totalOunces >= targetOunces
    }
    
    var remainingOunces: Double {
        max(targetOunces - totalOunces, 0)
    }
}

// MARK: - Quick Add Options

enum WaterQuickAdd: Int, CaseIterable {
    case small = 8
    case medium = 12
    case large = 16
    case extraLarge = 24
    case bottle = 32
    
    var ounces: Double {
        Double(rawValue)
    }
    
    var displayText: String {
        "+\(rawValue)oz"
    }
    
    var icon: String {
        switch self {
        case .small: return "drop"
        case .medium: return "drop.fill"
        case .large: return "waterbottle"
        case .extraLarge: return "waterbottle.fill"
        case .bottle: return "cylinder"
        }
    }
}
