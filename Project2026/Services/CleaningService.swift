//
//  CleaningService.swift
//  Project2026
//
//  Service for managing cleaning tasks and rotation
//

import SwiftUI

@MainActor
class CleaningService: ObservableObject {
    @Published var tasks: [CleaningTask] = []
    @Published var logs: [CleaningLog] = []
    @Published var isLoading = false
    
    private let persistence = PersistenceManager.shared
    private let maxDailyTasks = 3
    
    init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load tasks
        do {
            tasks = try await persistence.load([CleaningTask].self, from: StorageKey.cleaningTasks)
        } catch {
            // Initialize with default tasks
            tasks = CleaningTask.defaultTasks
            await saveTasks()
        }
        
        // Load logs
        do {
            logs = try await persistence.load([CleaningLog].self, from: StorageKey.cleaningLogs)
        } catch {
            logs = []
        }
    }
    
    // MARK: - Task Management
    
    var activeTasks: [CleaningTask] {
        tasks.filter { $0.isActive }
    }
    
    var archivedTasks: [CleaningTask] {
        tasks.filter { !$0.isActive }
    }
    
    /// Returns today's cleaning tasks (prioritized by overdue, then due today)
    func tasksForToday() -> [CleaningTask] {
        let availableTasks = activeTasks.filter { !$0.isSnoozed }
        
        // Sort by priority: overdue first, then due today, then by days until due
        let sorted = availableTasks.sorted { task1, task2 in
            if task1.isOverdue && !task2.isOverdue { return true }
            if !task1.isOverdue && task2.isOverdue { return false }
            
            let days1 = task1.daysUntilDue ?? 0
            let days2 = task2.daysUntilDue ?? 0
            return days1 < days2
        }
        
        // Return up to maxDailyTasks
        return Array(sorted.prefix(maxDailyTasks))
    }
    
    var overdueTasks: [CleaningTask] {
        activeTasks.filter { $0.isOverdue && !$0.isSnoozed }
    }
    
    var dueTodayTasks: [CleaningTask] {
        activeTasks.filter { $0.isDueToday && !$0.isSnoozed }
    }
    
    func addTask(_ task: CleaningTask) async {
        tasks.append(task)
        await saveTasks()
    }
    
    func updateTask(_ task: CleaningTask) async {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            await saveTasks()
        }
    }
    
    func archiveTask(_ task: CleaningTask) async {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isActive = false
            await saveTasks()
        }
    }
    
    func restoreTask(_ task: CleaningTask) async {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isActive = true
            await saveTasks()
        }
    }
    
    func deleteTask(_ task: CleaningTask) async {
        tasks.removeAll { $0.id == task.id }
        await saveTasks()
    }
    
    // MARK: - Task Completion
    
    func completeTask(_ task: CleaningTask, durationMinutes: Int? = nil, note: String? = nil) async {
        // Create log entry
        let log = CleaningLog(
            taskId: task.id,
            completedDate: Date(),
            durationMinutes: durationMinutes,
            note: note
        )
        logs.append(log)
        
        // Update task's last completed date
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].lastCompletedDate = Date()
            tasks[index].snoozedUntil = nil // Clear any snooze
        }
        
        await saveTasks()
        await saveLogs()
    }
    
    func snoozeTask(_ task: CleaningTask, until date: Date) async {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].snoozedUntil = date
            await saveTasks()
        }
    }
    
    func snoozeTaskForOneDay(_ task: CleaningTask) async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        await snoozeTask(task, until: tomorrow)
    }
    
    func clearSnooze(_ task: CleaningTask) async {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].snoozedUntil = nil
            await saveTasks()
        }
    }
    
    // MARK: - Statistics
    
    func completionRate(for date: Date) -> Double {
        let todayTasks = tasksForToday()
        guard !todayTasks.isEmpty else { return 1.0 }
        
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let completedToday = logs.filter { log in
            log.completedDate >= dayStart && log.completedDate < dayEnd &&
            todayTasks.contains { $0.id == log.taskId }
        }.count
        
        return Double(completedToday) / Double(todayTasks.count)
    }
    
    func completedTasksCount(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        return logs.filter { $0.completedDate >= dayStart && $0.completedDate < dayEnd }.count
    }
    
    func isTaskCompleted(_ task: CleaningTask, on date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        return logs.contains { log in
            log.taskId == task.id && log.completedDate >= dayStart && log.completedDate < dayEnd
        }
    }
    
    func logsForTask(_ taskId: UUID) -> [CleaningLog] {
        logs.filter { $0.taskId == taskId }
            .sorted { $0.completedDate > $1.completedDate }
    }
    
    // MARK: - Persistence
    
    private func saveTasks() async {
        do {
            try await persistence.save(tasks, to: StorageKey.cleaningTasks)
        } catch {
            print("Failed to save cleaning tasks: \(error)")
        }
    }
    
    private func saveLogs() async {
        do {
            try await persistence.save(logs, to: StorageKey.cleaningLogs)
        } catch {
            print("Failed to save cleaning logs: \(error)")
        }
    }
}
