import Foundation

class ExportService {
    func generateChatGPTExport(
        profile: UserProfile,
        summary: DaySummary,
        weeklySummaries: [DaySummary],
        habits: [HabitTemplate],
        habitLogs: [HabitLog],
        readingData: (totalPages: Int, currentBooks: [Book])
    ) -> String {
        var export = """
        # Project 2026 - Review Export
        
        ## Goals
        """
        
        for goal in profile.goals where goal.isActive {
            export += "\n- \(goal.title)"
        }
        
        export += "\n\n## KPIs\n"
        for kpi in profile.kpis {
            let current = kpi.currentValue ?? "Not tracked"
            export += "\n- \(kpi.title): Target \(kpi.target), Current: \(current)"
        }
        
        export += "\n\n## Today's Summary\n"
        export += "\n- Score: \(String(format: "%.1f", summary.score))%"
        export += "\n- Habits: \(summary.habitsCompleted)/\(summary.habitsTotal) completed"
        export += "\n- Cleaning: \(summary.cleaningCompleted)/\(summary.cleaningTotal) completed"
        export += "\n- Water: \(summary.waterConsumed)oz / \(summary.waterTarget)oz"
        export += "\n- Pages Read: \(summary.pagesRead)"
        
        export += "\n\n## Weekly Performance\n"
        if !weeklySummaries.isEmpty {
            let avgScore = weeklySummaries.reduce(0.0) { $0 + $1.score } / Double(weeklySummaries.count)
            let totalHabitsCompleted = weeklySummaries.reduce(0) { $0 + $1.habitsCompleted }
            let totalHabitsAvailable = weeklySummaries.reduce(0) { $0 + $1.habitsTotal }
            let habitCompliance = totalHabitsAvailable > 0 ? Double(totalHabitsCompleted) / Double(totalHabitsAvailable) * 100 : 0
            
            export += "\n- Average Score: \(String(format: "%.1f", avgScore))%"
            export += "\n- Habit Compliance: \(String(format: "%.1f", habitCompliance))%"
            export += "\n- Days Tracked: \(weeklySummaries.count)"
        }
        
        export += "\n\n## Current Reading\n"
        if readingData.currentBooks.isEmpty {
            export += "\n- No books currently being read"
        } else {
            for book in readingData.currentBooks {
                let progress = book.progress?.percentageComplete(totalPages: book.totalPages) ?? 0
                export += "\n- \(book.title) by \(book.author): \(String(format: "%.0f", progress))% complete"
            }
        }
        export += "\n- Total pages read this week: \(readingData.totalPages)"
        
        if let notes = summary.reflectionNotes, !notes.isEmpty {
            export += "\n\n## Reflection Notes\n\(notes)"
        }
        
        export += "\n\n---\nGenerated: \(Date().formatted())"
        
        return export
    }
}
