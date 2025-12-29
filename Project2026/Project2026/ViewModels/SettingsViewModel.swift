import Foundation

class SettingsViewModel: ObservableObject {
    @Published var waterTarget: Int = 100
    @Published var currentTheme: Theme
    @Published var isGoodreadsConnected: Bool = false
    
    private let themeService: ThemeService
    private let goodreadsService: GoodreadsService
    
    init(
        themeService: ThemeService = ThemeService(),
        goodreadsService: GoodreadsService = GoodreadsService()
    ) {
        self.themeService = themeService
        self.goodreadsService = goodreadsService
        self.currentTheme = themeService.currentTheme
        self.isGoodreadsConnected = goodreadsService.isConnected
    }
    
    func updateWaterTarget(_ target: Int) {
        waterTarget = target
        UserDefaults.standard.set(target, forKey: "waterTarget")
    }
    
    func setTheme(_ theme: Theme) {
        themeService.setTheme(theme)
        currentTheme = theme
    }
}
