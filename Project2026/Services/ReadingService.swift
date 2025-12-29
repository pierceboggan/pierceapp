//
//  ReadingService.swift
//  Project2026
//
//  Service for tracking reading progress
//

import SwiftUI

@MainActor
class ReadingService: ObservableObject {
    @Published var books: [Book] = []
    @Published var readingSessions: [ReadingSession] = []
    @Published var goodreadsAccount: GoodreadsAccount = GoodreadsAccount()
    @Published var isLoading = false
    @Published var isSyncing = false
    
    private let persistence = PersistenceManager.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
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
        
        do {
            goodreadsAccount = try await persistence.load(GoodreadsAccount.self, from: StorageKey.goodreadsAccount)
        } catch {
            goodreadsAccount = GoodreadsAccount()
        }
    }
    
    // MARK: - Current Reading
    
    var currentlyReading: [Book] {
        books.filter { $0.status == .currentlyReading }
    }
    
    var primaryBook: Book? {
        currentlyReading.first
    }
    
    var finishedBooks: [Book] {
        books.filter { $0.status == .finished }
    }
    
    var wantToReadBooks: [Book] {
        books.filter { $0.status == .wantToRead }
    }
    
    // MARK: - Book Management
    
    func addBook(_ book: Book) async {
        var newBook = book
        if newBook.status == .currentlyReading && newBook.startDate == nil {
            newBook.startDate = Date()
        }
        books.append(newBook)
        await saveBooks()
    }
    
    func updateBook(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            await saveBooks()
        }
    }
    
    func deleteBook(_ book: Book) async {
        books.removeAll { $0.id == book.id }
        readingSessions.removeAll { $0.bookId == book.id }
        await saveBooks()
        await saveSessions()
    }
    
    func startReading(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].status = .currentlyReading
            books[index].startDate = Date()
            await saveBooks()
        }
    }
    
    func finishReading(_ book: Book) async {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].status = .finished
            books[index].finishDate = Date()
            books[index].currentPage = books[index].totalPages
            await saveBooks()
        }
    }
    
    // MARK: - Reading Sessions
    
    func logReading(book: Book, pagesRead: Int, durationMinutes: Int? = nil, note: String? = nil) async {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        
        let startPage = books[index].currentPage
        let endPage = startPage + pagesRead
        
        let session = ReadingSession(
            bookId: book.id,
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
            books[index].finishDate = Date()
        }
        
        await saveBooks()
        await saveSessions()
    }
    
    func updateProgress(book: Book, currentPage: Int) async {
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
    
    func sessionsForToday() -> [ReadingSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return readingSessions.filter { $0.date == today }
    }
    
    func pagesReadToday() -> Int {
        sessionsForToday().reduce(0) { $0 + $1.pagesRead }
    }
    
    func didReadToday() -> Bool {
        !sessionsForToday().isEmpty
    }
    
    func sessionsForBook(_ bookId: UUID) -> [ReadingSession] {
        readingSessions.filter { $0.bookId == bookId }
            .sorted { $0.date > $1.date }
    }
    
    func totalPagesRead(for book: Book) -> Int {
        sessionsForBook(book.id).reduce(0) { $0 + $1.pagesRead }
    }
    
    func readingStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while readingSessions.contains(where: { $0.date == currentDate }) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    func booksFinishedThisYear() -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return finishedBooks.filter { book in
            guard let finishDate = book.finishDate else { return false }
            return calendar.component(.year, from: finishDate) == currentYear
        }.count
    }
    
    // MARK: - Goodreads Integration (Placeholder)
    
    func connectGoodreads() async {
        // OAuth flow would go here
        // For v1, this is a placeholder
        isSyncing = true
        defer { isSyncing = false }
        
        // Simulate connection
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real implementation:
        // 1. Open OAuth URL
        // 2. Handle callback
        // 3. Store tokens
        // 4. Fetch currently reading shelf
    }
    
    func disconnectGoodreads() async {
        goodreadsAccount = GoodreadsAccount()
        await saveGoodreadsAccount()
    }
    
    func syncWithGoodreads() async {
        guard goodreadsAccount.isConnected else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        // In a real implementation:
        // 1. Fetch currently-reading shelf
        // 2. Update local books with Goodreads data
        // 3. Handle conflicts
        
        goodreadsAccount.lastSyncDate = Date()
        await saveGoodreadsAccount()
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
    
    private func saveGoodreadsAccount() async {
        do {
            try await persistence.save(goodreadsAccount, to: StorageKey.goodreadsAccount)
        } catch {
            print("Failed to save Goodreads account: \(error)")
        }
    }
}
