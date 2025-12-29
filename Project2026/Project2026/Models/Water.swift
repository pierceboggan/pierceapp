import Foundation

struct WaterLog: Codable, Identifiable {
    let id: UUID
    let date: Date
    var entries: [WaterEntry]
    
    var totalOunces: Int {
        entries.reduce(0) { $0 + $1.ounces }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), entries: [WaterEntry] = []) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

struct WaterEntry: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let ounces: Int
    
    init(id: UUID = UUID(), timestamp: Date = Date(), ounces: Int) {
        self.id = id
        self.timestamp = timestamp
        self.ounces = ounces
    }
}
