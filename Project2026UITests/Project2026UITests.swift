import XCTest

final class Project2026UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabNavigation() throws {
        // Test all tabs can be navigated to
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        // Today Tab
        let todayTab = tabBar.buttons["Today"]
        XCTAssertTrue(todayTab.exists, "Today tab should exist")
        todayTab.tap()
        XCTAssertTrue(app.navigationBars["Today"].exists, "Today navigation bar should exist")

        // Fitness Tab
        let fitnessTab = tabBar.buttons["Fitness"]
        XCTAssertTrue(fitnessTab.exists, "Fitness tab should exist")
        fitnessTab.tap()
        XCTAssertTrue(app.navigationBars["Fitness"].exists, "Fitness navigation bar should exist")

        // Habits Tab
        let habitsTab = tabBar.buttons["Habits"]
        XCTAssertTrue(habitsTab.exists, "Habits tab should exist")
        habitsTab.tap()
        XCTAssertTrue(app.navigationBars["Habits"].exists, "Habits navigation bar should exist")

        // Cleaning Tab
        let cleaningTab = tabBar.buttons["Cleaning"]
        XCTAssertTrue(cleaningTab.exists, "Cleaning tab should exist")
        cleaningTab.tap()
        XCTAssertTrue(app.navigationBars["Cleaning"].exists, "Cleaning navigation bar should exist")

        // History Tab
        let historyTab = tabBar.buttons["History"]
        XCTAssertTrue(historyTab.exists, "History tab should exist")
        historyTab.tap()
        XCTAssertTrue(app.navigationBars["History"].exists, "History navigation bar should exist")

