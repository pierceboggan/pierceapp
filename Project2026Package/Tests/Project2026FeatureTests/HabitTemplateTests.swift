//
//  HabitTemplateTests.swift
//  Project2026Tests
//
//  Tests for habit template logic
//

import XCTest
@testable import Project2026

final class HabitTemplateTests: XCTestCase {
    
    // MARK: - Core Habits Tests
    
    func testCoreHabitsExist() {
        let coreHabits = HabitTemplate.coreHabits
        
        XCTAssertGreaterThan(coreHabits.count, 0, "Should have core habits defined")
    }
    
    func testCoreHabitsAreMarkedAsCore() {
        let coreHabits = HabitTemplate.coreHabits
        
        for habit in coreHabits {
            XCTAssertTrue(habit.isCore, "Core habit '\(habit.title)' should be marked as core")
        }
    }
    
    func testCoreHabitsAreActive() {
        let coreHabits = HabitTemplate.coreHabits
        
        for habit in coreHabits {
            XCTAssertTrue(habit.isActive, "Core habit '\(habit.title)' should be active by default")
        }
    }
    
    // MARK: - Category Tests
    
    func testHabitCategoryIcons() {
        XCTAssertEqual(HabitCategory.life.icon, "heart.fill")
        XCTAssertEqual(HabitCategory.fitness.icon, "figure.run")
        XCTAssertEqual(HabitCategory.nutrition.icon, "fork.knife")
        XCTAssertEqual(HabitCategory.health.icon, "cross.fill")
        XCTAssertEqual(HabitCategory.work.icon, "briefcase.fill")
        XCTAssertEqual(HabitCategory.supplements.icon, "pills.fill")
        XCTAssertEqual(HabitCategory.custom.icon, "star.fill")
    }
    
    func testAllCategoriesHaveHabits() {
        let coreHabits = HabitTemplate.coreHabits
        let categories = Set(coreHabits.map { $0.category })
        
        // Core habits should span multiple categories
        XCTAssertGreaterThan(categories.count, 1, "Core habits should span multiple categories")
    }
    
    // MARK: - Input Type Tests
    
    func testInputTypeIcons() {
        XCTAssertEqual(HabitInputType.boolean.icon, "checkmark.circle")
        XCTAssertEqual(HabitInputType.numeric.icon, "number")
        XCTAssertEqual(HabitInputType.duration.icon, "clock")
    }
    
    // MARK: - Habit Creation Tests
    
    func testCreateCustomHabit() {
        let habit = HabitTemplate(
            title: "Custom Habit",
            category: .custom,
            frequency: .daily,
            inputType: .boolean,
            isCore: false,
            isActive: true
        )
        
        XCTAssertEqual(habit.title, "Custom Habit")
        XCTAssertEqual(habit.category, .custom)
        XCTAssertEqual(habit.frequency, .daily)
        XCTAssertFalse(habit.isCore)
        XCTAssertTrue(habit.isActive)
    }
    
    func testCreateNumericHabit() {
        let habit = HabitTemplate(
            title: "Steps",
            category: .fitness,
            frequency: .daily,
            inputType: .numeric,
            targetValue: 10000,
            unit: "steps",
            isCore: false,
            isActive: true
        )
        
        XCTAssertEqual(habit.inputType, .numeric)
        XCTAssertEqual(habit.targetValue, 10000)
        XCTAssertEqual(habit.unit, "steps")
    }
    
    func testCreateDurationHabit() {
        let habit = HabitTemplate(
            title: "Meditation",
            category: .health,
            frequency: .daily,
            inputType: .duration,
            targetValue: 15,
            unit: "min",
            isCore: false,
            isActive: true
        )
        
        XCTAssertEqual(habit.inputType, .duration)
        XCTAssertEqual(habit.targetValue, 15)
    }
}
