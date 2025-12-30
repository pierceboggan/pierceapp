//
//  CalendarService.swift
//  Project2026
//
//  Service for reading planned workouts from iCloud Calendar via EventKit.
//

import EventKit
import SwiftUI

/// Authorization status for calendar access.
public enum CalendarAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

/// Parsed workout metrics from TrainerRoad calendar notes.
public struct WorkoutMetrics: Equatable {
    /// Training Stress Score - measure of workout intensity and duration.
    public let tss: Int?
    /// Intensity Factor - ratio of normalized power to FTP.
    public let intensityFactor: Double?
    /// Energy expenditure in kilojoules.
    public let kilojoules: Int?
    /// Workout description text.
    public let description: String?
    /// Workout goals text.
    public let goals: String?
    /// Duration in minutes extracted from description.
    public let durationMinutes: Int?
    /// FTP percentage range (e.g., "50-55%").
    public let ftpRange: String?
    
    /// Returns true if any metrics were parsed.
    public var hasMetrics: Bool {
        tss != nil || intensityFactor != nil || kilojoules != nil
    }
    
    /// Formatted TSS display string.
    public var formattedTSS: String? {
        guard let tss = tss else { return nil }
        return "\(tss) TSS"
    }
    
    /// Formatted IF display string.
    public var formattedIF: String? {
        guard let intensityFactor = intensityFactor else { return nil }
        return String(format: "IF %.2f", intensityFactor)
    }
    
    /// Formatted energy display string.
    public var formattedEnergy: String? {
        guard let kj = kilojoules else { return nil }
        return "\(kj) kJ"
    }
}

/// Represents a planned workout event from the calendar.
public struct PlannedWorkout: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let duration: TimeInterval
    public let calendarName: String
    public let calendarColor: Color
    public let notes: String?
    public let location: String?
    /// Parsed workout metrics from TrainerRoad notes.
    public let metrics: WorkoutMetrics?
    
    /// Duration formatted as a human-readable string.
    public var formattedDuration: String {
        // Prefer duration from metrics if available (more accurate)
        if let metricsDuration = metrics?.durationMinutes {
            if metricsDuration < 60 {
                return "\(metricsDuration) min"
            } else {
                let hours = metricsDuration / 60
                let remainingMinutes = metricsDuration % 60
                if remainingMinutes == 0 {
                    return "\(hours)h"
                }
                return "\(hours)h \(remainingMinutes)m"
            }
        }
        
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    /// Returns true if this workout is happening today.
    public var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
    
    /// Returns true if this workout has already passed.
    public var isPast: Bool {
        startDate < Date()
    }
    
    /// Time formatted for display (e.g., "9:00 AM").
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    /// Short description for display (first sentence or truncated).
    public var shortDescription: String? {
        guard let description = metrics?.description else { return nil }
        // Get first sentence or first 100 chars
        if let periodIndex = description.firstIndex(of: ".") {
            return String(description[...periodIndex])
        }
        if description.count > 100 {
            return String(description.prefix(100)) + "..."
        }
        return description
    }
}

/// Service for fetching planned workout events from iCloud Calendar.
/// Uses EventKit to read calendar events that match workout-related criteria.
@MainActor
public class CalendarService: ObservableObject {
    @Published public private(set) var authorizationStatus: CalendarAuthorizationStatus = .notDetermined
    @Published public private(set) var plannedWorkouts: [PlannedWorkout] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?
    
    private let eventStore = EKEventStore()
    
    /// Keywords to identify workout events in calendar titles.
    /// Note: "mobility" is excluded as it's tracked separately in-app.
    private let workoutKeywords = [
        "workout", "training", "trainerroad", "trainer road",
        "cycling", "bike", "ride", "run", "running", "swim",
        "strength", "gym", "hiit", "yoga",
        "interval", "tempo", "endurance", "recovery",
        "zwift", "peloton", "spin", "tss", "ftp"
    ]
    
    /// Calendar names that are likely to contain workouts.
    private let workoutCalendarNames = [
        "trainerroad", "training", "workouts", "fitness", "exercise"
    ]
    
