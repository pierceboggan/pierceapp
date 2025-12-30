//
//  Book.swift
//  Project2026
//
//  Book and reading session models
//

import Foundation

// MARK: - Book

struct Book: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var coverURL: URL?
    var status: BookStatus
    var startDate: Date?
    var finishDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(
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
    
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPages), 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var pagesRemaining: Int {
        max(totalPages - currentPage, 0)
    }
    
    var isComplete: Bool {
        currentPage >= totalPages
    }
}

// MARK: - Book Status

enum BookStatus: String, Codable, CaseIterable {
    case wantToRead = "Want to Read"
    case currentlyReading = "Currently Reading"
    case finished = "Finished"
    case abandoned = "Abandoned"
    
    var icon: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .currentlyReading: return "book.fill"
        case .finished: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle"
        }
    }
}

// MARK: - Reading Session

struct ReadingSession: Codable, Identifiable {
    let id: UUID
    let bookId: UUID
    let date: Date
    var pagesRead: Int
    var durationMinutes: Int?
    var note: String?
    var startPage: Int
    var endPage: Int
    
    init(
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

struct ReadingProgress: Codable, Identifiable {
    let id: UUID
    let date: Date
    var sessions: [ReadingSession]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        sessions: [ReadingSession] = []
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.sessions = sessions
    }
    
    var totalPagesRead: Int {
        sessions.reduce(0) { $0 + $1.pagesRead }
    }
    
    var totalMinutes: Int {
        sessions.compactMap { $0.durationMinutes }.reduce(0, +)
    }
    
    var didRead: Bool {
        totalPagesRead > 0
    }
}


