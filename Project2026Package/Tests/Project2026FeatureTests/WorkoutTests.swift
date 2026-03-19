import Testing
@testable import Project2026Feature

@Suite("Workout Type Tests")
struct WorkoutTypeTests {

    @Test("All workout types have icons")
    func allTypesHaveIcons() {
        for workoutType in WorkoutType.allCases {
            #expect(!workoutType.icon.isEmpty, "Workout type \(workoutType.rawValue) should have an icon")
        }
    }

    @Test("All workout types have colors")
    func allTypesHaveColors() {
        for workoutType in WorkoutType.allCases {
            #expect(!workoutType.color.isEmpty, "Workout type \(workoutType.rawValue) should have a color")
        }
    }

    @Test("Workout type raw values are correct")
    func rawValuesAreCorrect() {
        #expect(WorkoutType.cycling.rawValue == "Cycling")
        #expect(WorkoutType.running.rawValue == "Running")
        #expect(WorkoutType.strength.rawValue == "Strength")
        #expect(WorkoutType.yoga.rawValue == "Yoga")
        #expect(WorkoutType.swimming.rawValue == "Swimming")
        #expect(WorkoutType.hiking.rawValue == "Hiking")
        #expect(WorkoutType.skiing.rawValue == "Skiing")
        #expect(WorkoutType.other.rawValue == "Other")
    }
}

@Suite("Workout Intensity Tests")
struct WorkoutIntensityTests {

    @Test("All intensities have icons")
    func allIntensitiesHaveIcons() {
        for intensity in WorkoutIntensity.allCases {
            #expect(!intensity.icon.isEmpty, "Intensity \(intensity.rawValue) should have an icon")
        }
    }

    @Test("TSS multipliers are correct")
    func tssMultipliersAreCorrect() {
        #expect(WorkoutIntensity.easy.tssMultiplier == 0.5)
        #expect(WorkoutIntensity.moderate.tssMultiplier == 0.7)
        #expect(WorkoutIntensity.hard.tssMultiplier == 0.9)
        #expect(WorkoutIntensity.veryHard.tssMultiplier == 1.1)
    }

    @Test("Intensities have correct raw values")
    func rawValuesAreCorrect() {
        #expect(WorkoutIntensity.easy.rawValue == "Easy")
        #expect(WorkoutIntensity.moderate.rawValue == "Moderate")
        #expect(WorkoutIntensity.hard.rawValue == "Hard")
        #expect(WorkoutIntensity.veryHard.rawValue == "Very Hard")
    }
}

@Suite("Workout Model Tests")
struct WorkoutTests {

    @Test("Workout initialization with default values")
    func defaultInitialization() {
        let workout = Workout(
            type: .cycling,
            title: "Morning Ride",
            durationMinutes: 60
        )

        #expect(workout.type == .cycling)
        #expect(workout.title == "Morning Ride")
        #expect(workout.durationMinutes == 60)
        #expect(workout.intensity == .moderate)
        #expect(workout.notes == nil)
        #expect(workout.tss == nil)
    }

    @Test("Workout date is normalized to start of day")
    func dateNormalization() {
        let now = Date()
        let workout = Workout(
            type: .running,
            title: "Run",
            date: now,
            durationMinutes: 30
        )

        let expectedDate = Calendar.current.startOfDay(for: now)
        #expect(workout.date == expectedDate)
    }

    @Test("Estimated TSS calculation when TSS not provided")
    func estimatedTSSCalculation() {
        let workout = Workout(
            type: .cycling,
            title: "Easy Ride",
            durationMinutes: 60,
            intensity: .easy
        )

        // 60 minutes * 0.5 (easy multiplier) = 30
        #expect(workout.estimatedTSS == 30)
    }

    @Test("Estimated TSS uses provided TSS when available")
    func estimatedTSSUsesProvided() {
        let workout = Workout(
            type: .cycling,
            title: "Hard Ride",
            durationMinutes: 60,
            intensity: .hard,
            tss: 85
        )

        #expect(workout.estimatedTSS == 85)
    }

    @Test("Formatted duration for hours only")
    func formattedDurationHoursOnly() {
        let workout = Workout(
            type: .cycling,
            title: "Long Ride",
            durationMinutes: 120
        )

        #expect(workout.formattedDuration == "2h")
    }

    @Test("Formatted duration for hours and minutes")
    func formattedDurationHoursAndMinutes() {
        let workout = Workout(
            type: .cycling,
            title: "Medium Ride",
            durationMinutes: 90
        )

        #expect(workout.formattedDuration == "1h 30m")
    }

    @Test("Formatted duration for minutes only")
    func formattedDurationMinutesOnly() {
        let workout = Workout(
            type: .strength,
            title: "Quick Workout",
            durationMinutes: 45
        )

        #expect(workout.formattedDuration == "45m")
    }

