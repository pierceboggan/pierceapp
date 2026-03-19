import Testing
import Foundation
@testable import Project2026Feature

@Suite("Workout Metrics Tests")
struct WorkoutMetricsTests {

    @Test("Workout metrics has no metrics when all are nil")
    func hasNoMetricsWhenAllNil() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: nil,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(!metrics.hasMetrics)
    }

    @Test("Workout metrics has metrics when TSS is present")
    func hasMetricsWithTSS() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: nil,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.hasMetrics)
    }

    @Test("Workout metrics has metrics when IF is present")
    func hasMetricsWithIF() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: 0.75,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.hasMetrics)
    }

    @Test("Workout metrics has metrics when kilojoules is present")
    func hasMetricsWithKilojoules() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: nil,
            kilojoules: 500,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.hasMetrics)
    }

    @Test("Formatted TSS display")
    func formattedTSSDisplay() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: nil,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedTSS == "62 TSS")
    }

    @Test("Formatted TSS is nil when TSS not present")
    func formattedTSSNilWhenNotPresent() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: 0.75,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedTSS == nil)
    }

    @Test("Formatted IF display")
    func formattedIFDisplay() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: 0.753,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedIF == "IF 0.75")
    }

    @Test("Formatted IF is nil when IF not present")
    func formattedIFNilWhenNotPresent() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: nil,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedIF == nil)
    }

    @Test("Formatted energy display")
    func formattedEnergyDisplay() {
        let metrics = WorkoutMetrics(
            tss: nil,
            intensityFactor: nil,
            kilojoules: 432,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedEnergy == "432 kJ")
    }

    @Test("Formatted energy is nil when kilojoules not present")
    func formattedEnergyNilWhenNotPresent() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: 0.75,
            kilojoules: nil,
            description: nil,
            goals: nil,
            durationMinutes: nil,
            ftpRange: nil
        )

        #expect(metrics.formattedEnergy == nil)
    }
}

@Suite("Planned Workout Tests")
struct PlannedWorkoutTests {

    @Test("Planned workout formatted duration from metrics")
    func formattedDurationFromMetrics() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: 0.75,
            kilojoules: 432,
            description: "Test workout",
            goals: nil,
            durationMinutes: 75,
            ftpRange: nil
        )

        let workout = PlannedWorkout(
            id: "test",
            title: "Test Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: metrics
        )

        #expect(workout.formattedDuration == "1h 15m")
    }

    @Test("Planned workout formatted duration without metrics")
    func formattedDurationWithoutMetrics() {
        let workout = PlannedWorkout(
            id: "test",
            title: "Test Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(2700), // 45 minutes
            duration: 2700,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(workout.formattedDuration == "45 min")
    }

    @Test("Planned workout formatted duration hours only")
    func formattedDurationHoursOnly() {
        let metrics = WorkoutMetrics(
            tss: 80,
            intensityFactor: 0.85,
            kilojoules: 600,
            description: "Long ride",
            goals: nil,
            durationMinutes: 120,
            ftpRange: nil
        )

        let workout = PlannedWorkout(
            id: "test",
            title: "Long Ride",
            startDate: Date(),
            endDate: Date().addingTimeInterval(7200),
            duration: 7200,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: metrics
        )

        #expect(workout.formattedDuration == "2h")
    }

    @Test("Planned workout is today")
    func isToday() {
        let workout = PlannedWorkout(
            id: "test",
            title: "Today's Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(workout.isToday)
    }

    @Test("Planned workout is not today")
    func isNotToday() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let workout = PlannedWorkout(
            id: "test",
            title: "Tomorrow's Workout",
            startDate: tomorrow,
            endDate: tomorrow.addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(!workout.isToday)
    }

    @Test("Planned workout is past")
    func isPast() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let workout = PlannedWorkout(
            id: "test",
            title: "Past Workout",
            startDate: yesterday,
            endDate: yesterday.addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(workout.isPast)
    }

    @Test("Planned workout is not past")
    func isNotPast() {
        let future = Date().addingTimeInterval(3600)
        let workout = PlannedWorkout(
            id: "test",
            title: "Future Workout",
            startDate: future,
            endDate: future.addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(!workout.isPast)
    }

    @Test("Planned workout formatted time")
    func formattedTime() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 30
        let workoutTime = Calendar.current.date(from: components) ?? Date()

        let workout = PlannedWorkout(
            id: "test",
            title: "Morning Workout",
            startDate: workoutTime,
            endDate: workoutTime.addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        // Should contain time components
        #expect(workout.formattedTime.contains("9"))
        #expect(workout.formattedTime.contains("30"))
    }

    @Test("Planned workout short description from first sentence")
    func shortDescriptionFirstSentence() {
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: 0.75,
            kilojoules: 432,
            description: "This is the first sentence. This is the second sentence.",
            goals: nil,
            durationMinutes: 75,
            ftpRange: nil
        )

        let workout = PlannedWorkout(
            id: "test",
            title: "Test Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: metrics
        )

        #expect(workout.shortDescription == "This is the first sentence.")
    }

    @Test("Planned workout short description truncated")
    func shortDescriptionTruncated() {
        let longDescription = String(repeating: "a", count: 150)
        let metrics = WorkoutMetrics(
            tss: 62,
            intensityFactor: 0.75,
            kilojoules: 432,
            description: longDescription,
            goals: nil,
            durationMinutes: 75,
            ftpRange: nil
        )

        let workout = PlannedWorkout(
            id: "test",
            title: "Test Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: metrics
        )

        #expect(workout.shortDescription?.hasSuffix("...") == true)
        #expect((workout.shortDescription?.count ?? 0) <= 103)
    }

    @Test("Planned workout short description is nil without metrics")
    func shortDescriptionNilWithoutMetrics() {
        let workout = PlannedWorkout(
            id: "test",
            title: "Test Workout",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: nil,
            metrics: nil
        )

        #expect(workout.shortDescription == nil)
    }

    @Test("Planned workout with location")
    func workoutWithLocation() {
        let workout = PlannedWorkout(
            id: "test",
            title: "Group Ride",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            duration: 3600,
            calendarName: "Training",
            calendarColor: .blue,
            notes: nil,
            location: "Canyon Entrance",
            metrics: nil
        )

        #expect(workout.location == "Canyon Entrance")
    }
}

@Suite("Calendar Authorization Status Tests")
struct CalendarAuthorizationStatusTests {

    @Test("Authorization status enum cases exist")
    func enumCasesExist() {
        let statuses: [CalendarAuthorizationStatus] = [
            .notDetermined,
            .authorized,
            .denied,
            .restricted
        ]

        #expect(statuses.count == 4)
    }
}
