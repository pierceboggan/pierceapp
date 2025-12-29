import Foundation

class DaySummaryService: ObservableObject {
    @Published var summaries: [DaySummary] = []
    
    private let summariesKey = "daySummaries"
    
    init() {
        loadSummaries()
    }
    
    func calculateDailySummary(
        habitService: HabitService,
        cleaningService: CleaningService,
        waterService: WaterService,
        readingService: ReadingService,
        date: Date = Date()
    ) -> DaySummary {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Calculate habits
        let activeHabits = habitService.habits.filter { $0.isActive }
        let todaysLogs = habitService.habitLogs.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let completedHabits = todaysLogs.filter { $0.completed }.count
        
        // Calculate cleaning
        let todaysTasks = cleaningService.tasks.filter { $0.isActive && calendar.isDate($0.nextDueDate, inSameDayAs: date) }
        let completedCleaning = cleaningService.logs.filter { calendar.isDate($0.completedDate, inSameDayAs: date) }.count
        
        // Get water
        let waterConsumed = waterService.todaysLog.totalOunces
        let waterTarget = waterService.dailyTarget
        
        // Get reading
        let pagesRead = readingService.getTotalPagesReadToday()
        
        // Calculate score (simplified algorithm)
        let habitScore = activeHabits.count > 0 ? Double(completedHabits) / Double(activeHabits.count) : 0
        let cleaningScore = todaysTasks.count > 0 ? Double(completedCleaning) / Double(todaysTasks.count) : 1.0
        let waterScore = waterTarget > 0 ? min(Double(waterConsumed) / Double(waterTarget), 1.0) : 0
        let readingScore = pagesRead > 0 ? 1.0 : 0.0
        
        let totalScore = (habitScore * 0.5 + cleaningScore * 0.2 + waterScore * 0.2 + readingScore * 0.1) * 100
        
        let summary = DaySummary(
            date: startOfDay,
            habitsCompleted: completedHabits,
            habitsTotal: activeHabits.count,
            cleaningCompleted: completedCleaning,
            cleaningTotal: todaysTasks.count,
            waterConsumed: waterConsumed,
            waterTarget: waterTarget,
            pagesRead: pagesRead,
            score: totalScore
        )
        
        // Save or update summary
        if let index = summaries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            summaries[index] = summary
        } else {
            summaries.append(summary)
        }
        saveSummaries()
        
        return summary
    }
    
    func getSummary(for date: Date) -> DaySummary? {
        let calendar = Calendar.current
        return summaries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getWeeklySummaries() -> [DaySummary] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        return summaries.filter { $0.date >= weekAgo && $0.date <= today }
            .sorted { $0.date < $1.date }
    }
    
    private func loadSummaries() {
        if let data = UserDefaults.standard.data(forKey: summariesKey),
           let decoded = try? JSONDecoder().decode([DaySummary].self, from: data) {
            summaries = decoded
        }
    }
    
    private func saveSummaries() {
        if let encoded = try? JSONEncoder().encode(summaries) {
            UserDefaults.standard.set(encoded, forKey: summariesKey)
        }
    }
}
