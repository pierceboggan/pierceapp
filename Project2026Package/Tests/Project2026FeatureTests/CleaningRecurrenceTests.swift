//
//  CleaningRecurrenceTests.swift
//  Project2026Tests
//
//  Tests for cleaning task recurrence logic
//

import XCTest
@testable import Project2026

final class CleaningRecurrenceTests: XCTestCase {
    
    // MARK: - Due Date Calculation Tests
    
    func testDailyRecurrenceDueDate() {
        let recurrence = CleaningRecurrence.daily
        let lastCompleted = Date()
        
        let dueDate = recurrence.nextDueDate(from: lastCompleted)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .day, value: 1, to: lastCompleted)!
        
        XCTAssertEqual(
            calendar.startOfDay(for: dueDate),
            calendar.startOfDay(for: expectedDate)
        )
    }
    
    func testWeeklyRecurrenceDueDate() {
        let recurrence = CleaningRecurrence.weekly
        let lastCompleted = Date()
        
        let dueDate = recurrence.nextDueDate(from: lastCompleted)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .day, value: 7, to: lastCompleted)!
        
        XCTAssertEqual(
            calendar.startOfDay(for: dueDate),
            calendar.startOfDay(for: expectedDate)
        )
    }
    
    func testBiweeklyRecurrenceDueDate() {
        let recurrence = CleaningRecurrence.biweekly
        let lastCompleted = Date()
        
        let dueDate = recurrence.nextDueDate(from: lastCompleted)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .day, value: 14, to: lastCompleted)!
        
        XCTAssertEqual(
            calendar.startOfDay(for: dueDate),
            calendar.startOfDay(for: expectedDate)
        )
    }
    
    func testMonthlyRecurrenceDueDate() {
        let recurrence = CleaningRecurrence.monthly
        let lastCompleted = Date()
        
        let dueDate = recurrence.nextDueDate(from: lastCompleted)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .month, value: 1, to: lastCompleted)!
        
        XCTAssertEqual(
            calendar.startOfDay(for: dueDate),
            calendar.startOfDay(for: expectedDate)
        )
    }
    
    func testCustomRecurrenceDueDate() {
        let recurrence = CleaningRecurrence.custom(days: 10)
        let lastCompleted = Date()
        
        let dueDate = recurrence.nextDueDate(from: lastCompleted)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .day, value: 10, to: lastCompleted)!
        
        XCTAssertEqual(
            calendar.startOfDay(for: dueDate),
            calendar.startOfDay(for: expectedDate)
        )
    }
    
    // MARK: - Display Text Tests
    
    func testRecurrenceDisplayText() {
        XCTAssertEqual(CleaningRecurrence.daily.displayText, "Daily")
        XCTAssertEqual(CleaningRecurrence.weekly.displayText, "Weekly")
        XCTAssertEqual(CleaningRecurrence.biweekly.displayText, "Every 2 weeks")
        XCTAssertEqual(CleaningRecurrence.monthly.displayText, "Monthly")
        XCTAssertEqual(CleaningRecurrence.custom(days: 10).displayText, "Every 10 days")
    }
    
    // MARK: - Cleaning Task Tests
    
    func testCleaningTaskOverdueWhenPastDue() {
        var task = CleaningTask(
            title: "Test Task",
            recurrence: .weekly
        )
        
        // Set last completed to 10 days ago
        let calendar = Calendar.current
        task.lastCompletedDate = calendar.date(byAdding: .day, value: -10, to: Date())
        
        XCTAssertTrue(task.isOverdue, "Task should be overdue when due date is in the past")
    }
    
    func testCleaningTaskNotOverdueWhenRecentlyCompleted() {
        var task = CleaningTask(
            title: "Test Task",
            recurrence: .weekly
        )
        
        // Set last completed to 2 days ago
        let calendar = Calendar.current
        task.lastCompletedDate = calendar.date(byAdding: .day, value: -2, to: Date())
        
        XCTAssertFalse(task.isOverdue, "Task should not be overdue when recently completed")
    }
    
    func testCleaningTaskDueTodayWhenOnDueDate() {
        var task = CleaningTask(
            title: "Test Task",
            recurrence: .weekly
        )
        
        // Set last completed to exactly 7 days ago
        let calendar = Calendar.current
        task.lastCompletedDate = calendar.date(byAdding: .day, value: -7, to: Date())
        
        XCTAssertTrue(task.isDueToday, "Task should be due today")
    }
    
    func testCleaningTaskSnoozed() {
        var task = CleaningTask(
            title: "Test Task",
            recurrence: .daily
        )
        
        // Set last completed to yesterday (making it overdue)
        let calendar = Calendar.current
        task.lastCompletedDate = calendar.date(byAdding: .day, value: -2, to: Date())
        
        // Snooze until tomorrow
        task.snoozedUntil = calendar.date(byAdding: .day, value: 1, to: Date())
        
        XCTAssertTrue(task.isSnoozed, "Task should be snoozed")
        XCTAssertFalse(task.isDueToday, "Snoozed task should not be due today")
    }
}
