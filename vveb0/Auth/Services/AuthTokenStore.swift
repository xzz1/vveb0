import Foundation

protocol AuthTokenStoreProtocol: AnyObject {
    var accessToken: String? { get set }
}

final class UserDefaultsTokenStore: AuthTokenStoreProtocol {
    private enum Keys {
        static let accessToken = "vveb0_access_token"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var accessToken: String? {
        get { defaults.string(forKey: Keys.accessToken) }
        set {
            let value = newValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let value, !value.isEmpty {
                defaults.set(value, forKey: Keys.accessToken)
            } else {
                defaults.removeObject(forKey: Keys.accessToken)
            }
        }
    }
}