    @Test("Workout with cycling metrics")
    func workoutWithCyclingMetrics() {
        let workout = Workout(
            type: .cycling,
            title: "TrainerRoad Workout",
            durationMinutes: 75,
            intensity: .hard,
            tss: 62,
            averagePower: 180,
            normalizedPower: 190,
            caloriesBurned: 650
        )

        #expect(workout.tss == 62)
        #expect(workout.averagePower == 180)
        #expect(workout.normalizedPower == 190)
        #expect(workout.caloriesBurned == 650)
        #expect(workout.estimatedTSS == 62)
    }

    @Test("Workout with external source tracking")
    func workoutWithExternalSource() {
        let workout = Workout(
            type: .cycling,
            title: "Zwift Ride",
            durationMinutes: 60,
            source: "Zwift",
            externalId: "zwift-123456"
        )

        #expect(workout.source == "Zwift")
        #expect(workout.externalId == "zwift-123456")
    }
}

@Suite("Mobility Log Tests")
struct MobilityLogTests {

    @Test("Mobility log initialization")
    func initialization() {
        let log = MobilityLog(
            durationMinutes: 12,
            exercisesCompleted: 10,
            totalExercises: 10
        )

        #expect(log.durationMinutes == 12)
        #expect(log.exercisesCompleted == 10)
        #expect(log.totalExercises == 10)
        #expect(log.routineName == "Bike-Mobility & Knee Health")
    }

    @Test("Mobility log date normalization")
    func dateNormalization() {
        let now = Date()
        let log = MobilityLog(
            date: now,
            durationMinutes: 12,
            exercisesCompleted: 10,
            totalExercises: 10
        )

        let expectedDate = Calendar.current.startOfDay(for: now)
        #expect(log.date == expectedDate)
    }

    @Test("Mobility log is complete when all exercises done")
    func isCompleteWhenAllExercisesDone() {
        let log = MobilityLog(
            durationMinutes: 12,
            exercisesCompleted: 10,
            totalExercises: 10
        )

        #expect(log.isComplete)
    }

    @Test("Mobility log is complete when more exercises than total")
    func isCompleteWhenExceedsTotal() {
        let log = MobilityLog(
            durationMinutes: 12,
            exercisesCompleted: 11,
            totalExercises: 10
        )

        #expect(log.isComplete)
    }

    @Test("Mobility log is not complete when exercises incomplete")
    func isNotCompleteWhenIncomplete() {
        let log = MobilityLog(
            durationMinutes: 8,
            exercisesCompleted: 7,
            totalExercises: 10
        )

        #expect(!log.isComplete)
    }
}

@Suite("Weekly Workout Summary Tests")
struct WeeklyWorkoutSummaryTests {

    @Test("Weekly summary initialization")
    func initialization() {
        let now = Date()
        let summary = WeeklyWorkoutSummary(
            weekStartDate: now,
            totalWorkouts: 5,
            totalDurationMinutes: 300,
            totalTSS: 250
        )

        #expect(summary.totalWorkouts == 5)
        #expect(summary.totalDurationMinutes == 300)
        #expect(summary.totalTSS == 250)
    }

    @Test("Formatted total duration for hours only")
    func formattedDurationHoursOnly() {
        let summary = WeeklyWorkoutSummary(
            weekStartDate: Date(),
            totalDurationMinutes: 180
        )

        #expect(summary.formattedTotalDuration == "3h")
    }

    @Test("Formatted total duration for hours and minutes")
    func formattedDurationHoursAndMinutes() {
        let summary = WeeklyWorkoutSummary(
            weekStartDate: Date(),
            totalDurationMinutes: 205
        )

        #expect(summary.formattedTotalDuration == "3h 25m")
    }

    @Test("Formatted total duration for minutes only")
    func formattedDurationMinutesOnly() {
        let summary = WeeklyWorkoutSummary(
            weekStartDate: Date(),
            totalDurationMinutes: 45
        )

        #expect(summary.formattedTotalDuration == "45m")
    }

    @Test("Weekly summary with workouts by type")
    func summaryWithWorkoutsByType() {
        let workoutsByType: [WorkoutType: Int] = [
            .cycling: 3,
            .running: 2,
            .strength: 1
        ]

        let summary = WeeklyWorkoutSummary(
            weekStartDate: Date(),
            totalWorkouts: 6,
            workoutsByType: workoutsByType,
            mobilitySessionsCompleted: 4
        )

        #expect(summary.workoutsByType[.cycling] == 3)
        #expect(summary.workoutsByType[.running] == 2)
        #expect(summary.workoutsByType[.strength] == 1)
        #expect(summary.mobilitySessionsCompleted == 4)
    }
}
