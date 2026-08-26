import Foundation

struct DefaultUserIDManagerImpl: UserIDManagerProtocol {
    private let domain: String
    private let userIDPrefix: String

    init() {
        domain = Bundle.main.configurationValue(for: .serverDomain)
        userIDPrefix = Bundle.main.configurationValue(for: .userIDPrefix)
    }

    func displayID(from input: String) -> String {
        "\(userIDPrefix)\(localPart(from: input))"
    }

    func signalingID(from input: String) -> String {
        "\(userIDPrefix)\(localPart(from: input)):\(domain)"
    }

    private func localPart(from input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: userIDPrefix))
    }
}
