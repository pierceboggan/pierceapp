import Foundation

class WaterService: ObservableObject {
    @Published var todaysLog: WaterLog
    @Published var allLogs: [WaterLog] = []
    
    private let logsKey = "waterLogs"
    var dailyTarget: Int = 100
    
    init() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        todaysLog = WaterLog(date: today)
        loadLogs()
        
        // Find or create today's log
        if let existingLog = allLogs.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            todaysLog = existingLog
        } else {
            todaysLog = WaterLog(date: today)
            allLogs.append(todaysLog)
            saveLogs()
        }
    }
    
    func addWater(ounces: Int) {
        let entry = WaterEntry(ounces: ounces)
        todaysLog.entries.append(entry)
        updateTodaysLog()
    }
    
    func getTodayProgress() -> Double {
        guard dailyTarget > 0 else { return 0 }
        return Double(todaysLog.totalOunces) / Double(dailyTarget)
    }
    
    func isTargetMet() -> Bool {
        return todaysLog.totalOunces >= dailyTarget
    }
    
    private func updateTodaysLog() {
        if let index = allLogs.firstIndex(where: { $0.id == todaysLog.id }) {
            allLogs[index] = todaysLog
        }
        saveLogs()
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([WaterLog].self, from: data) {
            allLogs = decoded
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(allLogs) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
    }
}
