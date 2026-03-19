import Testing
import Foundation
@testable import Project2026Feature

@Suite("Export Service Tests")
struct ExportServiceTests {

    @Test("ChatGPT summary includes period dates")
    func chatGPTSummaryIncludesPeriodDates() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate

        let weeklySummary = WeeklySummary(
            startDate: startDate,
            endDate: endDate,
            days: []
        )

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("# Project 2026 Weekly Review"))
        #expect(output.contains("## Period"))
    }

    @Test("ChatGPT summary includes high-level goals")
    func chatGPTSummaryIncludesHighLevelGoals() {
        let goals = [
            Goal(title: "Be more present", category: .presence, isHighLevel: true),
            Goal(title: "Live healthy", category: .health, isHighLevel: true)
        ]

        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let output = ExportService.generateChatGPTSummary(
            goals: goals,
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("## High-Level Goals"))
        #expect(output.contains("Be more present"))
        #expect(output.contains("Live healthy"))
    }

    @Test("ChatGPT summary includes KPIs with progress")
    func chatGPTSummaryIncludesKPIs() {
        let kpis = [
            Goal(
                title: "Reach 250 FTP",
                category: .fitness,
                isHighLevel: false,
                targetValue: 250,
                currentValue: 200,
                unit: "FTP"
            )
        ]

        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let output = ExportService.generateChatGPTSummary(
            goals: kpis,
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("## KPIs"))
        #expect(output.contains("Reach 250 FTP"))
        #expect(output.contains("200/250 FTP"))
        #expect(output.contains("(80%)"))
    }

    @Test("ChatGPT summary includes weekly performance stats")
    func chatGPTSummaryIncludesWeeklyStats() {
        let day1 = DaySummary(
            habitsCompleted: 8,
            habitsTotal: 10,
            cleaningTasksCompleted: 3,
            cleaningTasksTotal: 5,
            waterOunces: 100,
            waterTarget: 100,
            pagesRead: 20,
            score: 85
        )

        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: [day1]
        )

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("## Weekly Performance"))
        #expect(output.contains("Average Daily Score"))
        #expect(output.contains("Habits Completed"))
        #expect(output.contains("Completion Rate"))
        #expect(output.contains("Daily Average"))
        #expect(output.contains("Days Read"))
    }

    @Test("ChatGPT summary includes currently reading books")
    func chatGPTSummaryIncludesCurrentBooks() {
        let book = Book(
            title: "Atomic Habits",
            author: "James Clear",
            totalPages: 320,
            currentPage: 160
        )

        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [book],
            reflectionNotes: []
        )

        #expect(output.contains("### Currently Reading"))
        #expect(output.contains("Atomic Habits"))
        #expect(output.contains("James Clear"))
        #expect(output.contains("50% complete"))
    }

    @Test("ChatGPT summary includes daily breakdown table")
    func chatGPTSummaryIncludesDailyTable() {
        let day1 = DaySummary(
            habitsCompleted: 8,
            habitsTotal: 10,
            cleaningTasksCompleted: 3,
            cleaningTasksTotal: 5,
            waterOunces: 90,
            waterTarget: 100,
            pagesRead: 15,
            score: 82
        )

        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: [day1]
        )

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("## Daily Breakdown"))
        #expect(output.contains("| Day | Score | Habits | Cleaning | Water | Read |"))
        #expect(output.contains("8/10"))
        #expect(output.contains("3/5"))
        #expect(output.contains("90oz"))
        #expect(output.contains("✓"))
    }

    @Test("ChatGPT summary includes reflection notes")
    func chatGPTSummaryIncludesReflections() {
        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let notes = [
            "Great progress this week",
            "Need to focus more on morning routine"
        ]

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: notes
        )

        #expect(output.contains("## Reflections"))
        #expect(output.contains("Great progress this week"))
        #expect(output.contains("Need to focus more on morning routine"))
    }

    @Test("ChatGPT summary filters out empty reflection notes")
    func chatGPTSummaryFiltersEmptyNotes() {
        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let notes = [
            "Valid note",
            "",
            "  ",
            "Another valid note"
        ]

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: notes
        )

        // Should only include valid notes
        #expect(output.contains("Valid note"))
        #expect(output.contains("Another valid note"))
    }

    @Test("ChatGPT summary includes questions for review")
    func chatGPTSummaryIncludesQuestions() {
        let weeklySummary = WeeklySummary(
            startDate: Date(),
            endDate: Date(),
            days: []
        )

        let output = ExportService.generateChatGPTSummary(
            goals: [],
            weeklySummary: weeklySummary,
            currentBooks: [],
            reflectionNotes: []
        )

        #expect(output.contains("## Questions for Review"))
        #expect(output.contains("What patterns do you notice"))
        #expect(output.contains("Which areas need the most attention"))
        #expect(output.contains("What adjustments would you suggest"))
        #expect(output.contains("Am I on track for my annual KPIs"))
    }

    @Test("Daily export includes summary and score")
    func dailyExportIncludesSummaryAndScore() {
        let summary = DaySummary(
            habitsCompleted: 7,
            habitsTotal: 10,
            cleaningTasksCompleted: 4,
            cleaningTasksTotal: 5,
            waterOunces: 95,
            waterTarget: 100,
            pagesRead: 25,
            score: 78.5
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [],
            currentBook: nil
        )

        #expect(output.contains("# Daily Summary"))
        #expect(output.contains("## Score: 78%") || output.contains("## Score: 79%"))
    }

    @Test("Daily export includes habit details")
    func dailyExportIncludesHabitDetails() {
        let summary = DaySummary()

        let habit = HabitTemplate(
            title: "Morning Meditation",
            frequency: .daily,
            category: .presence,
            unit: "min"
        )
        let log = HabitLog(
            templateId: habit.id,
            date: Date(),
            completed: true,
            durationMinutes: 10
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [(habit, log)],
            cleaningTasks: [],
            currentBook: nil
        )

        #expect(output.contains("## Habits"))
        #expect(output.contains("Morning Meditation"))
        #expect(output.contains("✓"))
        #expect(output.contains("10 min"))
    }

    @Test("Daily export includes cleaning tasks")
    func dailyExportIncludesCleaningTasks() {
        let summary = DaySummary()

        let task = CleaningTask(
            title: "Kitchen",
            recurrence: .daily
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [(task, true)],
            currentBook: nil
        )

        #expect(output.contains("## Cleaning"))
        #expect(output.contains("Kitchen"))
        #expect(output.contains("✓"))
    }

    @Test("Daily export includes water tracking")
    func dailyExportIncludesWaterTracking() {
        let summary = DaySummary(
            waterOunces: 85,
            waterTarget: 100
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [],
            currentBook: nil
        )

        #expect(output.contains("## Water: 85/100oz"))
    }

    @Test("Daily export includes reading stats")
    func dailyExportIncludesReadingStats() {
        let summary = DaySummary(
            pagesRead: 30
        )

        let book = Book(
            title: "Deep Work",
            author: "Cal Newport",
            totalPages: 300,
            currentPage: 150
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [],
            currentBook: book
        )

        #expect(output.contains("## Reading"))
        #expect(output.contains("Pages Read: 30"))
        #expect(output.contains("Currently Reading: Deep Work"))
        #expect(output.contains("50%"))
    }

    @Test("Daily export includes reflection note")
    func dailyExportIncludesReflection() {
        let summary = DaySummary(
            reflectionNote: "Productive day with good focus"
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [],
            currentBook: nil
        )

        #expect(output.contains("## Reflection"))
        #expect(output.contains("Productive day with good focus"))
    }

    @Test("Daily export handles empty reflection note")
    func dailyExportHandlesEmptyReflection() {
        let summary = DaySummary(
            reflectionNote: ""
        )

        let output = ExportService.generateDailyExport(
            summary: summary,
            habits: [],
            cleaningTasks: [],
            currentBook: nil
        )

        // Should not include reflection section for empty notes
        #expect(!output.contains("## Reflection\n\n"))
    }
}
