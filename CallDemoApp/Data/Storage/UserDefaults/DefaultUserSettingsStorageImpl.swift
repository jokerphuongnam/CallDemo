import Foundation

final class DefaultUserSettingsStorageImpl: UserSettingsStorageProtocol {
    private enum Key {
        static let currentUserID = "currentUserID"
        static let partnerUserID = "partnerUserID"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func load() -> UserSettingsStorageModel {
        UserSettingsStorageModel(
            currentUserID: userDefaults.string(forKey: Key.currentUserID) ?? "",
            partnerUserID: userDefaults.string(forKey: Key.partnerUserID) ?? ""
        )
    }

    func save(_ model: UserSettingsStorageModel) {
        userDefaults.set(model.currentUserID, forKey: Key.currentUserID)
        userDefaults.set(model.partnerUserID, forKey: Key.partnerUserID)
    }
}
