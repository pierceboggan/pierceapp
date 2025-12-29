import Foundation

class HabitsViewModel: ObservableObject {
    @Published var habits: [HabitTemplate] = []
    @Published var habitsByCategory: [HabitCategory: [HabitTemplate]] = [:]
    
    private let habitService: HabitService
    
    init(habitService: HabitService = HabitService()) {
        self.habitService = habitService
        loadHabits()
    }
    
    func loadHabits() {
        habits = habitService.habits
        organizeByCategory()
    }
    
    func addHabit(title: String, category: HabitCategory, frequency: HabitFrequency, inputType: HabitInputType, targetValue: Double? = nil, unit: String? = nil) {
        let habit = HabitTemplate(
            title: title,
            category: category,
            frequency: frequency,
            inputType: inputType,
            targetValue: targetValue,
            unit: unit
        )
        habitService.addHabit(habit)
        loadHabits()
    }
    
    func toggleHabit(_ habit: HabitTemplate) {
        var updatedHabit = habit
        updatedHabit.isActive.toggle()
        habitService.updateHabit(updatedHabit)
        loadHabits()
    }
    
    func updateHabit(_ habit: HabitTemplate) {
        habitService.updateHabit(habit)
        loadHabits()
    }
    
    func deleteHabit(_ habit: HabitTemplate) {
        habitService.deleteHabit(habit)
        loadHabits()
    }
    
    private func organizeByCategory() {
        habitsByCategory = Dictionary(grouping: habits) { $0.category }
    }
}
