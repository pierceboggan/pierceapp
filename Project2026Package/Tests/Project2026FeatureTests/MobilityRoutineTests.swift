import Testing
@testable import Project2026Feature

@Suite("Mobility Exercise Tests")
struct MobilityExerciseTests {
    
    @Test("Mobility routine contains all 10 exercises")
    func routineHasAllExercises() {
        let routine = MobilityRoutine.bikeRoutine
        
        #expect(routine.exercises.count == 10)
        #expect(routine.title == "Bike-Mobility & Knee Health Routine")
    }
    
    @Test("All exercises have required properties")
    func exercisesHaveRequiredProperties() {
        let routine = MobilityRoutine.bikeRoutine
        
        for exercise in routine.exercises {
            #expect(!exercise.name.isEmpty, "Exercise name should not be empty")
            #expect(!exercise.why.isEmpty, "Exercise 'why' should not be empty")
            #expect(!exercise.howToDoIt.isEmpty, "Exercise instructions should not be empty")
            #expect(!exercise.cues.isEmpty, "Exercise cues should not be empty")
            #expect(exercise.durationSeconds > 0, "Exercise duration should be positive")
        }
    }
    
    @Test("Total routine duration is calculated correctly")
    func totalDurationCalculation() {
        let routine = MobilityRoutine.bikeRoutine
        
        let expectedTotal = routine.exercises.reduce(0) { $0 + $1.durationSeconds }
        #expect(routine.totalDuration == expectedTotal)
        #expect(routine.totalDuration > 0)
    }
    
    @Test("Exercise names are unique")
    func exerciseNamesAreUnique() {
        let routine = MobilityRoutine.bikeRoutine
        let names = routine.exercises.map { $0.name }
        let uniqueNames = Set(names)
        
        #expect(names.count == uniqueNames.count, "All exercise names should be unique")
    }
}

@Suite("Mobility Timer Service Tests")
@MainActor
struct MobilityTimerServiceTests {
    
    @Test("Timer starts with correct initial state")
    func timerInitialState() {
        let service = MobilityTimerService()
        
        #expect(!service.isRunning)
        #expect(!service.isPaused)
        #expect(service.currentExerciseIndex == 0)
        #expect(service.timeRemaining == 0)
        #expect(!service.isComplete)
    }
    
    @Test("Current exercise is correct")
    func currentExerciseSelection() {
        let service = MobilityTimerService()
        
        let firstExercise = service.currentExercise
        #expect(firstExercise != nil)
        #expect(firstExercise?.name == MobilityRoutine.bikeRoutine.exercises[0].name)
    }
    
    @Test("Progress calculation works correctly")
    func progressCalculation() {
        let service = MobilityTimerService()
        
        // Initial progress should be 0
        #expect(service.progress == 0.0)
        
        // After starting, progress should update
        service.start()
        
        // Time remaining should be set
        #expect(service.timeRemaining > 0)
        #expect(service.isRunning)
    }
    
    @Test("Time formatting works correctly")
    func timeFormatting() {
        let service = MobilityTimerService()
        service.start()
        
        let formatted = service.formattedTimeRemaining()
        #expect(formatted.contains(":"), "Formatted time should contain colon separator")
    }
    
    @Test("Skip to next exercise works")
    func skipToNextExercise() {
        let service = MobilityTimerService()
        service.start()
        
        let initialIndex = service.currentExerciseIndex
        service.skipToNext()
        
        #expect(service.currentExerciseIndex == initialIndex + 1)
    }
    
    @Test("Skip to previous exercise works")
    func skipToPreviousExercise() {
        let service = MobilityTimerService()
        service.start()
        
        // Skip forward first
        service.skipToNext()
        let currentIndex = service.currentExerciseIndex
        
        // Skip back
        service.skipToPrevious()
        
        #expect(service.currentExerciseIndex == currentIndex - 1)
    }
    
    @Test("Pause and resume functionality")
    func pauseAndResume() {
        let service = MobilityTimerService()
        service.start()
        
        #expect(service.isRunning)
        #expect(!service.isPaused)
        
        service.pause()
        
        #expect(service.isPaused)
        #expect(service.isRunning)
        
        service.resume()
        
        #expect(!service.isPaused)
        #expect(service.isRunning)
    }
    
    @Test("Reset functionality works")
    func resetTimer() {
        let service = MobilityTimerService()
        service.start()
        service.skipToNext()
        
        service.reset()
        
        #expect(!service.isRunning)
        #expect(!service.isPaused)
        #expect(service.currentExerciseIndex == 0)
        #expect(service.timeRemaining == 0)
    }
    
    @Test("Completion state is correct")
    func completionState() {
        let service = MobilityTimerService()
        
        // Initially not complete
        #expect(!service.isComplete)
        
        // Skip through all exercises
        for _ in 0..<MobilityRoutine.bikeRoutine.exercises.count {
            service.skipToNext()
        }
        
        // Should now be complete
        #expect(service.isComplete)
    }
}
