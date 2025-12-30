//
//  Book.swift
//  Project2026
//
//  Book and reading session models
//

import Foundation

// MARK: - Book

/// Represents a book being tracked for reading progress.
/// Tracks current page, total pages, and reading status (want to read, reading, finished).
/// All book data is entered manually by the user.
public struct Book: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var author: String
    public var totalPages: Int
    public var currentPage: Int
    public var coverURL: URL?
    public var status: BookStatus
    public var startDate: Date?
    public var finishDate: Date?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        author: String = "",
        totalPages: Int,
        currentPage: Int = 0,
        coverURL: URL? = nil,
        status: BookStatus = .wantToRead,
        startDate: Date? = nil,
        finishDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.coverURL = coverURL
        self.status = status
        self.startDate = startDate
        self.finishDate = finishDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var progress: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPages), 1.0)
    }
    
    public var progressPercentage: Int {
        Int(progress * 100)
    }
    
    public var pagesRemaining: Int {
        max(totalPages - currentPage, 0)
    }
    
    public var isComplete: Bool {
        currentPage >= totalPages
    }
}

// MARK: - Book Status

public enum BookStatus: String, Codable, CaseIterable, Sendable {
    case wantToRead = "Want to Read"
    case currentlyReading = "Currently Reading"
    case finished = "Finished"
    case abandoned = "Abandoned"
    
    public var icon: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .currentlyReading: return "book.fill"
        case .finished: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle"
        }
    }
}

// MARK: - Reading Session

/// Records a single reading session with pages read, duration, and page range.
/// Links to a specific book and tracks when reading occurred.
public struct ReadingSession: Codable, Identifiable, Sendable {
    public let id: UUID
    let bookId: UUID
    let date: Date
    public var pagesRead: Int
    public var durationMinutes: Int?
    public var note: String?
    public var startPage: Int
    public var endPage: Int
    
    public init(
        id: UUID = UUID(),
        bookId: UUID,
        date: Date = Date(),
        pagesRead: Int,
        durationMinutes: Int? = nil,
        note: String? = nil,
        startPage: Int = 0,
        endPage: Int = 0
    ) {
        self.id = id
        self.bookId = bookId
        self.date = Calendar.current.startOfDay(for: date)
        self.pagesRead = pagesRead
        self.durationMinutes = durationMinutes
        self.note = note
        self.startPage = startPage
        self.endPage = endPage
    }
}

// MARK: - Reading Progress (Daily Summary)

/// Aggregates all reading sessions for a single day.
/// Used to track daily reading habits and calculate pages read per day.
public struct ReadingProgress: Codable, Identifiable, Sendable {
    public let id: UUID
    let date: Date
    public var sessions: [ReadingSession]
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        sessions: [ReadingSession] = []
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.sessions = sessions
    }
    
    public var totalPagesRead: Int {
        sessions.reduce(0) { $0 + $1.pagesRead }
    }
    
    public var totalMinutes: Int {
        sessions.compactMap { $0.durationMinutes }.reduce(0, +)
    }
    
    public var didRead: Bool {
        totalPagesRead > 0
    }
}


