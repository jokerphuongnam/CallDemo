import Foundation

final class DefaultSettingsUseCaseImpl: SettingsUseCaseProtocol {
    private let repository: UserSettingsRepositoryProtocol
    private let userIDManager: UserIDManagerProtocol

    init(repository: UserSettingsRepositoryProtocol, userIDManager: UserIDManagerProtocol) {
        self.repository = repository
        self.userIDManager = userIDManager
    }

    func loadSettings() -> UserSettings {
        repository.getSettings()
    }

    func saveSettings(_ settings: UserSettings) {
        repository.saveSettings(
            UserSettings(
                currentUserID: normalized(settings.currentUserID),
                partnerUserID: normalized(settings.partnerUserID)
            )
        )
    }

    func signalingIDPreview(for input: String) -> String {
        userIDManager.signalingID(from: input)
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
