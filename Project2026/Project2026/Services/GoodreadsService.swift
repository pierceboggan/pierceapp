import Foundation

class GoodreadsService: ObservableObject {
    @Published var account: GoodreadsAccount?
    @Published var isConnected: Bool = false
    
    private let accountKey = "goodreadsAccount"
    
    init() {
        loadAccount()
    }
    
    func connect(userId: String, accessToken: String) {
        let newAccount = GoodreadsAccount(userId: userId, accessToken: accessToken)
        account = newAccount
        isConnected = true
        saveAccount()
    }
    
    func disconnect() {
        account = nil
        isConnected = false
        UserDefaults.standard.removeObject(forKey: accountKey)
    }
    
    func syncWithGoodreads() async throws {
        guard let account = account else {
            throw GoodreadsError.notConnected
        }
        
        // TODO: Implement actual Goodreads API integration
        // This is a placeholder for the OAuth flow and API calls
        
        var updatedAccount = account
        updatedAccount.lastSyncDate = Date()
        self.account = updatedAccount
        saveAccount()
    }
    
    private func loadAccount() {
        if let data = UserDefaults.standard.data(forKey: accountKey),
           let decoded = try? JSONDecoder().decode(GoodreadsAccount.self, from: data) {
            account = decoded
            isConnected = decoded.isConnected
        }
    }
    
    private func saveAccount() {
        if let encoded = try? JSONEncoder().encode(account) {
            UserDefaults.standard.set(encoded, forKey: accountKey)
        }
    }
}

enum GoodreadsError: Error {
    case notConnected
    case syncFailed
    case invalidCredentials
}
