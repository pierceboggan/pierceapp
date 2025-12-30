//
//  PersistenceManager.swift
//  Project2026
//
//  Generic persistence manager for local storage
//

import Foundation

/// Thread-safe actor for reading and writing Codable data to local JSON files.
/// Supports both the app's documents directory and shared App Group container for widgets.
/// Used by all services for data persistence with async/await API.
actor PersistenceManager {
    public static let shared = PersistenceManager()
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var appGroupDirectory: URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.project2026.app")
    }
    
    // Use app group for widget sharing, fallback to documents
    private var storageDirectory: URL {
        appGroupDirectory ?? documentsDirectory
    }
    
    private init() {}
    
    // MARK: - Save
    
    public func save<T: Encodable>(_ object: T, to filename: String) throws {
        let url = storageDirectory.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    // MARK: - Load
    
    public func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = storageDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Delete
    
    public func delete(filename: String) throws {
        let url = storageDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Exists
    
    public func exists(filename: String) -> Bool {
        let url = storageDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path)
    }
}

// MARK: - Storage Keys

public enum StorageKey {
    public static let userProfile = "user_profile.json"
    public static let goals = "goals.json"
    public static let habitTemplates = "habit_templates.json"
    public static let habitLogs = "habit_logs.json"
    public static let cleaningTasks = "cleaning_tasks.json"
    public static let cleaningLogs = "cleaning_logs.json"
    public static let waterLogs = "water_logs.json"
    public static let books = "books.json"
    public static let readingSessions = "reading_sessions.json"
    public static let daySummaries = "day_summaries.json"
}
