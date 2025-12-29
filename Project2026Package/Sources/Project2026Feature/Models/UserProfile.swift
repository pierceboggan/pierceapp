//
//  UserProfile.swift
//  Project2026
//
//  User profile model
//

import Foundation

/// Stores user preferences and daily targets including water intake, protein goals,
/// wake/sleep times, and work schedule. These values personalize the habit tracking experience.
public struct UserProfile: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var dailyWaterTarget: Double // in ounces
    public var dailyProteinTarget: Double // in grams
    public var wakeUpTime: Date
    public var lightsOutTime: Date
    public var workStartTime: Date
    public var workEndTime: Date
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String = "User",
        dailyWaterTarget: Double = 100,
        dailyProteinTarget: Double = 145,
        wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 5, minute: 30)) ?? Date(),
        lightsOutTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
        workStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        workEndTime: Date = Calendar.current.date(from: DateComponents(hour: 17, minute: 30)) ?? Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dailyWaterTarget = dailyWaterTarget
        self.dailyProteinTarget = dailyProteinTarget
        self.wakeUpTime = wakeUpTime
        self.lightsOutTime = lightsOutTime
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
