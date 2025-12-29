import Foundation

struct Book: Codable, Identifiable {
    let id: UUID
    var title: String
    var author: String
    var totalPages: Int
    var coverImageURL: String?
    var goodreadsId: String?
    var isCurrentlyReading: Bool
    var startedDate: Date?
    var finishedDate: Date?
    
    var progress: ReadingProgress? {
        didSet {
            updateCurrentlyReadingStatus()
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        totalPages: Int,
        coverImageURL: String? = nil,
        goodreadsId: String? = nil,
        isCurrentlyReading: Bool = false,
        startedDate: Date? = nil,
        finishedDate: Date? = nil,
        progress: ReadingProgress? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.coverImageURL = coverImageURL
        self.goodreadsId = goodreadsId
        self.isCurrentlyReading = isCurrentlyReading
        self.startedDate = startedDate
        self.finishedDate = finishedDate
        self.progress = progress
    }
    
    private mutating func updateCurrentlyReadingStatus() {
        if let progress = progress {
            isCurrentlyReading = progress.pagesRead < totalPages
            if progress.pagesRead >= totalPages && finishedDate == nil {
                finishedDate = Date()
            }
        }
    }
}

struct ReadingProgress: Codable {
    var pagesRead: Int
    var lastUpdated: Date
    
    init(pagesRead: Int = 0, lastUpdated: Date = Date()) {
        self.pagesRead = pagesRead
        self.lastUpdated = lastUpdated
    }
    
    func percentageComplete(totalPages: Int) -> Double {
        guard totalPages > 0 else { return 0 }
        return Double(pagesRead) / Double(totalPages) * 100
    }
}

struct ReadingSession: Codable, Identifiable {
    let id: UUID
    let bookId: UUID
    let date: Date
    var pagesRead: Int
    var minutes: Int?
    var note: String?
    
    init(
        id: UUID = UUID(),
        bookId: UUID,
        date: Date = Date(),
        pagesRead: Int,
        minutes: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.date = date
        self.pagesRead = pagesRead
        self.minutes = minutes
        self.note = note
    }
}

struct GoodreadsAccount: Codable {
    var userId: String
    var accessToken: String
    var lastSyncDate: Date?
    var isConnected: Bool
    
    init(
        userId: String,
        accessToken: String,
        lastSyncDate: Date? = nil,
        isConnected: Bool = true
    ) {
        self.userId = userId
        self.accessToken = accessToken
        self.lastSyncDate = lastSyncDate
        self.isConnected = isConnected
    }
}
