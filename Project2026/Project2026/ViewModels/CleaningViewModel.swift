import Foundation

class CleaningViewModel: ObservableObject {
    @Published var tasks: [CleaningTask] = []
    @Published var todaysTasks: [CleaningTask] = []
    @Published var logs: [CleaningLog] = []
    
    private let cleaningService: CleaningService
    
    init(cleaningService: CleaningService = CleaningService()) {
        self.cleaningService = cleaningService
        loadTasks()
    }
    
    func loadTasks() {
        tasks = cleaningService.tasks
        todaysTasks = cleaningService.getTodaysTasks()
        logs = cleaningService.logs
    }
    
    func addTask(title: String, recurrence: CleaningRecurrence, estimatedMinutes: Int? = nil) {
        let task = CleaningTask(title: title, recurrence: recurrence, estimatedMinutes: estimatedMinutes)
        cleaningService.addTask(task)
        loadTasks()
    }
    
    func completeTask(_ task: CleaningTask, actualMinutes: Int? = nil) {
        cleaningService.completeTask(task, actualMinutes: actualMinutes)
        loadTasks()
    }
    
    func updateTask(_ task: CleaningTask) {
        cleaningService.updateTask(task)
        loadTasks()
    }
    
    func deleteTask(_ task: CleaningTask) {
        cleaningService.deleteTask(task)
        loadTasks()
    }
}
