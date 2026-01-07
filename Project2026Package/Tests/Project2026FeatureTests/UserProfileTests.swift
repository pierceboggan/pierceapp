import Testing
import Foundation
@testable import Project2026Feature

@Suite("User Profile Tests")
struct UserProfileTests {

    @Test("User profile initialization with defaults")
    func defaultInitialization() {
        let profile = UserProfile()

        #expect(profile.name == "User")
        #expect(profile.dailyWaterTarget == 100)
        #expect(profile.dailyProteinTarget == 145)
    }

    @Test("User profile initialization with custom values")
    func customInitialization() {
        let profile = UserProfile(
            name: "Pierce",
            dailyWaterTarget: 120,
            dailyProteinTarget: 160
        )

        #expect(profile.name == "Pierce")
        #expect(profile.dailyWaterTarget == 120)
        #expect(profile.dailyProteinTarget == 160)
    }

    @Test("User profile has unique ID")
    func hasUniqueID() {
        let profile1 = UserProfile()
        let profile2 = UserProfile()

        #expect(profile1.id != profile2.id)
    }

    @Test("User profile wake up time is set correctly")
    func wakeUpTimeIsSet() {
        let wakeTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
        let profile = UserProfile(wakeUpTime: wakeTime)

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.wakeUpTime)
        #expect(components.hour == 6)
        #expect(components.minute == 0)
    }

    @Test("User profile default wake up time")
    func defaultWakeUpTime() {
        let profile = UserProfile()

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.wakeUpTime)
        #expect(components.hour == 5)
        #expect(components.minute == 30)
    }

    @Test("User profile lights out time is set correctly")
    func lightsOutTimeIsSet() {
        let lightsOut = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
        let profile = UserProfile(lightsOutTime: lightsOut)

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.lightsOutTime)
        #expect(components.hour == 23)
        #expect(components.minute == 0)
    }

    @Test("User profile default lights out time")
    func defaultLightsOutTime() {
        let profile = UserProfile()

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.lightsOutTime)
        #expect(components.hour == 22)
        #expect(components.minute == 0)
    }

    @Test("User profile work start time is set correctly")
    func workStartTimeIsSet() {
        let workStart = Calendar.current.date(from: DateComponents(hour: 8, minute: 30)) ?? Date()
        let profile = UserProfile(workStartTime: workStart)

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.workStartTime)
        #expect(components.hour == 8)
        #expect(components.minute == 30)
    }

    @Test("User profile default work start time")
    func defaultWorkStartTime() {
        let profile = UserProfile()

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.workStartTime)
        #expect(components.hour == 9)
        #expect(components.minute == 0)
    }

    @Test("User profile work end time is set correctly")
    func workEndTimeIsSet() {
        let workEnd = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
        let profile = UserProfile(workEndTime: workEnd)

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.workEndTime)
        #expect(components.hour == 18)
        #expect(components.minute == 0)
    }

    @Test("User profile default work end time")
    func defaultWorkEndTime() {
        let profile = UserProfile()

        let components = Calendar.current.dateComponents([.hour, .minute], from: profile.workEndTime)
        #expect(components.hour == 17)
        #expect(components.minute == 30)
    }

    @Test("User profile conforms to Codable")
    func codableConformance() throws {
        let profile = UserProfile(
            name: "Test User",
            dailyWaterTarget: 110,
            dailyProteinTarget: 150
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserProfile.self, from: data)

        #expect(decoded.name == profile.name)
        #expect(decoded.dailyWaterTarget == profile.dailyWaterTarget)
        #expect(decoded.dailyProteinTarget == profile.dailyProteinTarget)
    }

    @Test("User profile tracks creation date")
    func tracksCreationDate() {
        let beforeCreation = Date()
        let profile = UserProfile()
        let afterCreation = Date()

        #expect(profile.createdAt >= beforeCreation)
        #expect(profile.createdAt <= afterCreation)
    }

    @Test("User profile tracks update date")
    func tracksUpdateDate() {
        let beforeCreation = Date()
        let profile = UserProfile()
        let afterCreation = Date()

        #expect(profile.updatedAt >= beforeCreation)
        #expect(profile.updatedAt <= afterCreation)
    }

    @Test("User profile with realistic water targets")
    func realisticWaterTargets() {
        let profiles = [
            UserProfile(dailyWaterTarget: 64),  // Minimum recommended
            UserProfile(dailyWaterTarget: 100), // Default
            UserProfile(dailyWaterTarget: 128)  // Higher target
        ]

        for profile in profiles {
            #expect(profile.dailyWaterTarget >= 64)
            #expect(profile.dailyWaterTarget <= 200)
        }
    }

    @Test("User profile with realistic protein targets")
    func realisticProteinTargets() {
        let profiles = [
            UserProfile(dailyProteinTarget: 100), // Lower target
            UserProfile(dailyProteinTarget: 145), // Default
            UserProfile(dailyProteinTarget: 200)  // Higher target
        ]

        for profile in profiles {
            #expect(profile.dailyProteinTarget >= 50)
            #expect(profile.dailyProteinTarget <= 300)
        }
    }
}
