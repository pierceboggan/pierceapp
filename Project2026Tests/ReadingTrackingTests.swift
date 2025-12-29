//
//  ReadingTrackingTests.swift
//  Project2026Tests
//
//  Tests for reading tracking logic
//

import XCTest
@testable import Project2026

final class ReadingTrackingTests: XCTestCase {
    
    // MARK: - Book Progress Tests
    
    func testBookProgressPercentage() {
        let book = Book(
            title: "Test Book",
            author: "Test Author",
            totalPages: 300,
            currentPage: 150
        )
        
        XCTAssertEqual(book.progressPercentage, 50)
    }
    
    func testBookProgressFraction() {
        let book = Book(
            title: "Test Book",
            author: "Test Author",
            totalPages: 200,
            currentPage: 50
        )
        
        XCTAssertEqual(book.progress, 0.25, accuracy: 0.01)
    }
    
    func testBookPagesRemaining() {
        let book = Book(
            title: "Test Book",
            author: "Test Author",
            totalPages: 400,
            currentPage: 100
        )
        
        XCTAssertEqual(book.pagesRemaining, 300)
    }
    
    func testBookIsCompleteWhenAtEnd() {
        let book = Book(
            title: "Test Book",
            author: "Test Author",
            totalPages: 200,
            currentPage: 200
        )
        
        XCTAssertTrue(book.isComplete)
    }
    
    func testBookNotCompleteWhenInProgress() {
        let book = Book(
            title: "Test Book",
            author: "Test Author",
            totalPages: 200,
            currentPage: 199
        )
        
        XCTAssertFalse(book.isComplete)
    }
    
    // MARK: - Book Status Tests
    
    func testBookStatusIcons() {
        XCTAssertEqual(BookStatus.wantToRead.icon, "bookmark")
        XCTAssertEqual(BookStatus.currentlyReading.icon, "book.fill")
        XCTAssertEqual(BookStatus.finished.icon, "checkmark.circle.fill")
    }
    
    // MARK: - Reading Session Tests
    
    func testReadingSessionDefaults() {
        let session = ReadingSession(
            bookId: UUID(),
            pagesRead: 20
        )
        
        XCTAssertEqual(session.pagesRead, 20)
        XCTAssertNil(session.durationMinutes)
        XCTAssertNil(session.note)
    }
    
    func testReadingSessionWithDuration() {
        let session = ReadingSession(
            bookId: UUID(),
            pagesRead: 30,
            durationMinutes: 45
        )
        
        XCTAssertEqual(session.pagesRead, 30)
        XCTAssertEqual(session.durationMinutes, 45)
    }
    
    func testReadingSessionDate() {
        let session = ReadingSession(
            bookId: UUID(),
            pagesRead: 10
        )
        
        // Session date should be today
        XCTAssertEqual(
            Calendar.current.startOfDay(for: session.date),
            Calendar.current.startOfDay(for: Date())
        )
    }
    
    // MARK: - Goodreads Account Tests
    
    func testGoodreadsAccountDefaultNotConnected() {
        let account = GoodreadsAccount()
        
        XCTAssertFalse(account.isConnected)
        XCTAssertNil(account.userId)
        XCTAssertNil(account.accessToken)
    }
    
    func testGoodreadsAccountConnectedWhenHasCredentials() {
        var account = GoodreadsAccount()
        account.userId = "123"
        account.accessToken = "token"
        
        XCTAssertTrue(account.isConnected)
    }
}
