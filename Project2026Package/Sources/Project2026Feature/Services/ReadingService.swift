//
//  ReadingService.swift
//  Project2026
//
//  Service for tracking reading progress
//

import SwiftUI

/// Manages book library and reading session tracking.
/// Tracks pages read per day, maintains reading history, and identifies the primary book.
/// All book data is entered and managed manually by the user.
@MainActor
public class ReadingService: ObservableObject {
    @Published var books: [Book] = []
    @Published var readingSessions: [ReadingSession] = []
    @Published var isLoading = false
    
    private let persistence = PersistenceManager.shared
    
    public init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    public func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            books = try await persistence.load([Book].self, from: StorageKey.books)
        } catch {
            books = []
        }
        
        do {
            readingSessions = try await persistence.load([ReadingSession].self, from: StorageKey.readingSessions)
        } catch {
            readingSessions = []
        }
    }
    
    // MARK: - Current Reading
    
    public var currentlyReading: [Book] {
        books.filter { $0.status == .currentlyReading }
    }
    
    public var primaryBook: Book? {
        currentlyReading.first
    }
    
    public var finishedBooks: [Book] {
        books.filter { $0.status == .finished }
    }
    
    public var wantToReadBooks: [Book] {
        books.filter { $0.status == .wantToRead }
    }
    
    // MARK: - Book Management
    
    public func addBook(_ book: Book) async {
        var newBook = book
        if newBook.status == .currentlyReading && newBook.startDate == nil {
            newBook.startDate = Date()
        }
        books.append(newBook)
        await saveBooks()
    }
    
    public func updateBook(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            await saveBooks()
        }
    }
    
    public func deleteBook(_ book: Book) async {
        books.removeAll { $0.id == book.id }
        readingSessions.removeAll { $0.bookId == book.id }
        await saveBooks()
        await saveSessions()
    }
    
    public func startReading(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].status = .currentlyReading
            books[index].startDate = Date()
            await saveBooks()
        }
    }
    
    public func finishReading(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].status = .finished
            books[index].finishDate = Date()
            books[index].currentPage = books[index].totalPages
            await saveBooks()
        }
    }
    
    // MARK: - Reading Sessions
    
    /// Log reading for a specific date (defaults to today).
    public func logReading(book: Book, pagesRead: Int, durationMinutes: Int? = nil, note: String? = nil, on date: Date = Date()) async {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        
        let startPage = books[index].currentPage
        let endPage = startPage + pagesRead
        
        let session = ReadingSession(
            bookId: book.id,
            date: date,
            pagesRead: pagesRead,
            durationMinutes: durationMinutes,
            note: note,
            startPage: startPage,
            endPage: endPage
        )
        readingSessions.append(session)
        
        // Update book progress
        books[index].currentPage = min(endPage, books[index].totalPages)
        books[index].updatedAt = Date()
        
        // Auto-finish if complete
        if books[index].isComplete {
            books[index].status = .finished
            books[index].finishDate = date
        }
        
        await saveBooks()
        await saveSessions()
    }
    
    public func updateProgress(book: Book, currentPage: Int) async {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        
        let pagesRead = currentPage - books[index].currentPage
        if pagesRead > 0 {
            let session = ReadingSession(
                bookId: book.id,
                pagesRead: pagesRead,
                startPage: books[index].currentPage,
                endPage: currentPage
            )
            readingSessions.append(session)
        }
        
        books[index].currentPage = min(currentPage, books[index].totalPages)
        books[index].updatedAt = Date()
        
        if books[index].isComplete {
            books[index].status = .finished
            books[index].finishDate = Date()
        }
        
        await saveBooks()
        await saveSessions()
    }
    
    // MARK: - Statistics
    
    public func sessionsForToday() -> [ReadingSession] {
        sessionsFor(date: Date())
    }
    
    /// Returns reading sessions for a specific date
    public func sessionsFor(date: Date) -> [ReadingSession] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return readingSessions.filter { $0.date == dayStart }
    }
    
    public func pagesReadToday() -> Int {
        sessionsForToday().reduce(0) { $0 + $1.pagesRead }
    }
    
    /// Pages read on a specific date
    public func pagesRead(on date: Date) -> Int {
        sessionsFor(date: date).reduce(0) { $0 + $1.pagesRead }
    }
    
    public func didReadToday() -> Bool {
        !sessionsForToday().isEmpty
    }
    
    /// Check if user read on a specific date
    public func didRead(on date: Date) -> Bool {
        !sessionsFor(date: date).isEmpty
    }
    
    public func sessionsForBook(_ bookId: UUID) -> [ReadingSession] {
        readingSessions.filter { $0.bookId == bookId }
            .sorted { $0.date > $1.date }
    }
    
    public func totalPagesRead(for book: Book) -> Int {
        sessionsForBook(book.id).reduce(0) { $0 + $1.pagesRead }
    }
    
    public func readingStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while readingSessions.contains(where: { $0.date == currentDate }) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    public func booksFinishedThisYear() -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return finishedBooks.filter { book in
            guard let finishDate = book.finishDate else { return false }
            return calendar.component(.year, from: finishDate) == currentYear
        }.count
    }
    
    // MARK: - Persistence
    
    private func saveBooks() async {
        do {
            try await persistence.save(books, to: StorageKey.books)
        } catch {
            print("Failed to save books: \(error)")
        }
    }
    
    private func saveSessions() async {
        do {
            try await persistence.save(readingSessions, to: StorageKey.readingSessions)
        } catch {
            print("Failed to save reading sessions: \(error)")
        }
    }
}
