//
//  UserProfile.swift
//  Project2026
//
//  User profile model
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var dailyWaterTarget: Double // in ounces
    var dailyProteinTarget: Double // in grams
    var wakeUpTime: Date
    var lightsOutTime: Date
    var workStartTime: Date
    var workEndTime: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(
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
