protocol UserSettingsStorageProtocol {
    func load() -> UserSettingsStorageModel
    func save(_ model: UserSettingsStorageModel)
}
