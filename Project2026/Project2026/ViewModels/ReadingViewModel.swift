import Foundation

class ReadingViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var currentBooks: [Book] = []
    @Published var sessions: [ReadingSession] = []
    @Published var todaysSessions: [ReadingSession] = []
    
    private let readingService: ReadingService
    private let goodreadsService: GoodreadsService
    
    init(
        readingService: ReadingService = ReadingService(),
        goodreadsService: GoodreadsService = GoodreadsService()
    ) {
        self.readingService = readingService
        self.goodreadsService = goodreadsService
        loadData()
    }
    
    func loadData() {
        books = readingService.books
        currentBooks = readingService.getCurrentlyReadingBooks()
        sessions = readingService.sessions
        todaysSessions = readingService.getTodaysSessions()
    }
    
    func addBook(title: String, author: String, totalPages: Int, coverImageURL: String? = nil) {
        let book = Book(
            title: title,
            author: author,
            totalPages: totalPages,
            coverImageURL: coverImageURL,
            isCurrentlyReading: true,
            startedDate: Date(),
            progress: ReadingProgress(pagesRead: 0)
        )
        readingService.addBook(book)
        loadData()
    }
    
    func logReading(bookId: UUID, pagesRead: Int, minutes: Int? = nil, note: String? = nil) {
        readingService.logReadingSession(bookId: bookId, pagesRead: pagesRead, minutes: minutes, note: note)
        loadData()
    }
    
    func updateBook(_ book: Book) {
        readingService.updateBook(book)
        loadData()
    }
    
    func deleteBook(_ book: Book) {
        readingService.deleteBook(book)
        loadData()
    }
    
    func connectGoodreads(userId: String, accessToken: String) {
        goodreadsService.connect(userId: userId, accessToken: accessToken)
    }
    
    func disconnectGoodreads() {
        goodreadsService.disconnect()
    }
    
    func syncGoodreads() async {
        do {
            try await goodreadsService.syncWithGoodreads()
            loadData()
        } catch {
            print("Failed to sync with Goodreads: \(error)")
        }
    }
}
