import Testing
import Foundation
@testable import Project2026TV

/// Tests for tvOS-specific service implementations.
@Suite("tvOS Services Tests")
struct TVServicesTests {
    
    // MARK: - TVMobilityService Tests
    
    @Test("Mobility service initializes with default values")
    func mobilityServiceInitialization() {
        let service = TVMobilityService()
        
        #expect(service.todayMinutes >= 0)
        #expect(service.currentStreak >= 0)
        #expect(service.totalSessions >= 0)
    }
    
    @Test("Can record a mobility session")
    func canRecordSession() {
        let service = TVMobilityService()
        let initialMinutes = service.todayMinutes
        let initialSessions = service.totalSessions
        
        service.recordSession(minutes: 10)
        
        #expect(service.todayMinutes == initialMinutes + 10)
        #expect(service.totalSessions == initialSessions + 1)
    }
    
    @Test("Recording session increases streak")
    func recordingSessionIncreasesStreak() {
        let service = TVMobilityService()
        let initialStreak = service.currentStreak
        
        service.recordSession(minutes: 10)
        
        #expect(service.currentStreak == initialStreak + 1)
    }
    
    // MARK: - TVStatsService Tests
    
    @Test("Stats service initializes with values")
    func statsServiceInitialization() {
        let service = TVStatsService()
        
        #expect(service.weeklyMinutes >= 0)
        #expect(service.monthlyMinutes >= 0)
        #expect(service.totalMinutes >= 0)
    }
    
    @Test("Weekly data has correct number of days")
    func weeklyDataHasSevenDays() {
        let service = TVStatsService()
        
        #expect(service.weeklyData.count == 7, "Should have 7 days of data")
    }
    
    @Test("Weekly data days are valid")
    func weeklyDataDaysAreValid() {
        let service = TVStatsService()
        let validDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        for data in service.weeklyData {
            #expect(validDays.contains(data.day), "\(data.day) should be a valid day abbreviation")
            #expect(data.minutes >= 0, "Minutes should be non-negative")
        }
    }
}

// MARK: - TVMobilityRoutine Tests

@Suite("tvOS Mobility Routine Tests")
struct TVMobilityRoutineTests {
    
    @Test("Bike routine exists and has exercises")
    func bikeRoutineExists() {
        let routine = TVMobilityRoutine.bikeRoutine
        
        #expect(routine.exercises.count > 0)
        #expect(routine.name == "Bike Mobility")
    }
    
    @Test("Bike routine has 10 exercises")
    func bikeRoutineHasTenExercises() {
        let routine = TVMobilityRoutine.bikeRoutine
        
        #expect(routine.exercises.count == 10, "Bike routine should have exactly 10 exercises")
    }
    
    @Test("Each exercise has required properties")
    func exercisesHaveRequiredProperties() {
        let routine = TVMobilityRoutine.bikeRoutine
        
        for exercise in routine.exercises {
            #expect(!exercise.name.isEmpty, "Exercise name should not be empty")
            #expect(!exercise.instructions.isEmpty, "Exercise instructions should not be empty")
            #expect(!exercise.iconName.isEmpty, "Exercise icon should not be empty")
            #expect(!exercise.targetArea.isEmpty, "Exercise target area should not be empty")
            #expect(exercise.durationSeconds > 0, "Exercise duration should be positive")
        }
    }
    
    @Test("Exercise durations are reasonable")
    func exerciseDurationsAreReasonable() {
        let routine = TVMobilityRoutine.bikeRoutine
        
        for exercise in routine.exercises {
            #expect(exercise.durationSeconds >= 30, "\(exercise.name) should be at least 30 seconds")
            #expect(exercise.durationSeconds <= 120, "\(exercise.name) should be at most 2 minutes")
        }
    }
    
    @Test("Total routine duration is around 10 minutes")
    func totalDurationIsAboutTenMinutes() {
        let routine = TVMobilityRoutine.bikeRoutine
        
        #expect(routine.totalDurationMinutes >= 8, "Routine should be at least 8 minutes")
        #expect(routine.totalDurationMinutes <= 12, "Routine should be at most 12 minutes")
    }
    
    @Test("Exercises cover different body areas")
    func exercisesCoverDifferentAreas() {
        let routine = TVMobilityRoutine.bikeRoutine
        let targetAreas = Set(routine.exercises.map { $0.targetArea })
        
        #expect(targetAreas.count >= 4, "Should target at least 4 different body areas")
    }
    
    @Test("Routine includes bilateral stretches")
    func routineIncludesBilateralStretches() {
        let routine = TVMobilityRoutine.bikeRoutine
        let exerciseNames = routine.exercises.map { $0.name }
        
        // Check for left/right pairs
        let hasLeftHipFlexor = exerciseNames.contains { $0.contains("Left") && $0.contains("Hip") }
        let hasRightHipFlexor = exerciseNames.contains { $0.contains("Right") && $0.contains("Hip") }
        
        #expect(hasLeftHipFlexor && hasRightHipFlexor, "Should have both left and right hip flexor stretches")
    }
}

// MARK: - TVMobilityExercise Tests

@Suite("tvOS Mobility Exercise Model Tests")
struct TVMobilityExerciseTests {
    
    @Test("Exercise has unique ID")
    func exerciseHasUniqueId() {
        let exercise1 = TVMobilityExercise(
            name: "Test 1",
            instructions: "Test instructions",
            durationSeconds: 60,
            iconName: "figure.flexibility",
            targetArea: "Test"
        )
        let exercise2 = TVMobilityExercise(
            name: "Test 2",
            instructions: "Test instructions",
            durationSeconds: 60,
            iconName: "figure.flexibility",
            targetArea: "Test"
        )
        
        #expect(exercise1.id != exercise2.id)
    }
    
    @Test("Exercise is identifiable")
    func exerciseIsIdentifiable() {
        let exercise = TVMobilityExercise(
            name: "Test",
            instructions: "Test instructions",
            durationSeconds: 60,
            iconName: "figure.flexibility",
            targetArea: "Test"
        )
        
        #expect(exercise.id != UUID())
    }
}
