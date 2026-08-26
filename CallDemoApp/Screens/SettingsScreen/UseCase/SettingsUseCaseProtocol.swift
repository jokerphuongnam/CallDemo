protocol SettingsUseCaseProtocol {
    func loadSettings() -> UserSettings
    func saveSettings(_ settings: UserSettings)
    func signalingIDPreview(for input: String) -> String
}
