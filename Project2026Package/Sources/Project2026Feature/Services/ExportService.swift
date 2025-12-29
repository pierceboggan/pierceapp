//
//  ExportService.swift
//  Project2026
//
//  Service for exporting data for ChatGPT review
//

import Foundation

/// Generates formatted markdown exports for weekly and daily reviews.
/// Designed for pasting into ChatGPT to get AI-powered analysis and suggestions.
/// Includes goals, habit compliance, water/reading stats, and reflection notes.
public class ExportService {
    
    // MARK: - ChatGPT Export
    
    static func generateChatGPTSummary(
        goals: [Goal],
        weeklySummary: WeeklySummary,
        currentBooks: [Book],
        reflectionNotes: [String]
    ) -> String {
        var output = """
        # Project 2026 Weekly Review
        
        ## Period
        \(formatDate(weeklySummary.startDate)) - \(formatDate(weeklySummary.endDate))
        
        ---
        
        ## High-Level Goals
        """
        
        // Goals
        let highLevelGoals = goals.filter { $0.isHighLevel }
        for goal in highLevelGoals {
            output += "\n- \(goal.title)"
        }
        
        output += "\n\n## KPIs\n"
        let kpis = goals.filter { !$0.isHighLevel }
        for kpi in kpis {
            var line = "- \(kpi.title)"
            if let current = kpi.currentValue, let target = kpi.targetValue, let unit = kpi.unit {
                let progress = Int((current / target) * 100)
                line += ": \(Int(current))/\(Int(target)) \(unit) (\(progress)%)"
            }
            output += line + "\n"
        }
        
        // Weekly Stats
        output += """
        
        ---
        
        ## Weekly Performance
        
        ### Overall
        - **Average Daily Score:** \(String(format: "%.1f", weeklySummary.averageScore))%
        - **Days Tracked:** \(weeklySummary.days.count)/7
        
        ### Habits
        - **Completion Rate:** \(String(format: "%.1f", weeklySummary.habitComplianceRate * 100))%
        - **Habits Completed:** \(weeklySummary.totalHabitsCompleted)/\(weeklySummary.totalHabitsTotal)
        
        ### Cleaning
        - **Completion Rate:** \(String(format: "%.1f", weeklySummary.cleaningComplianceRate * 100))%
        
        ### Hydration
        - **Daily Average:** \(String(format: "%.0f", weeklySummary.averageWaterOunces))oz
        
        ### Reading
        - **Days Read:** \(weeklySummary.daysWithReading)/7
        - **Pages Read:** \(weeklySummary.totalPagesRead)
        
        """
        
        // Current Reading
        if !currentBooks.isEmpty {
            output += "\n### Currently Reading\n"
            for book in currentBooks {
                output += "- **\(book.title)** by \(book.author) - \(book.progressPercentage)% complete (\(book.currentPage)/\(book.totalPages) pages)\n"
            }
        }
        
        // Daily Breakdown
        output += "\n---\n\n## Daily Breakdown\n\n"
        output += "| Day | Score | Habits | Cleaning | Water | Read |\n"
        output += "|-----|-------|--------|----------|-------|------|\n"
        
        for day in weeklySummary.days {
            let dayName = day.dayOfWeek.prefix(3)
            let score = String(format: "%.0f%%", day.score)
            let habits = "\(day.habitsCompleted)/\(day.habitsTotal)"
            let cleaning = "\(day.cleaningTasksCompleted)/\(day.cleaningTasksTotal)"
            let water = "\(Int(day.waterOunces))oz"
            let read = day.didRead ? "✓" : "✗"
            
            output += "| \(dayName) | \(score) | \(habits) | \(cleaning) | \(water) | \(read) |\n"
        }
        
        // Reflections
        let validNotes = reflectionNotes.filter { !$0.isEmpty }
        if !validNotes.isEmpty {
            output += "\n---\n\n## Reflections\n"
            for note in validNotes {
                output += "\n> \(note)\n"
            }
        }
        
        // Prompt for ChatGPT
        output += """
        
        ---
        
        ## Questions for Review
        
        Based on this data, please help me reflect on:
        1. What patterns do you notice in my performance?
        2. Which areas need the most attention?
        3. What adjustments would you suggest for next week?
        4. Am I on track for my annual KPIs?
        
        """
        
        return output
    }
    
    // MARK: - Daily Export
    
    static func generateDailyExport(
        summary: DaySummary,
        habits: [(HabitTemplate, HabitLog?)],
        cleaningTasks: [(CleaningTask, Bool)],
        currentBook: Book?
    ) -> String {
        var output = """
        # Daily Summary - \(summary.formattedDate)
        
        ## Score: \(String(format: "%.0f", summary.score))%
        
        ---
        
        ## Habits (\(summary.habitsCompleted)/\(summary.habitsTotal))
        
        """
        
        for (habit, log) in habits {
            let status = log?.completed == true ? "✓" : "○"
            var line = "\(status) \(habit.title)"
            
            if let value = log?.numericValue, let unit = habit.unit {
                line += " - \(Int(value))\(unit)"
            }
            if let duration = log?.durationMinutes {
                line += " - \(duration) min"
            }
            
            output += line + "\n"
        }
        
        output += "\n## Cleaning (\(summary.cleaningTasksCompleted)/\(summary.cleaningTasksTotal))\n\n"
        
        for (task, completed) in cleaningTasks {
            let status = completed ? "✓" : "○"
            output += "\(status) \(task.title)\n"
        }
        
        output += """
        
        ## Water: \(Int(summary.waterOunces))/\(Int(summary.waterTarget))oz (\(String(format: "%.0f", summary.waterCompletionRate * 100))%)
        
        ## Reading
        - Pages Read: \(summary.pagesRead)
        """
        
        if let book = currentBook {
            output += "\n- Currently Reading: \(book.title) (\(book.progressPercentage)%)"
        }
        
        if let note = summary.reflectionNote, !note.isEmpty {
            output += "\n\n## Reflection\n\(note)"
        }
        
        return output
    }
    
    // MARK: - Helpers
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
