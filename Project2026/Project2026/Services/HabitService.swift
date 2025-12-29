import Foundation

class HabitService: ObservableObject {
    @Published var habits: [HabitTemplate] = []
    @Published var habitLogs: [HabitLog] = []
    
    private let habitsKey = "habits"
    private let logsKey = "habitLogs"
    
    init() {
        loadHabits()
        loadLogs()
        if habits.isEmpty {
            createCoreHabits()
        }
    }
    
    private func createCoreHabits() {
        let coreHabits: [HabitTemplate] = [
            // Life
            HabitTemplate(title: "Brick phone 5-8pm", category: .life, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Read a chapter a day", category: .life, inputType: .boolean, isCoreHabit: true),
            
            // Fitness
            HabitTemplate(title: "Workout", category: .fitness, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Mobility", category: .fitness, inputType: .boolean, isCoreHabit: true),
            
            // Nutrition
            HabitTemplate(title: "Drink 100oz of water", category: .nutrition, inputType: .numeric, isCoreHabit: true, targetValue: 100, unit: "oz"),
            HabitTemplate(title: "Minimize processed foods", category: .nutrition, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "No liquid calories", category: .nutrition, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Only 2 cups of coffee", category: .nutrition, inputType: .numeric, isCoreHabit: true, targetValue: 2, unit: "cups"),
            HabitTemplate(title: "Hit 145g of protein", category: .nutrition, inputType: .numeric, isCoreHabit: true, targetValue: 145, unit: "g"),
            
            // Health
            HabitTemplate(title: "Lights out by 10pm", category: .health, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Track HRV daily", category: .health, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Meditate daily", category: .health, inputType: .boolean, isCoreHabit: true),
            
            // Work
            HabitTemplate(title: "Work 9-5:30", category: .work, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Limit social media to 15 min/day", category: .work, inputType: .numeric, isCoreHabit: true, targetValue: 15, unit: "min"),
            
            // Supplements & Recovery
            HabitTemplate(title: "Wake up 5:30am", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Multivitamin", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Recovery vitamin", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Anti-sickness vitamin", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "10 min in hot tub", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true),
            HabitTemplate(title: "Daily mobility", category: .supplementsRecovery, inputType: .boolean, isCoreHabit: true)
        ]
        
        habits = coreHabits
        saveHabits()
    }
    
    func addHabit(_ habit: HabitTemplate) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: HabitTemplate) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: HabitTemplate) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func logHabit(habitId: UUID, completed: Bool, value: Double? = nil, note: String? = nil) {
        let log = HabitLog(habitId: habitId, completed: completed, value: value, note: note)
        habitLogs.append(log)
        saveLogs()
    }
    
    func getLogsForToday() -> [HabitLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return habitLogs.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    func getLogForHabit(habitId: UUID, date: Date = Date()) -> HabitLog? {
        let calendar = Calendar.current
        return habitLogs.first { log in
            log.habitId == habitId && calendar.isDate(log.date, inSameDayAs: date)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([HabitTemplate].self, from: data) {
            habits = decoded
        }
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([HabitLog].self, from: data) {
            habitLogs = decoded
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(habitLogs) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
    }
}