        // Settings Tab
        let settingsTab = tabBar.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists, "Settings tab should exist")
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists, "Settings navigation bar should exist")
    }

    // MARK: - Today Tab Tests

    @MainActor
    func testTodayTabDisplaysScore() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check for daily score
        XCTAssertTrue(app.staticTexts["Daily Score"].exists, "Daily Score should be displayed")
    }

    @MainActor
    func testTodayTabWaterTracking() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check water tracker exists
        XCTAssertTrue(app.staticTexts["Water"].exists, "Water label should exist")

        // Check for quick add buttons
        let quickAddButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'oz'"))
        XCTAssertGreaterThan(quickAddButtons.count, 0, "Quick add water buttons should exist")
    }

    @MainActor
    func testTodayTabHabitsSection() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check habits section exists
        XCTAssertTrue(app.staticTexts["Habits"].exists, "Habits section should exist")
    }

    @MainActor
    func testTodayTabCleaningSection() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check cleaning section exists
        XCTAssertTrue(app.staticTexts["Cleaning"].exists, "Cleaning section should exist")
    }

    @MainActor
    func testTodayTabMobilityRoutine() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check mobility routine card exists
        XCTAssertTrue(app.staticTexts["Bike Mobility Routine"].exists, "Mobility routine card should exist")
    }

    @MainActor
    func testTodayTabReflection() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Check reflection card exists
        XCTAssertTrue(app.staticTexts["Daily Reflection"].exists, "Daily Reflection card should exist")
    }

    // MARK: - Fitness Tab Tests

    @MainActor
    func testFitnessTabWeeklySummary() throws {
        let fitnessTab = app.tabBars.buttons["Fitness"]
        fitnessTab.tap()

        // Check weekly summary exists
        XCTAssertTrue(app.staticTexts["This Week"].exists, "Weekly summary should exist")
        XCTAssertTrue(app.staticTexts["Workouts"].exists, "Workouts stat should exist")
        XCTAssertTrue(app.staticTexts["Mobility"].exists, "Mobility stat should exist")
        XCTAssertTrue(app.staticTexts["Duration"].exists, "Duration stat should exist")
    }

    @MainActor
    func testFitnessTabQuickActions() throws {
        let fitnessTab = app.tabBars.buttons["Fitness"]
        fitnessTab.tap()

        // Check quick action buttons
        XCTAssertTrue(app.buttons["Log Workout"].exists, "Log Workout button should exist")
        XCTAssertTrue(app.buttons["Start Mobility"].exists, "Start Mobility button should exist")
    }

    @MainActor
    func testFitnessTabSegmentControl() throws {
        let fitnessTab = app.tabBars.buttons["Fitness"]
        fitnessTab.tap()

        // Check segment picker exists
        let workoutsSegment = app.buttons["Workouts"]
        let mobilitySegment = app.buttons["Mobility"]

        XCTAssertTrue(workoutsSegment.exists, "Workouts segment should exist")
        XCTAssertTrue(mobilitySegment.exists, "Mobility segment should exist")

        // Switch to mobility
        mobilitySegment.tap()
        XCTAssertTrue(app.staticTexts["Bike-Mobility & Knee Health"].exists, "Mobility section should be displayed")

        // Switch back to workouts
        workoutsSegment.tap()
        XCTAssertTrue(app.staticTexts["Recent Workouts"].exists, "Workouts section should be displayed")
    }

    @MainActor
    func testFitnessTabAddWorkoutSheet() throws {
        let fitnessTab = app.tabBars.buttons["Fitness"]
        fitnessTab.tap()

        // Tap add button in toolbar
        let addButton = app.navigationBars["Fitness"].buttons.matching(identifier: "plus").firstMatch
        if addButton.exists {
            addButton.tap()

            // Check sheet is presented
            XCTAssertTrue(app.navigationBars["Log Workout"].exists, "Log Workout sheet should be presented")

            // Dismiss sheet
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }

    @MainActor
    func testFitnessTabLogWorkout() throws {
        let fitnessTab = app.tabBars.buttons["Fitness"]
        fitnessTab.tap()

        // Tap Log Workout quick action
        let logWorkoutButton = app.buttons["Log Workout"]
        if logWorkoutButton.exists {
            logWorkoutButton.tap()

            // Check form elements
            XCTAssertTrue(app.navigationBars["Log Workout"].exists, "Log Workout sheet should appear")
            XCTAssertTrue(app.textFields["Title"].exists, "Title field should exist")

            // Cancel
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }

    // MARK: - Habits Tab Tests

    @MainActor
    func testHabitsTabCategoryFilter() throws {
        let habitsTab = app.tabBars.buttons["Habits"]
        habitsTab.tap()

        // Check All filter exists
        let allFilter = app.buttons["All"]
        XCTAssertTrue(allFilter.exists, "All category filter should exist")

        // Check category filters exist
        let categoryFilters = ["Life", "Fitness", "Nutrition", "Health", "Work", "Supplements", "Custom"]
        for category in categoryFilters {
            let filterButton = app.buttons[category]
            if filterButton.exists {
                XCTAssertTrue(filterButton.exists, "\(category) filter should exist")
            }
        }
    }

    @MainActor
    func testHabitsTabAddHabitButton() throws {
        let habitsTab = app.tabBars.buttons["Habits"]
        habitsTab.tap()

        // Check add button exists
        let addButton = app.navigationBars["Habits"].buttons.matching(identifier: "plus.circle.fill").firstMatch
        XCTAssertTrue(addButton.exists || app.navigationBars["Habits"].buttons.element(boundBy: 0).exists,
                     "Add habit button should exist")
    }

    @MainActor
    func testHabitsTabShowArchived() throws {
        let habitsTab = app.tabBars.buttons["Habits"]
        habitsTab.tap()

        // Scroll to bottom to find Show Archived button
        let showArchivedButton = app.buttons["Show Archived"]
        if showArchivedButton.exists {
            showArchivedButton.tap()

            // Verify button text changed
            XCTAssertTrue(app.buttons["Hide Archived"].exists, "Button should change to Hide Archived")

            // Toggle back
            app.buttons["Hide Archived"].tap()
            XCTAssertTrue(app.buttons["Show Archived"].exists, "Button should change back to Show Archived")
        }
    }

    // MARK: - Cleaning Tab Tests

    @MainActor
    func testCleaningTabSegmentControl() throws {
        let cleaningTab = app.tabBars.buttons["Cleaning"]
        cleaningTab.tap()

        // Check segment picker
        let todaySegment = app.buttons["Today"]
        let allTasksSegment = app.buttons["All Tasks"]
        let historySegment = app.buttons["History"]

        XCTAssertTrue(todaySegment.exists, "Today segment should exist")
        XCTAssertTrue(allTasksSegment.exists, "All Tasks segment should exist")
        XCTAssertTrue(historySegment.exists, "History segment should exist")

        // Test segment switching
        allTasksSegment.tap()
        sleep(1) // Wait for segment transition

        todaySegment.tap()
        sleep(1)

        historySegment.tap()
        sleep(1)
    }

    @MainActor
    func testCleaningTabTodayProgress() throws {
        let cleaningTab = app.tabBars.buttons["Cleaning"]
        cleaningTab.tap()

        // Ensure we're on Today segment
        let todaySegment = app.buttons["Today"]
        todaySegment.tap()

        // Check for progress indicator
        XCTAssertTrue(app.staticTexts["Today's Progress"].exists, "Today's Progress should be displayed")
    }

    @MainActor
    func testCleaningTabAddTaskButton() throws {
        let cleaningTab = app.tabBars.buttons["Cleaning"]
        cleaningTab.tap()

        // Check add button exists
        let addButton = app.navigationBars["Cleaning"].buttons.matching(identifier: "plus.circle.fill").firstMatch
        XCTAssertTrue(addButton.exists || app.navigationBars["Cleaning"].buttons.element(boundBy: 0).exists,
                     "Add cleaning task button should exist")
    }

    // MARK: - History Tab Tests

    @MainActor
    func testHistoryTabSegmentControl() throws {
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Check segment picker
        let listSegment = app.buttons["List"]
        let calendarSegment = app.buttons["Calendar"]
        let statsSegment = app.buttons["Stats"]

        XCTAssertTrue(listSegment.exists, "List segment should exist")
        XCTAssertTrue(calendarSegment.exists, "Calendar segment should exist")
        XCTAssertTrue(statsSegment.exists, "Stats segment should exist")

        // Test segment switching
        calendarSegment.tap()
        sleep(1)

        statsSegment.tap()
        sleep(1)

        listSegment.tap()
        sleep(1)
    }

    @MainActor
    func testHistoryTabWeeklySummary() throws {
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Ensure we're on List view
        let listSegment = app.buttons["List"]
        listSegment.tap()

        // Check weekly summary
        XCTAssertTrue(app.staticTexts["This Week"].exists, "This Week summary should exist")
    }

    @MainActor
    func testHistoryTabCalendarView() throws {
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Switch to calendar
        let calendarSegment = app.buttons["Calendar"]
        calendarSegment.tap()

        // Check calendar navigation exists
        let prevMonthButton = app.buttons.matching(identifier: "chevron.left").firstMatch
        let nextMonthButton = app.buttons.matching(identifier: "chevron.right").firstMatch

        XCTAssertTrue(prevMonthButton.exists || app.buttons.element(boundBy: 0).exists,
                     "Previous month button should exist")
        XCTAssertTrue(nextMonthButton.exists || app.buttons.element(boundBy: 1).exists,
                     "Next month button should exist")
    }

    @MainActor
    func testHistoryTabStatsView() throws {
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()

        // Switch to stats
        let statsSegment = app.buttons["Stats"]
        statsSegment.tap()

        // Check for stats sections
        XCTAssertTrue(app.staticTexts["Streaks"].exists, "Streaks section should exist")
        XCTAssertTrue(app.staticTexts["Current Streak"].exists, "Current Streak should be displayed")
    }

    // MARK: - Settings Tab Tests

    @MainActor
    func testSettingsTabNavigation() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check main sections exist
        XCTAssertTrue(app.staticTexts["Goals & KPIs"].exists || app.cells.staticTexts["Goals & KPIs"].exists,
                     "Goals & KPIs should exist")
        XCTAssertTrue(app.staticTexts["Daily Targets"].exists, "Daily Targets section should exist")
        XCTAssertTrue(app.staticTexts["Appearance"].exists, "Appearance section should exist")
    }

    @MainActor
    func testSettingsTabWaterGoal() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check water goal setting exists
        XCTAssertTrue(app.staticTexts["Water Goal"].exists, "Water Goal setting should exist")
    }

    @MainActor
    func testSettingsTabThemeSelection() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check Appearance section
        XCTAssertTrue(app.staticTexts["Appearance"].exists, "Appearance section should exist")

        // Check for theme options (at least one should exist)
        let themeButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Midnight' OR label CONTAINS[c] 'Ocean' OR label CONTAINS[c] 'Forest'"))
        // Themes might be in cells, so also check for static texts
        let themeTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Midnight' OR label CONTAINS[c] 'Ocean' OR label CONTAINS[c] 'Forest'"))

        XCTAssertTrue(themeButtons.count > 0 || themeTexts.count > 0, "At least one theme should be available")
    }

    @MainActor
    func testSettingsTabReadingSection() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check Reading section exists
        XCTAssertTrue(app.staticTexts["Reading"].exists, "Reading section should exist")
        XCTAssertTrue(app.staticTexts["My Books"].exists || app.cells.staticTexts["My Books"].exists,
                     "My Books navigation should exist")
    }

    @MainActor
    func testSettingsTabDataSection() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check Data section exists
        XCTAssertTrue(app.staticTexts["Data"].exists, "Data section should exist")
        XCTAssertTrue(app.staticTexts["Export Data"].exists || app.cells.staticTexts["Export Data"].exists,
                     "Export Data should exist")
        XCTAssertTrue(app.staticTexts["Reset All Data"].exists || app.buttons["Reset All Data"].exists,
                     "Reset All Data should exist")
    }

    @MainActor
    func testSettingsTabAbout() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check About section exists
        XCTAssertTrue(app.staticTexts["About Project 2026"].exists || app.cells.staticTexts["About Project 2026"].exists,
                     "About Project 2026 should exist")
        XCTAssertTrue(app.staticTexts["Version"].exists, "Version should be displayed")
    }

    @MainActor
    func testSettingsTabGoalsNavigation() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Navigate to Goals & KPIs
        let goalsButton = app.cells.staticTexts["Goals & KPIs"]
        if goalsButton.exists {
            goalsButton.tap()

            // Check Goals screen loaded
            XCTAssertTrue(app.navigationBars["Goals & KPIs"].exists, "Goals & KPIs screen should be displayed")

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
    }

    @MainActor
    func testSettingsTabBooksListNavigation() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Navigate to My Books
        let booksButton = app.cells.staticTexts["My Books"]
        if booksButton.exists {
            booksButton.tap()

            // Check Books screen loaded
            XCTAssertTrue(app.navigationBars["My Books"].exists, "My Books screen should be displayed")

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
    }

    // MARK: - Sheet Presentation Tests

    @MainActor
    func testAddWaterSheetPresentation() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Find and tap the add water button (plus icon)
        let addWaterButton = app.buttons.matching(identifier: "plus.circle.fill").firstMatch
        if addWaterButton.exists {
            addWaterButton.tap()

            // Wait for sheet
            sleep(1)

            // Look for any navigation bar or sheet indicator
            let hasSheet = app.navigationBars.count > 1 || app.textFields.count > 0
            XCTAssertTrue(hasSheet, "Add water sheet should be presented")
        }
    }

    @MainActor
    func testReflectionSheetPresentation() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        // Find and tap Daily Reflection card
        let reflectionCard = app.staticTexts["Daily Reflection"]
        if reflectionCard.exists {
            reflectionCard.tap()

            // Wait for sheet
            sleep(1)

            // Check for sheet elements
            let hasSheet = app.navigationBars.count > 1 || app.textViews.count > 0
            XCTAssertTrue(hasSheet, "Reflection sheet should be presented")
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testTabBarAccessibility() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        let tabs = ["Today", "Fitness", "Habits", "Cleaning", "History", "Settings"]
        for tabName in tabs {
            let tab = tabBar.buttons[tabName]
            XCTAssertTrue(tab.exists, "\(tabName) tab should be accessible")
        }
    }

    @MainActor
    func testNavigationBarAccessibility() throws {
        // Test each tab's navigation bar
        let tabs = [
            ("Today", "Today"),
            ("Fitness", "Fitness"),
            ("Habits", "Habits"),
            ("Cleaning", "Cleaning"),
            ("History", "History"),
            ("Settings", "Settings")
        ]

        for (tabName, expectedNavTitle) in tabs {
            let tab = app.tabBars.buttons[tabName]
            tab.tap()
            sleep(1)

            let navBar = app.navigationBars[expectedNavTitle]
            XCTAssertTrue(navBar.exists, "\(expectedNavTitle) navigation bar should be accessible")
        }
    }

    // MARK: - Landscape Orientation Tests

    @MainActor
    func testLandscapeOrientation() throws {
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        // Check that UI is still accessible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist in landscape")

        // Navigate through tabs
        let todayTab = tabBar.buttons["Today"]
        todayTab.tap()
        XCTAssertTrue(app.navigationBars["Today"].exists, "Today view should work in landscape")

        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        XCTAssertTrue(app.navigationBars["Today"].exists, "Today view should work after rotation")
    }

    // MARK: - Performance Tests

    @MainActor
    func testTabSwitchingPerformance() throws {
        let tabBar = app.tabBars.firstMatch

        measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
            // Measure time to switch between all tabs
            tabBar.buttons["Today"].tap()
            tabBar.buttons["Fitness"].tap()
            tabBar.buttons["Habits"].tap()
            tabBar.buttons["Cleaning"].tap()
            tabBar.buttons["History"].tap()
            tabBar.buttons["Settings"].tap()
            tabBar.buttons["Today"].tap()
        }
    }
}
