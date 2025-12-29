//
//  WaterTrackingTests.swift
//  Project2026Tests
//
//  Tests for water tracking logic
//

import XCTest
@testable import Project2026

final class WaterTrackingTests: XCTestCase {
    
    // MARK: - Water Log Tests
    
    func testWaterLogTotalOunces() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 16),
            WaterEntry(amount: 8),
            WaterEntry(amount: 24)
        ]
        
        XCTAssertEqual(log.totalOunces, 48)
    }
    
    func testWaterLogProgress() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 50)
        ]
        
        XCTAssertEqual(log.progress, 0.5, accuracy: 0.01)
    }
    
    func testWaterLogProgressCappedAt1() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 120)
        ]
        
        XCTAssertEqual(log.progress, 1.0, "Progress should cap at 100%")
    }
    
    func testWaterLogRemainingOunces() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 40)
        ]
        
        XCTAssertEqual(log.remainingOunces, 60)
    }
    
    func testWaterLogRemainingOuncesNeverNegative() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 150)
        ]
        
        XCTAssertEqual(log.remainingOunces, 0, "Remaining should never be negative")
    }
    
    func testWaterLogIsComplete() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 100)
        ]
        
        XCTAssertTrue(log.isComplete)
    }
    
    func testWaterLogNotCompleteWhenBelowTarget() {
        var log = WaterLog(date: Date(), targetOunces: 100)
        log.entries = [
            WaterEntry(amount: 99)
        ]
        
        XCTAssertFalse(log.isComplete)
    }
    
    // MARK: - Quick Add Tests
    
    func testQuickAddValues() {
        XCTAssertEqual(WaterQuickAdd.small.ounces, 8)
        XCTAssertEqual(WaterQuickAdd.medium.ounces, 16)
        XCTAssertEqual(WaterQuickAdd.large.ounces, 24)
        XCTAssertEqual(WaterQuickAdd.bottle.ounces, 32)
    }
    
    func testQuickAddDisplayText() {
        XCTAssertEqual(WaterQuickAdd.small.displayText, "8oz")
        XCTAssertEqual(WaterQuickAdd.medium.displayText, "16oz")
        XCTAssertEqual(WaterQuickAdd.large.displayText, "24oz")
        XCTAssertEqual(WaterQuickAdd.bottle.displayText, "32oz")
    }
}
