//
//  DaySummaryTests.swift
//  Project2026Tests
//
//  Tests for daily score calculation
//

import XCTest
@testable import Project2026

final class DaySummaryTests: XCTestCase {
    
    // MARK: - Score Calculation Tests
    
    func testPerfectScoreIs100() {
        let score = DaySummary.calculateScore(
            habitCompletion: 1.0,
            cleaningCompletion: 1.0,
            waterCompletion: 1.0,
            didRead: true
        )
        
        XCTAssertEqual(score, 100.0, accuracy: 0.1)
    }
    
    func testZeroScoreWhenNothingDone() {
        let score = DaySummary.calculateScore(
            habitCompletion: 0.0,
            cleaningCompletion: 0.0,
            waterCompletion: 0.0,
            didRead: false
        )
        
        XCTAssertEqual(score, 0.0, accuracy: 0.1)
    }
    
    func testHabitWeightIs50Percent() {
        // Only habits completed at 100%
        let score = DaySummary.calculateScore(
            habitCompletion: 1.0,
            cleaningCompletion: 0.0,
            waterCompletion: 0.0,
            didRead: false
        )
        
        XCTAssertEqual(score, 50.0, accuracy: 0.1, "Habits should contribute 50% of total score")
    }
    
    func testCleaningWeightIs20Percent() {
        // Only cleaning completed at 100%
        let score = DaySummary.calculateScore(
            habitCompletion: 0.0,
            cleaningCompletion: 1.0,
            waterCompletion: 0.0,
            didRead: false
        )
        
        XCTAssertEqual(score, 20.0, accuracy: 0.1, "Cleaning should contribute 20% of total score")
    }
    
    func testWaterWeightIs15Percent() {
        // Only water completed at 100%
        let score = DaySummary.calculateScore(
            habitCompletion: 0.0,
            cleaningCompletion: 0.0,
            waterCompletion: 1.0,
            didRead: false
        )
        
        XCTAssertEqual(score, 15.0, accuracy: 0.1, "Water should contribute 15% of total score")
    }
    
    func testReadingWeightIs15Percent() {
        // Only reading done
        let score = DaySummary.calculateScore(
            habitCompletion: 0.0,
            cleaningCompletion: 0.0,
            waterCompletion: 0.0,
            didRead: true
        )
        
        XCTAssertEqual(score, 15.0, accuracy: 0.1, "Reading should contribute 15% of total score")
    }
    
    func testPartialCompletionScore() {
        // 50% habits, 50% cleaning, 50% water, no reading
        let score = DaySummary.calculateScore(
            habitCompletion: 0.5,
            cleaningCompletion: 0.5,
            waterCompletion: 0.5,
            didRead: false
        )
        
        // Expected: 50% * 0.5 + 20% * 0.5 + 15% * 0.5 + 0 = 25 + 10 + 7.5 = 42.5
        XCTAssertEqual(score, 42.5, accuracy: 0.1)
    }
    
    // MARK: - Completion Rate Tests
    
    func testHabitCompletionRate() {
        let summary = DaySummary(
            habitsCompleted: 8,
            habitsTotal: 10
        )
        
        XCTAssertEqual(summary.habitCompletionRate, 0.8, accuracy: 0.01)
    }
    
    func testHabitCompletionRateZeroWhenNoHabits() {
        let summary = DaySummary(
            habitsCompleted: 0,
            habitsTotal: 0
        )
        
        XCTAssertEqual(summary.habitCompletionRate, 0.0)
    }
    
    func testCleaningCompletionRateDefaultsTo1WhenNoTasks() {
        let summary = DaySummary(
            cleaningTasksCompleted: 0,
            cleaningTasksTotal: 0
        )
        
        XCTAssertEqual(summary.cleaningCompletionRate, 1.0, "Should default to 100% when no cleaning tasks")
    }
    
    func testWaterCompletionRateCappedAt1() {
        let summary = DaySummary(
            waterOunces: 150,
            waterTarget: 100
        )
        
        XCTAssertEqual(summary.waterCompletionRate, 1.0, "Water completion should cap at 100%")
    }
    
    // MARK: - Weekly Summary Tests
    
    func testWeeklySummaryAverageScore() {
        let days = [
            DaySummary(score: 80),
            DaySummary(score: 90),
            DaySummary(score: 70)
        ]
        
        let weekly = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: days
        )
        
        XCTAssertEqual(weekly.averageScore, 80.0, accuracy: 0.1)
    }
    
    func testWeeklySummaryHabitCompliance() {
        let days = [
            DaySummary(habitsCompleted: 8, habitsTotal: 10),
            DaySummary(habitsCompleted: 9, habitsTotal: 10),
            DaySummary(habitsCompleted: 10, habitsTotal: 10)
        ]
        
        let weekly = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: days
        )
        
        // 27 completed out of 30 total = 90%
        XCTAssertEqual(weekly.habitComplianceRate, 0.9, accuracy: 0.01)
    }
    
    func testWeeklySummaryReadingDays() {
        let days = [
            DaySummary(pagesRead: 20),
            DaySummary(pagesRead: 0),
            DaySummary(pagesRead: 15),
            DaySummary(pagesRead: 30)
        ]
        
        let weekly = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: days
        )
        
        XCTAssertEqual(weekly.daysWithReading, 3)
        XCTAssertEqual(weekly.totalPagesRead, 65)
    }
}
