import SwiftUI
import Project2026Feature

@main
struct Project2026App: App {
    @StateObject private var themeService = ThemeService()
    @StateObject private var habitService = HabitService()
    @StateObject private var cleaningService = CleaningService()
    @StateObject private var waterService = WaterService()
    @StateObject private var readingService = ReadingService()
    @StateObject private var daySummaryService = DaySummaryService()
    @StateObject private var workoutService = WorkoutService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeService)
                .environmentObject(habitService)
                .environmentObject(cleaningService)
                .environmentObject(waterService)
                .environmentObject(readingService)
                .environmentObject(daySummaryService)
                .environmentObject(workoutService)
                .preferredColorScheme(themeService.currentTheme.colorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Update widget data when app goes to background
                    updateWidgetData()
                }
        }
    }
    
    private func updateWidgetData() {
        let defaults = UserDefaults(suiteName: "group.com.project2026.app")
        
        // Calculate current score
        let habitCompletion = habitService.completionRate(for: Date())
        let cleaningCompletion = cleaningService.completionRate(for: Date())
        let waterCompletion = waterService.todayProgress
        let didRead = readingService.didReadToday()
        
        let score = DaySummary.calculateScore(
            habitCompletion: habitCompletion,
            cleaningCompletion: cleaningCompletion,
            waterCompletion: waterCompletion,
            didRead: didRead
        )
        
        defaults?.set(score, forKey: "widget_score")
        defaults?.set(habitService.completedCount(for: Date()), forKey: "widget_habits_completed")
        defaults?.set(habitService.habitsForToday().count, forKey: "widget_habits_total")
        defaults?.set(Int(waterService.todayTotal), forKey: "widget_water_current")
        defaults?.set(Int(waterService.dailyTarget), forKey: "widget_water_target")
        defaults?.set(cleaningService.tasksForToday().first?.title, forKey: "widget_next_cleaning")
        defaults?.set(didRead, forKey: "widget_did_read")
    }
}
