import Foundation

class CleaningService: ObservableObject {
    @Published var tasks: [CleaningTask] = []
    @Published var logs: [CleaningLog] = []
    
    private let tasksKey = "cleaningTasks"
    private let logsKey = "cleaningLogs"
    
    init() {
        loadTasks()
        loadLogs()
        if tasks.isEmpty {
            createDefaultTasks()
        }
    }
    
    private func createDefaultTasks() {
        let defaultTasks: [CleaningTask] = [
            CleaningTask(title: "Kitchen reset", recurrence: .daily, estimatedMinutes: 15),
            CleaningTask(title: "Floors", recurrence: .weekly, estimatedMinutes: 30),
            CleaningTask(title: "Bathrooms", recurrence: .weekly, estimatedMinutes: 25),
            CleaningTask(title: "Laundry", recurrence: .weekly, estimatedMinutes: 60),
            CleaningTask(title: "Fridge clean-out", recurrence: .weekly, estimatedMinutes: 20),
            CleaningTask(title: "Bedding", recurrence: .weekly, estimatedMinutes: 15),
            CleaningTask(title: "Car clean", recurrence: .monthly, estimatedMinutes: 45),
            CleaningTask(title: "Garage/Gear tidy", recurrence: .monthly, estimatedMinutes: 30)
        ]
        
        tasks = defaultTasks
        saveTasks()
    }
    
    func addTask(_ task: CleaningTask) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: CleaningTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: CleaningTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func completeTask(_ task: CleaningTask, actualMinutes: Int? = nil, note: String? = nil) {
        let log = CleaningLog(taskId: task.id, actualMinutes: actualMinutes, note: note)
        logs.append(log)
        
        // Update task with new next due date
        var updatedTask = task
        updatedTask.lastCompletedDate = Date()
        updatedTask.nextDueDate = calculateNextDueDate(for: task)
        updateTask(updatedTask)
        
        saveLogs()
    }
    
    func getTodaysTasks() -> [CleaningTask] {
        let today = Date()
        return tasks.filter { $0.isActive && $0.nextDueDate <= today }
            .sorted { task1, task2 in
                if task1.isOverdue != task2.isOverdue {
                    return task1.isOverdue
                }
                return task1.nextDueDate < task2.nextDueDate
            }
            .prefix(3)
            .map { $0 }
    }
    
    private func calculateNextDueDate(for task: CleaningTask) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch task.recurrence {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: now) ?? now
        case .custom:
            return calendar.date(byAdding: .day, value: 7, to: now) ?? now
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([CleaningTask].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([CleaningLog].self, from: data) {
            logs = decoded
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
    }
}
