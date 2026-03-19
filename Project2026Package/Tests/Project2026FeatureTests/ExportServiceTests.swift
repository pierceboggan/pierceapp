import Foundation
import Testing
@testable import Project2026Feature

/// Validates markdown export generation for weekly and daily summaries.
@Suite("Export Service Tests")
struct ExportServiceTests {
    @Test("ChatGPT weekly summary includes goals, KPIs, books, and reflections")
    func chatGPTSummaryIncludesKeySections() {
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate

        let days = [
            DaySummary(
                date: startDate,
                habitsCompleted: 5,
                habitsTotal: 6,
                cleaningTasksCompleted: 2,
                cleaningTasksTotal: 2,
                waterOunces: 90,
                waterTarget: 100,
                pagesRead: 15,
                score: 82
            ),
            DaySummary(
                date: endDate,
                habitsCompleted: 6,
                habitsTotal: 6,
                cleaningTasksCompleted: 1,
                cleaningTasksTotal: 2,
                waterOunces: 100,
                waterTarget: 100,
                pagesRead: 0,
                score: 88
            )
        ]

        let weeklySummary = WeeklySummary(
            startDate: startDate,
            endDate: endDate,
            days: days
        )

        let goals: [Goal] = [
            Goal(title: "Be present", category: .presence, isHighLevel: true),
            Goal(
                title: "Reach 250 FTP",
                category: .fitness,
                isHighLevel: false,
                targetValue: 250,
                currentValue: 125,
                unit: "FTP"
            )
        ]

        let currentBooks = [
            Book(title: "Swift Testing", author: "A. Developer", totalPages: 200, currentPage: 100)
        ]

        let reflectionNotes = ["Focus on recovery and mobility", ""]

        let output = ExportService.generateChatGPTSummary(
            goals: goals,
            weeklySummary: weeklySummary,
            currentBooks: currentBooks,
            reflectionNotes: reflectionNotes
        )

        #expect(output.contains("# Project 2026 Weekly Review"))
        #expect(output.contains("Be present"), "High-level goals should appear")
        #expect(output.contains("Reach 250 FTP"), "KPIs should appear")
        #expect(output.contains("(50%)"), "KPI progress percentage should be included")
        #expect(output.contains("Days Tracked: 2/7"))
        #expect(output.contains("Days Read: 1/7"))
        #expect(output.contains("Swift Testing"), "Current book details should be listed")
        #expect(output.contains("Focus on recovery and mobility"), "Non-empty reflections should be appended")
        #expect(!output.contains("\n> \n"), "Empty reflection notes should be skipped")
    }

    @Test("Daily export formats habits, cleaning tasks, reading, and reflection")
    func dailyExportFormatting() {
        let date = Date(timeIntervalSince1970: 1_700_086_400) // Jan 2, 2024 approx

        let summary = DaySummary(
            date: date,
            habitsCompleted: 1,
            habitsTotal: 2,
            cleaningTasksCompleted: 1,
            cleaningTasksTotal: 2,
            waterOunces: 80,
            waterTarget: 100,
            pagesRead: 20,
            minutesRead: 25,
            score: 88,
            reflectionNote: "Keep momentum going"
        )

        let hydrationHabit = HabitTemplate(
            title: "Drink water",
            category: .health,
            inputType: .numeric,
            targetValue: 100,
            unit: "oz"
        )
        let hydrationLog = HabitLog(
            habitId: hydrationHabit.id,
            completed: true,
            numericValue: 80,
            durationMinutes: 30
        )

        let mobilityHabit = HabitTemplate(title: "Stretch", category: .fitness)

        let habits: [(HabitTemplate, HabitLog?)] = [
            (hydrationHabit, hydrationLog),
            (mobilityHabit, nil)
        ]

        let vacuumTask = CleaningTask(title: "Vacuum", recurrence: .daily)
        let dustTask = CleaningTask(title: "Dust", recurrence: .weekly)

        let cleaningTasks: [(CleaningTask, Bool)] = [
            (vacuumTask, true),
            (dustTask, false)
        ]

        let currentBook = Book(
            title: "Swift Adventures",
            author: "B. Author",
            totalPages: 200,
            currentPage: 100
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: habits,
            cleaningTasks: cleaningTasks,
            currentBook: currentBook
        )

        #expect(output.contains("# Daily Summary"))
        #expect(output.contains("Score: 88%"))
        #expect(output.contains("✓ Drink water - 80oz - 30 min"))
        #expect(output.contains("○ Stretch"), "Incomplete habits should show open circle")
        #expect(output.contains("## Cleaning (1/2)"))
        #expect(output.contains("✓ Vacuum"))
        #expect(output.contains("○ Dust"))
        #expect(output.contains("Pages Read: 20"))
        #expect(output.contains("Currently Reading: Swift Adventures (50%)"))
        #expect(output.contains("Keep momentum going"))
    }
}