    public init() {
        updateAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Requests calendar access permission from the user.
    public func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            updateAuthorizationStatus()
            
            if granted {
                await fetchUpcomingWorkouts()
            }
        } catch {
            errorMessage = "Failed to request calendar access: \(error.localizedDescription)"
            updateAuthorizationStatus()
        }
    }
    
    /// Updates the authorization status based on current EventKit status.
    private func updateAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .fullAccess, .writeOnly:
            authorizationStatus = .authorized
        case .restricted:
            authorizationStatus = .restricted
        case .denied:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .denied
        }
    }
    
    // MARK: - Fetching Workouts
    
    /// Fetches upcoming workout events from the calendar.
    /// Looks ahead 14 days by default.
    public func fetchUpcomingWorkouts(daysAhead: Int = 14) async {
        guard authorizationStatus == .authorized else {
            errorMessage = "Calendar access not authorized"
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        guard let endDate = calendar.date(byAdding: .day, value: daysAhead, to: startDate) else {
            return
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Filter events that look like workouts
        let workoutEvents = events.filter { isWorkoutEvent($0) }
        
        plannedWorkouts = workoutEvents.map { event in
            let metrics = parseWorkoutMetrics(from: event.notes)
            return PlannedWorkout(
                id: event.eventIdentifier,
                title: event.title ?? "Workout",
                startDate: event.startDate,
                endDate: event.endDate,
                duration: event.endDate.timeIntervalSince(event.startDate),
                calendarName: event.calendar.title,
                calendarColor: Color(cgColor: event.calendar.cgColor),
                notes: event.notes,
                location: event.location,
                metrics: metrics
            )
        }
        .sorted { $0.startDate < $1.startDate }
    }
    
    /// Determines if a calendar event appears to be a workout.
    private func isWorkoutEvent(_ event: EKEvent) -> Bool {
        let title = (event.title ?? "").lowercased()
        let calendarName = event.calendar.title.lowercased()
        let notes = (event.notes ?? "").lowercased()
        
        // Check if calendar name suggests workouts
        if workoutCalendarNames.contains(where: { calendarName.contains($0) }) {
            return true
        }
        
        // Check if title contains workout keywords
        if workoutKeywords.contains(where: { title.contains($0) }) {
            return true
        }
        
        // Check if notes contain workout keywords
        if workoutKeywords.contains(where: { notes.contains($0) }) {
            return true
        }
        
        return false
    }
    
    // MARK: - TrainerRoad Notes Parsing
    
    /// Parses workout metrics from TrainerRoad calendar event notes.
    /// Example format: "TSS 35, IF 0.53, kJ(Cal) 432. Description: Vladeasa consists of 75 minutes..."
    private func parseWorkoutMetrics(from notes: String?) -> WorkoutMetrics? {
        guard let notes = notes, !notes.isEmpty else { return nil }
        
        let tss = parseTSS(from: notes)
        let intensityFactor = parseIF(from: notes)
        let kilojoules = parseKilojoules(from: notes)
        let description = parseDescription(from: notes)
        let goals = parseGoals(from: notes)
        let durationMinutes = parseDuration(from: notes)
        let ftpRange = parseFTPRange(from: notes)
        
        // Only return metrics if we found something useful
        if tss != nil || intensityFactor != nil || kilojoules != nil || description != nil {
            return WorkoutMetrics(
                tss: tss,
                intensityFactor: intensityFactor,
                kilojoules: kilojoules,
                description: description,
                goals: goals,
                durationMinutes: durationMinutes,
                ftpRange: ftpRange
            )
        }
        
        return nil
    }
    
    /// Parses TSS (Training Stress Score) from notes.
    /// Matches patterns like "TSS 35" or "TSS: 35"
    private func parseTSS(from notes: String) -> Int? {
        let pattern = #"TSS[:\s]+(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return Int(notes[range])
    }
    
    /// Parses IF (Intensity Factor) from notes.
    /// Matches patterns like "IF 0.53" or "IF: 0.53"
    private func parseIF(from notes: String) -> Double? {
        let pattern = #"IF[:\s]+([\d.]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return Double(notes[range])
    }
    
    /// Parses kilojoules from notes.
    /// Matches patterns like "kJ(Cal) 432" or "kJ 432"
    private func parseKilojoules(from notes: String) -> Int? {
        let pattern = #"kJ(?:\(Cal\))?[:\s]+(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return Int(notes[range])
    }
    
    /// Parses workout description from notes.
    /// Extracts text after "Description:" until "Goals:" or end.
    private func parseDescription(from notes: String) -> String? {
        let pattern = #"Description:\s*(.+?)(?:Goals:|$)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return String(notes[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Parses workout goals from notes.
    /// Extracts text after "Goals:"
    private func parseGoals(from notes: String) -> String? {
        let pattern = #"Goals:\s*(.+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return String(notes[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Parses duration in minutes from description.
    /// Matches patterns like "75 minutes" or "60 min"
    private func parseDuration(from notes: String) -> Int? {
        let pattern = #"(\d+)\s*min(?:utes?)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return Int(notes[range])
    }
    
    /// Parses FTP percentage range from description.
    /// Matches patterns like "50-55% FTP" or "88-94% FTP"
    private func parseFTPRange(from notes: String) -> String? {
        let pattern = #"(\d+-\d+%)\s*FTP"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: notes, range: NSRange(notes.startIndex..., in: notes)),
              let range = Range(match.range(at: 1), in: notes) else {
            return nil
        }
        return String(notes[range])
    }
    
    // MARK: - Convenience Methods
    
    /// Returns today's planned workouts.
    public var todaysWorkouts: [PlannedWorkout] {
        plannedWorkouts.filter { $0.isToday }
    }
    
    /// Returns upcoming workouts (not including today).
    public var upcomingWorkouts: [PlannedWorkout] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let tomorrowStart = Calendar.current.startOfDay(for: tomorrow)
        return plannedWorkouts.filter { $0.startDate >= tomorrowStart }
    }
    
    /// Returns the next scheduled workout.
    public var nextWorkout: PlannedWorkout? {
        plannedWorkouts.first { !$0.isPast }
    }
    
    /// Refreshes workout data from the calendar.
    public func refresh() async {
        await fetchUpcomingWorkouts()
    }
}
