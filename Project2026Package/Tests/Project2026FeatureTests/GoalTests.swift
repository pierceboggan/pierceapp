import Testing
@testable import Project2026Feature

@Suite("Goal Category Tests")
struct GoalCategoryTests {

    @Test("All categories have icons")
    func allCategoriesHaveIcons() {
        for category in GoalCategory.allCases {
            #expect(!category.icon.isEmpty, "Category \(category.rawValue) should have an icon")
        }
    }

    @Test("Category raw values are correct")
    func rawValuesAreCorrect() {
        #expect(GoalCategory.presence.rawValue == "Presence")
        #expect(GoalCategory.health.rawValue == "Health")
        #expect(GoalCategory.outdoors.rawValue == "Outdoors")
        #expect(GoalCategory.fitness.rawValue == "Fitness")
        #expect(GoalCategory.phone.rawValue == "Phone")
    }

    @Test("Category icons are unique")
    func iconsAreUnique() {
        let icons = GoalCategory.allCases.map { $0.icon }
        let uniqueIcons = Set(icons)
        #expect(icons.count == uniqueIcons.count, "All category icons should be unique")
    }
}

@Suite("Goal Model Tests")
struct GoalTests {

    @Test("High-level goal initialization")
    func highLevelGoalInitialization() {
        let goal = Goal(
            title: "Live a healthy life",
            category: .health,
            isHighLevel: true
        )

        #expect(goal.title == "Live a healthy life")
        #expect(goal.category == .health)
        #expect(goal.isHighLevel)
        #expect(goal.isActive)
        #expect(goal.targetValue == nil)
        #expect(goal.currentValue == nil)
        #expect(goal.progress == nil)
    }

    @Test("KPI goal initialization")
    func kpiGoalInitialization() {
        let goal = Goal(
            title: "Reach 250 FTP",
            category: .fitness,
            isHighLevel: false,
            targetValue: 250,
            currentValue: 200,
            unit: "FTP"
        )

        #expect(goal.title == "Reach 250 FTP")
        #expect(goal.category == .fitness)
        #expect(!goal.isHighLevel)
        #expect(goal.targetValue == 250)
        #expect(goal.currentValue == 200)
        #expect(goal.unit == "FTP")
    }

    @Test("Goal progress calculation")
    func progressCalculation() {
        let goal = Goal(
            title: "Ski 50 days",
            category: .outdoors,
            isHighLevel: false,
            targetValue: 50,
            currentValue: 25
        )

        #expect(goal.progress == 0.5)
    }

    @Test("Goal progress caps at 100%")
    func progressCapsAt100Percent() {
        let goal = Goal(
            title: "Read books",
            category: .presence,
            isHighLevel: false,
            targetValue: 10,
            currentValue: 15
        )

        #expect(goal.progress == 1.0)
    }

    @Test("Goal progress is nil when no target")
    func progressIsNilWithoutTarget() {
        let goal = Goal(
            title: "Be more present",
            category: .presence,
            isHighLevel: true
        )

        #expect(goal.progress == nil)
    }

    @Test("Goal progress is nil when no current value")
    func progressIsNilWithoutCurrentValue() {
        let goal = Goal(
            title: "Reach goal",
            category: .fitness,
            isHighLevel: false,
            targetValue: 100
        )

        #expect(goal.progress == nil)
    }

    @Test("Goal progress is nil when target is zero")
    func progressIsNilWithZeroTarget() {
        let goal = Goal(
            title: "Invalid goal",
            category: .fitness,
            isHighLevel: false,
            targetValue: 0,
            currentValue: 10
        )

        #expect(goal.progress == nil)
    }

    @Test("Inactive goal can be created")
    func inactiveGoal() {
        let goal = Goal(
            title: "Old goal",
            category: .fitness,
            isHighLevel: false,
            isActive: false
        )

        #expect(!goal.isActive)
    }
}

@Suite("Default Goals Tests")
struct DefaultGoalsTests {

    @Test("Default high-level goals exist")
    func defaultHighLevelGoalsExist() {
        let goals = Goal.defaultHighLevelGoals

        #expect(!goals.isEmpty)
        #expect(goals.count == 3)

        for goal in goals {
            #expect(goal.isHighLevel)
            #expect(!goal.title.isEmpty)
        }
    }

    @Test("Default high-level goals cover key categories")
    func highLevelGoalsCoverKeyCategories() {
        let goals = Goal.defaultHighLevelGoals
        let categories = Set(goals.map { $0.category })

        #expect(categories.contains(.presence))
        #expect(categories.contains(.health))
        #expect(categories.contains(.outdoors))
    }

    @Test("Default KPIs exist")
    func defaultKPIsExist() {
        let kpis = Goal.defaultKPIs

        #expect(!kpis.isEmpty)
        #expect(kpis.count == 4)

        for kpi in kpis {
            #expect(!kpi.isHighLevel)
            #expect(!kpi.title.isEmpty)
            #expect(kpi.targetValue != nil)
            #expect(kpi.unit != nil)
        }
    }

    @Test("Default KPI for FTP is correct")
    func ftpKPIIsCorrect() {
        let kpis = Goal.defaultKPIs
        let ftpGoal = kpis.first { $0.title.contains("FTP") }

        #expect(ftpGoal != nil)
        #expect(ftpGoal?.targetValue == 250)
        #expect(ftpGoal?.unit == "FTP")
        #expect(ftpGoal?.category == .fitness)
    }

    @Test("Default KPI for skiing resorts is correct")
    func skiResortsKPIIsCorrect() {
        let kpis = Goal.defaultKPIs
        let skiResortsGoal = kpis.first { $0.title.contains("resort") }

        #expect(skiResortsGoal != nil)
        #expect(skiResortsGoal?.targetValue == 7)
        #expect(skiResortsGoal?.unit == "resorts")
        #expect(skiResortsGoal?.category == .outdoors)
    }

    @Test("Default KPI for ski days is correct")
    func skiDaysKPIIsCorrect() {
        let kpis = Goal.defaultKPIs
        let skiDaysGoal = kpis.first { $0.title.contains("Ski 50") }

        #expect(skiDaysGoal != nil)
        #expect(skiDaysGoal?.targetValue == 50)
        #expect(skiDaysGoal?.unit == "days")
        #expect(skiDaysGoal?.category == .outdoors)
    }

    @Test("Default KPI for phone usage is correct")
    func phoneUsageKPIIsCorrect() {
        let kpis = Goal.defaultKPIs
        let phoneGoal = kpis.first { $0.title.contains("Phone") }

        #expect(phoneGoal != nil)
        #expect(phoneGoal?.targetValue == 60)
        #expect(phoneGoal?.unit == "min/day avg")
        #expect(phoneGoal?.category == .phone)
    }

    @Test("All default goals are active")
    func allDefaultGoalsAreActive() {
        let allGoals = Goal.defaultHighLevelGoals + Goal.defaultKPIs

        for goal in allGoals {
            #expect(goal.isActive)
        }
    }

    @Test("All default KPIs have initial current value of zero")
    func allKPIsStartAtZero() {
        for kpi in Goal.defaultKPIs {
            #expect(kpi.currentValue == 0)
        }
    }
}
