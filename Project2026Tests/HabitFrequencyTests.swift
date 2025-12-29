//
//  HabitFrequencyTests.swift
//  Project2026Tests
//
//  Tests for habit frequency logic
//

import XCTest
@testable import Project2026

final class HabitFrequencyTests: XCTestCase {
    
    // MARK: - Daily Frequency Tests
    
    func testDailyFrequencyIsActiveEveryDay() {
        let frequency = HabitFrequency.daily
        let calendar = Calendar.current
        
        // Test a full week
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: Date())!
            XCTAssertTrue(frequency.isActiveOn(date: date), "Daily frequency should be active on day \(dayOffset)")
        }
    }
    
    func testDailyDisplayText() {
        let frequency = HabitFrequency.daily
        XCTAssertEqual(frequency.displayText, "Daily")
    }
    
    // MARK: - Weekly Frequency Tests
    
    func testWeeklyFrequencyDisplayText() {
        let frequency3 = HabitFrequency.weekly(daysPerWeek: 3)
        XCTAssertEqual(frequency3.displayText, "3x/week")
        
        let frequency5 = HabitFrequency.weekly(daysPerWeek: 5)
        XCTAssertEqual(frequency5.displayText, "5x/week")
    }
    
    func testWeeklyFrequencyIsActiveEveryDay() {
        // Weekly frequency with a target is always "available" to be done
        let frequency = HabitFrequency.weekly(daysPerWeek: 3)
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: Date())!
            XCTAssertTrue(frequency.isActiveOn(date: date), "Weekly frequency should be active on day \(dayOffset)")
        }
    }
    
    // MARK: - Specific Days Frequency Tests
    
    func testSpecificDaysFrequency() {
        // Monday (2), Wednesday (4), Friday (6)
        let frequency = HabitFrequency.specificDays(days: [2, 4, 6])
        
        // Create a known Monday
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 5 // Monday, Jan 5, 2026
        let monday = Calendar.current.date(from: components)!
        
        XCTAssertTrue(frequency.isActiveOn(date: monday), "Should be active on Monday")
        
        // Tuesday
        let tuesday = Calendar.current.date(byAdding: .day, value: 1, to: monday)!
        XCTAssertFalse(frequency.isActiveOn(date: tuesday), "Should not be active on Tuesday")
        
        // Wednesday
        let wednesday = Calendar.current.date(byAdding: .day, value: 2, to: monday)!
        XCTAssertTrue(frequency.isActiveOn(date: wednesday), "Should be active on Wednesday")
    }
    
    func testSpecificDaysDisplayText() {
        let frequency = HabitFrequency.specificDays(days: [2, 4, 6])
        XCTAssertEqual(frequency.displayText, "Mon, Wed, Fri")
    }
}
