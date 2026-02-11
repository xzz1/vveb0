import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var isLoggedIn = false
    @Published private(set) var displayName = "游客"
    @Published private(set) var handle = "@guest"

    func login(displayName: String = "小林", handle: String = "@xzz1") {
        self.displayName = displayName
        self.handle = handle
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        displayName = "游客"
        handle = "@guest"
    }

    func login(phone: String) {
        let suffix = String(phone.suffix(4))
        displayName = "用户\(suffix)"
        handle = "@\(phone)"
        isLoggedIn = true
    }
}
