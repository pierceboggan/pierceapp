import Foundation
import Combine

class TodayViewModel: ObservableObject {
    @Published var activeHabits: [HabitTemplate] = []
    @Published var habitLogs: [HabitLog] = []
    @Published var cleaningTasks: [CleaningTask] = []
    @Published var waterProgress: Double = 0
    @Published var waterAmount: Int = 0
    @Published var currentBooks: [Book] = []
    @Published var todaysSummary: DaySummary?
    
    private let habitService: HabitService
    private let cleaningService: CleaningService
    private let waterService: WaterService
    private let readingService: ReadingService
    private let summaryService: DaySummaryService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        habitService: HabitService = HabitService(),
        cleaningService: CleaningService = CleaningService(),
        waterService: WaterService = WaterService(),
        readingService: ReadingService = ReadingService(),
        summaryService: DaySummaryService = DaySummaryService()
    ) {
        self.habitService = habitService
        self.cleaningService = cleaningService
        self.waterService = waterService
        self.readingService = readingService
        self.summaryService = summaryService
        
        setupSubscriptions()
        refreshData()
    }
    
    private func setupSubscriptions() {
        habitService.$habits
            .sink { [weak self] habits in
                self?.activeHabits = habits.filter { $0.isActive }
            }
            .store(in: &cancellables)
        
        habitService.$habitLogs
            .sink { [weak self] logs in
                self?.habitLogs = logs
            }
            .store(in: &cancellables)
        
        cleaningService.$tasks
            .sink { [weak self] _ in
                self?.cleaningTasks = self?.cleaningService.getTodaysTasks() ?? []
            }
            .store(in: &cancellables)
        
        waterService.$todaysLog
            .sink { [weak self] log in
                guard let self = self else { return }
                self.waterAmount = log.totalOunces
                self.waterProgress = self.waterService.getTodayProgress()
            }
            .store(in: &cancellables)
        
        readingService.$books
            .sink { [weak self] _ in
                self?.currentBooks = self?.readingService.getCurrentlyReadingBooks() ?? []
            }
            .store(in: &cancellables)
    }
    
    func refreshData() {
        activeHabits = habitService.habits.filter { $0.isActive }
        habitLogs = habitService.getLogsForToday()
        cleaningTasks = cleaningService.getTodaysTasks()
        waterAmount = waterService.todaysLog.totalOunces
        waterProgress = waterService.getTodayProgress()
        currentBooks = readingService.getCurrentlyReadingBooks()
        updateSummary()
    }
    
    func toggleHabit(_ habit: HabitTemplate) {
        let existingLog = habitService.getLogForHabit(habitId: habit.id)
        let newCompleted = !(existingLog?.completed ?? false)
        habitService.logHabit(habitId: habit.id, completed: newCompleted)
        refreshData()
    }
    
    func logHabitValue(_ habit: HabitTemplate, value: Double) {
        habitService.logHabit(habitId: habit.id, completed: true, value: value)
        refreshData()
    }
    
    func addWater(_ ounces: Int) {
        waterService.addWater(ounces: ounces)
        refreshData()
    }
    
    func completeCleaningTask(_ task: CleaningTask) {
        cleaningService.completeTask(task)
        refreshData()
    }
    
    func updateSummary() {
        todaysSummary = summaryService.calculateDailySummary(
            habitService: habitService,
            cleaningService: cleaningService,
            waterService: waterService,
            readingService: readingService
        )
    }
}
