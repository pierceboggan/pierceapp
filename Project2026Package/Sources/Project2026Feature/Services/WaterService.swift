//
//  WaterService.swift
//  Project2026
//
//  Service for tracking water consumption
//

import SwiftUI

/// Tracks daily water intake against a configurable target (default 100oz).
/// Provides quick-add buttons (8oz, 16oz, 24oz, 32oz) and calculates progress percentage.
/// Creates a new WaterLog each day to maintain daily history.
@MainActor
public class WaterService: ObservableObject {
    @Published var waterLogs: [WaterLog] = []
    @Published var dailyTarget: Double = 100 // ounces
    @Published var isLoading = false
    
    private let persistence = PersistenceManager.shared
    
    public init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    public func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            waterLogs = try await persistence.load([WaterLog].self, from: StorageKey.waterLogs)
        } catch {
            waterLogs = []
        }
    }
    
    // MARK: - Today's Water
    
    public var todayLog: WaterLog {
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = waterLogs.first(where: { $0.date == today }) {
            return existing
        }
        return WaterLog(date: Date(), targetOunces: dailyTarget)
    }
    
    public var todayTotal: Double {
        todayLog.totalOunces
    }
    
    public var todayProgress: Double {
        todayLog.progress
    }
    
    public var todayRemaining: Double {
        todayLog.remainingOunces
    }
    
    public var isTodayComplete: Bool {
        todayLog.isComplete
    }
    
    // MARK: - Adding Water
    
    public func addWater(_ amount: Double) async {
        await addWater(amount, on: Date())
    }
    
    /// Add water for a specific date
    public func addWater(_ amount: Double, on date: Date) async {
        let dayStart = Calendar.current.startOfDay(for: date)
        let entry = WaterEntry(amount: amount)
        
        if let index = waterLogs.firstIndex(where: { $0.date == dayStart }) {
            waterLogs[index].entries.append(entry)
        } else {
            var newLog = WaterLog(date: date, targetOunces: dailyTarget)
            newLog.entries.append(entry)
            waterLogs.append(newLog)
        }
        
        await save()
    }
    
    public func addWater(quickAdd: WaterQuickAdd) async {
        await addWater(quickAdd.ounces)
    }
    
    public func removeLastEntry() async {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = waterLogs.firstIndex(where: { $0.date == today }) {
            if !waterLogs[index].entries.isEmpty {
                waterLogs[index].entries.removeLast()
                await save()
            }
        }
    }
    
    public func setManualTotal(_ amount: Double) async {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = waterLogs.firstIndex(where: { $0.date == today }) {
            // Replace all entries with a single entry of the specified amount
            waterLogs[index].entries = [WaterEntry(amount: amount)]
        } else {
            var newLog = WaterLog(date: Date(), targetOunces: dailyTarget)
            newLog.entries = [WaterEntry(amount: amount)]
            waterLogs.append(newLog)
        }
        
        await save()
    }
    
    // MARK: - History
    
    public func waterLog(for date: Date) -> WaterLog? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return waterLogs.first { $0.date == dayStart }
    }
    
    public func totalOunces(for date: Date) -> Double {
        waterLog(for: date)?.totalOunces ?? 0
    }
    
    /// Progress for a specific date (0.0 to 1.0)
    public func progress(for date: Date) -> Double {
        waterLog(for: date)?.progress ?? 0
    }
    
    /// Check if water goal is complete for a specific date
    public func isComplete(for date: Date) -> Bool {
        waterLog(for: date)?.isComplete ?? false
    }
    
    public func weeklyAverage() -> Double {
        let calendar = Calendar.current
        let today = Date()
        var total: Double = 0
        var count = 0
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            if let log = waterLog(for: date) {
                total += log.totalOunces
                count += 1
            }
        }
        
        return count > 0 ? total / Double(count) : 0
    }
    
    public func weeklyData() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(Date, Double)] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let amount = waterLog(for: date)?.totalOunces ?? 0
            data.append((date, amount))
        }
        
        return data
    }
    
    // MARK: - Target Management
    
    public func updateDailyTarget(_ target: Double) async {
        dailyTarget = target
        
        // Update today's log target
        let today = Calendar.current.startOfDay(for: Date())
        if let index = waterLogs.firstIndex(where: { $0.date == today }) {
            waterLogs[index].targetOunces = target
            await save()
        }
    }
    
    // MARK: - Persistence
    
    private func save() async {
        do {
            try await persistence.save(waterLogs, to: StorageKey.waterLogs)
        } catch {
            print("Failed to save water logs: \(error)")
        }
    }
}
