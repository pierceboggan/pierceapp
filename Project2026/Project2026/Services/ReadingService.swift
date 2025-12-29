import Foundation

class ReadingService: ObservableObject {
    @Published var books: [Book] = []
    @Published var sessions: [ReadingSession] = []
    
    private let booksKey = "books"
    private let sessionsKey = "readingSessions"
    
    init() {
        loadBooks()
        loadSessions()
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        sessions.removeAll { $0.bookId == book.id }
        saveBooks()
        saveSessions()
    }
    
    func getCurrentlyReadingBooks() -> [Book] {
        return books.filter { $0.isCurrentlyReading }
    }
    
    func logReadingSession(bookId: UUID, pagesRead: Int, minutes: Int? = nil, note: String? = nil) {
        let session = ReadingSession(bookId: bookId, pagesRead: pagesRead, minutes: minutes, note: note)
        sessions.append(session)
        
        // Update book progress
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            var book = books[index]
            let currentPages = book.progress?.pagesRead ?? 0
            book.progress = ReadingProgress(pagesRead: currentPages + pagesRead)
            
            if book.startedDate == nil {
                book.startedDate = Date()
            }
            
            if currentPages + pagesRead >= book.totalPages {
                book.finishedDate = Date()
                book.isCurrentlyReading = false
            }
            
            books[index] = book
        }
        
        saveSessions()
        saveBooks()
    }
    
    func getTodaysSessions() -> [ReadingSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    func getTotalPagesReadToday() -> Int {
        return getTodaysSessions().reduce(0) { $0 + $1.pagesRead }
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: booksKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
    }
    
    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([ReadingSession].self, from: data) {
            sessions = decoded
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
}
