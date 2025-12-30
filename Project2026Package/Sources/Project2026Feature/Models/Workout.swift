//
//  Workout.swift
//  Project2026
//
//  Workout tracking models
//

import Foundation

// MARK: - Workout Type

/// Categories of workouts for organization and filtering.
public enum WorkoutType: String, Codable, CaseIterable, Sendable {
    case cycling = "Cycling"
    case running = "Running"
    case strength = "Strength"
    case yoga = "Yoga"
    case swimming = "Swimming"
    case hiking = "Hiking"
    case skiing = "Skiing"
    case other = "Other"
    
    public var icon: String {
        switch self {
        case .cycling: return "bicycle"
        case .running: return "figure.run"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .skiing: return "figure.skiing.downhill"
        case .other: return "figure.mixed.cardio"
        }
    }
    
    public var color: String {
        switch self {
        case .cycling: return "blue"
        case .running: return "green"
        case .strength: return "orange"
        case .yoga: return "purple"
        case .swimming: return "cyan"
        case .hiking: return "brown"
        case .skiing: return "mint"
        case .other: return "gray"
        }
    }
}

// MARK: - Workout Intensity

/// Perceived effort level for a workout.
public enum WorkoutIntensity: String, Codable, CaseIterable, Sendable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    case veryHard = "Very Hard"
    
    public var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .moderate: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        case .veryHard: return "4.circle.fill"
        }
    }
    
    public var tssMultiplier: Double {
        switch self {
        case .easy: return 0.5
        case .moderate: return 0.7
        case .hard: return 0.9
        case .veryHard: return 1.1
        }
    }
}

// MARK: - Workout

/// Represents a single workout session with type, duration, and optional metrics.
/// Supports cycling-specific metrics like TSS and power for TrainerRoad compatibility.
public struct Workout: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public var type: WorkoutType
    public var title: String
    public var date: Date
    public var durationMinutes: Int
    public var intensity: WorkoutIntensity
    public var notes: String?
    
    // Cycling-specific metrics (for TrainerRoad integration)
    public var tss: Int?
    public var averagePower: Int?
    public var normalizedPower: Int?
    public var caloriesBurned: Int?
    
    // External source tracking
    public var source: String?
    public var externalId: String?
    
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        type: WorkoutType,
        title: String,
        date: Date = Date(),
        durationMinutes: Int,
        intensity: WorkoutIntensity = .moderate,
        notes: String? = nil,
        tss: Int? = nil,
        averagePower: Int? = nil,
        normalizedPower: Int? = nil,
        caloriesBurned: Int? = nil,
        source: String? = nil,
        externalId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.date = Calendar.current.startOfDay(for: date)
        self.durationMinutes = durationMinutes
        self.intensity = intensity
        self.notes = notes
        self.tss = tss
        self.averagePower = averagePower
        self.normalizedPower = normalizedPower
        self.caloriesBurned = caloriesBurned
        self.source = source
        self.externalId = externalId
        self.createdAt = createdAt
    }
    
    /// Estimated TSS based on duration and intensity if not provided.
    public var estimatedTSS: Int {
        if let tss = tss { return tss }
        // Rough estimate: TSS ≈ duration * intensity factor
        return Int(Double(durationMinutes) * intensity.tssMultiplier)
    }
    
    /// Formatted duration string (e.g., "1h 30m")
    public var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Mobility Log

/// Records completion of a mobility routine session.
public struct MobilityLog: Codable, Identifiable, Sendable {
    public let id: UUID
    public var date: Date
    public var routineName: String
    public var durationMinutes: Int
    public var exercisesCompleted: Int
    public var totalExercises: Int
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        routineName: String = "Bike-Mobility & Knee Health",
        durationMinutes: Int,
        exercisesCompleted: Int,
        totalExercises: Int,
        notes: String? = nil
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.routineName = routineName
        self.durationMinutes = durationMinutes
        self.exercisesCompleted = exercisesCompleted
        self.totalExercises = totalExercises
        self.notes = notes
    }
    
    public var isComplete: Bool {
        exercisesCompleted >= totalExercises
    }
}

// MARK: - Weekly Workout Summary

/// Aggregated workout statistics for a week.
public struct WeeklyWorkoutSummary: Sendable {
    public let weekStartDate: Date
    public var totalWorkouts: Int
    public var totalDurationMinutes: Int
    public var totalTSS: Int
    public var workoutsByType: [WorkoutType: Int]
    public var mobilitySessionsCompleted: Int
    
    public init(
        weekStartDate: Date,
        totalWorkouts: Int = 0,
        totalDurationMinutes: Int = 0,
        totalTSS: Int = 0,
        workoutsByType: [WorkoutType: Int] = [:],
        mobilitySessionsCompleted: Int = 0
    ) {
        self.weekStartDate = weekStartDate
        self.totalWorkouts = totalWorkouts
        self.totalDurationMinutes = totalDurationMinutes
        self.totalTSS = totalTSS
        self.workoutsByType = workoutsByType
        self.mobilitySessionsCompleted = mobilitySessionsCompleted
    }
    
    public var formattedTotalDuration: String {
        let hours = totalDurationMinutes / 60
        let minutes = totalDurationMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
