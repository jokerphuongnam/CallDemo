final class DefaultUserSettingsRepositoryImpl: UserSettingsRepositoryProtocol {
    private let storage: UserSettingsStorageProtocol

    init(storage: UserSettingsStorageProtocol) {
        self.storage = storage
    }

    func getSettings() -> UserSettings {
        let storageModel = storage.load()
        return UserSettings(
            currentUserID: storageModel.currentUserID,
            partnerUserID: storageModel.partnerUserID
        )
    }

    func saveSettings(_ settings: UserSettings) {
        storage.save(UserSettingsStorageModel(
            currentUserID: settings.currentUserID,
            partnerUserID: settings.partnerUserID
        ))
    }
}
