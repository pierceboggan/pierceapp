import Foundation

class HistoryViewModel: ObservableObject {
    @Published var summaries: [DaySummary] = []
    @Published var weeklySummaries: [DaySummary] = []
    
    private let summaryService: DaySummaryService
    private let habitService: HabitService
    private let cleaningService: CleaningService
    private let waterService: WaterService
    private let readingService: ReadingService
    private let exportService: ExportService
    
    init(
        summaryService: DaySummaryService = DaySummaryService(),
        habitService: HabitService = HabitService(),
        cleaningService: CleaningService = CleaningService(),
        waterService: WaterService = WaterService(),
        readingService: ReadingService = ReadingService(),
        exportService: ExportService = ExportService()
    ) {
        self.summaryService = summaryService
        self.habitService = habitService
        self.cleaningService = cleaningService
        self.waterService = waterService
        self.readingService = readingService
        self.exportService = exportService
        
        loadSummaries()
    }
    
    func loadSummaries() {
        summaries = summaryService.summaries.sorted { $0.date > $1.date }
        weeklySummaries = summaryService.getWeeklySummaries()
    }
    
    func getSummary(for date: Date) -> DaySummary? {
        return summaryService.getSummary(for: date)
    }
    
    func generateChatGPTExport() -> String {
        let profile = UserProfile(
            dailyWaterTarget: waterService.dailyTarget,
            goals: [
                Goal(title: "Be more present and enjoy the time I have"),
                Goal(title: "Live a healthy life"),
                Goal(title: "Enjoy the outdoors and Utah more")
            ],
            kpis: [
                KPI(title: "Bike", target: "250 FTP"),
                KPI(title: "Ski", target: "Ski every SLC resort, ski 50 days"),
                KPI(title: "Phone", target: "Under 1 hour/day")
            ]
        )
        
        let todaysSummary = summaryService.calculateDailySummary(
            habitService: habitService,
            cleaningService: cleaningService,
            waterService: waterService,
            readingService: readingService
        )
        
        let currentBooks = readingService.getCurrentlyReadingBooks()
        let totalPages = readingService.getTotalPagesReadToday()
        
        return exportService.generateChatGPTExport(
            profile: profile,
            summary: todaysSummary,
            weeklySummaries: weeklySummaries,
            habits: habitService.habits,
            habitLogs: habitService.habitLogs,
            readingData: (totalPages: totalPages, currentBooks: currentBooks)
        )
    }
}
