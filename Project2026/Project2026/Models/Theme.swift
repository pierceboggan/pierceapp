import SwiftUI

struct Theme: Codable, Identifiable {
    let id: UUID
    var name: String
    var primaryColor: String
    var accentColor: String
    var backgroundColor: String
    var cardColor: String
    var positiveColor: String
    var warningColor: String
    
    init(
        id: UUID = UUID(),
        name: String,
        primaryColor: String,
        accentColor: String,
        backgroundColor: String,
        cardColor: String,
        positiveColor: String,
        warningColor: String
    ) {
        self.id = id
        self.name = name
        self.primaryColor = primaryColor
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.cardColor = cardColor
        self.positiveColor = positiveColor
        self.warningColor = warningColor
    }
    
    static let defaultTheme = Theme(
        name: "Default",
        primaryColor: "0066CC",
        accentColor: "FF6B35",
        backgroundColor: "F5F5F5",
        cardColor: "FFFFFF",
        positiveColor: "34C759",
        warningColor: "FF3B30"
    )
}
