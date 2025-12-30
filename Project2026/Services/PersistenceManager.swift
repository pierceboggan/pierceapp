//
//  PersistenceManager.swift
//  Project2026
//
//  Generic persistence manager for local storage
//

import Foundation

actor PersistenceManager {
    static let shared = PersistenceManager()
    
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
    
    func save<T: Encodable>(_ object: T, to filename: String) throws {
        let url = storageDirectory.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    // MARK: - Load
    
    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = storageDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Delete
    
    func delete(filename: String) throws {
        let url = storageDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Exists
    
    func exists(filename: String) -> Bool {
        let url = storageDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path)
    }
}

// MARK: - Storage Keys

enum StorageKey {
    static let userProfile = "user_profile.json"
    static let goals = "goals.json"
    static let habitTemplates = "habit_templates.json"
    static let habitLogs = "habit_logs.json"
    static let cleaningTasks = "cleaning_tasks.json"
    static let cleaningLogs = "cleaning_logs.json"
    static let waterLogs = "water_logs.json"
    static let books = "books.json"
    static let readingSessions = "reading_sessions.json"
    static let daySummaries = "day_summaries.json"
}
