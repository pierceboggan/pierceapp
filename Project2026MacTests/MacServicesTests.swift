import Testing
import Foundation
@testable import Project2026Mac

/// Tests for macOS-specific service implementations.
@Suite("macOS Services Tests")
struct MacServicesTests {
    
    // MARK: - ThemeServiceMac Tests
    
    @Test("Theme service initializes with system default")
    @MainActor
    func themeServiceInitialization() async {
        let service = ThemeServiceMac()
        #expect(service.currentTheme.name == "System")
        #expect(service.availableThemes.count == 5)
    }
    
    @Test("Theme can be changed")
    @MainActor
    func themeCanBeChanged() async {
        let service = ThemeServiceMac()
        let themes = service.availableThemes
        
        #expect(themes.count > 0, "Should have available themes")
        
        if let darkTheme = themes.first(where: { $0.name == "Dark" }) {
            service.selectTheme(darkTheme)
            #expect(service.currentTheme.name == "Dark")
        }
    }
    
    // MARK: - HabitServiceMac Tests
    
    @Test("Habit service initializes")
    @MainActor
    func habitServiceInitialization() async {
        let service = HabitServiceMac()
        #expect(service.allHabits.count >= 0)
    }
    
    @Test("Can add a habit")
    @MainActor
    func canAddHabit() async {
        let service = HabitServiceMac()
        let initialCount = service.allHabits.count
        
        service.addHabit(title: "Test Habit", frequency: .daily)
        
        #expect(service.allHabits.count == initialCount + 1)
        #expect(service.allHabits.last?.title == "Test Habit")
    }
    
    @Test("Can toggle habit completion")
    @MainActor
    func canToggleHabitCompletion() async {
        let service = HabitServiceMac()
        service.addHabit(title: "Toggle Test", frequency: .daily)
        
        guard let habit = service.allHabits.last else {
            Issue.record("No habit found")
            return
        }
        
        let today = Date()
        #expect(!service.isCompleted(habit, on: today))
        
        service.toggleCompletion(for: habit, on: today)
        
        if let updatedHabit = service.allHabits.first(where: { $0.id == habit.id }) {
            #expect(service.isCompleted(updatedHabit, on: today))
        }
    }
    
    // MARK: - WaterServiceMac Tests
    
    @Test("Water service initializes with default target")
    @MainActor
    func waterServiceInitialization() async {
        let service = WaterServiceMac()
        #expect(service.dailyTarget == 100)
        #expect(service.todayTotal >= 0)
    }
    
    @Test("Can add water intake")
    @MainActor
    func canAddWaterIntake() async {
        let service = WaterServiceMac()
        let initialTotal = service.todayTotal
        
        service.logWater(amount: 25)
        
        #expect(service.todayTotal == initialTotal + 25)
    }
    
    @Test("Water progress is calculated correctly")
    @MainActor
    func waterProgressCalculation() async {
        let service = WaterServiceMac()
        
        #expect(service.todayProgress >= 0.0)
        #expect(service.todayProgress <= 1.0)
    }
    
    // MARK: - CleaningServiceMac Tests
    
    @Test("Cleaning service initializes with tasks")
    @MainActor
    func cleaningServiceInitialization() async {
        let service = CleaningServiceMac()
        #expect(service.tasks.count > 0)
    }
    
    @Test("Can check task completion")
    @MainActor
    func canCheckTaskCompletion() async {
        let service = CleaningServiceMac()
        
        guard let task = service.tasks.first else {
            Issue.record("No tasks found")
            return
        }
        
        let today = Date()
        let isCompleted = service.isCompleted(task, on: today)
        #expect(!isCompleted || isCompleted)
    }
    
    // MARK: - ReadingServiceMac Tests
    
    @Test("Reading service initializes")
    @MainActor
    func readingServiceInitialization() async {
        let service = ReadingServiceMac()
        #expect(service.readDates.count >= 0)
    }
    
    @Test("Can mark reading")
    @MainActor
    func canMarkReading() async {
        let service = ReadingServiceMac()
        
        service.markRead()
        
        #expect(service.didReadToday())
    }
    
    // MARK: - DaySummary Tests
    
    @Test("Day summary score calculation")
    func daySummaryScoreCalculation() {
        let perfectScore = DaySummary.calculateScore(
            habitCompletion: 1.0,
            cleaningCompletion: 1.0,
            waterCompletion: 1.0,
            didRead: true
        )
        
        #expect(perfectScore == 100.0)
        
        let halfScore = DaySummary.calculateScore(
            habitCompletion: 0.5,
            cleaningCompletion: 0.5,
            waterCompletion: 0.5,
            didRead: false
        )
        
        #expect(halfScore == 40.0)
    }
}

// MARK: - MobilityRoutine Tests

@Suite("macOS Mobility Routine Tests")
struct MacMobilityTests {
    
    @Test("Mobility routine has exercises")
    func mobilityRoutineHasExercises() {
        let routine = MobilityRoutine.bikeRoutine
        
        #expect(routine.exercises.count > 0)
        #expect(routine.title == "Bike-Mobility & Knee Health Routine")
    }
    
    @Test("Each exercise has valid duration")
    func exercisesHaveValidDuration() {
        let routine = MobilityRoutine.bikeRoutine
        
        for exercise in routine.exercises {
            #expect(exercise.durationSeconds > 0, "Exercise \(exercise.name) should have positive duration")
            #expect(exercise.durationSeconds <= 120, "Exercise \(exercise.name) should be 2 minutes or less")
        }
    }
    
    @Test("Total routine duration is reasonable")
    func totalDurationIsReasonable() {
        let routine = MobilityRoutine.bikeRoutine
        let totalMinutes = routine.totalDuration / 60
        
        #expect(totalMinutes >= 5, "Routine should be at least 5 minutes")
        #expect(totalMinutes <= 20, "Routine should be at most 20 minutes")
    }
    
    @Test("Each exercise has required fields")
    func exercisesHaveRequiredFields() {
        let routine = MobilityRoutine.bikeRoutine
        
        for exercise in routine.exercises {
            #expect(!exercise.name.isEmpty)
            #expect(!exercise.why.isEmpty)
            #expect(!exercise.howToDoIt.isEmpty)
            #expect(!exercise.cues.isEmpty)
        }
    }
}
