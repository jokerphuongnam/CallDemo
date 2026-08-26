protocol UserSettingsRepositoryProtocol {
    func getSettings() -> UserSettings
    func saveSettings(_ settings: UserSettings)
}
