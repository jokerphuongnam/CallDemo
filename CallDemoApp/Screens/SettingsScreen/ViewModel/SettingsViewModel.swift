import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let useCase: SettingsUseCaseProtocol
    private let logger: AppLoggerProtocol

    var currentUserID = ""
    var partnerUserID = ""

    init(useCase: SettingsUseCaseProtocol, logger: AppLoggerProtocol) {
        self.useCase = useCase
        self.logger = logger
        let settings = useCase.loadSettings()
        currentUserID = settings.currentUserID
        partnerUserID = settings.partnerUserID
    }

    var canSave: Bool {
        !currentUserID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var signalingUserIDPreview: String {
        canSave ? useCase.signalingIDPreview(for: currentUserID) : ""
    }

    var partnerSignalingIDPreview: String {
        partnerUserID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? ""
            : useCase.signalingIDPreview(for: partnerUserID)
    }

    func save() {
        logger.info("[Settings] Save tapped")
        useCase.saveSettings(
            UserSettings(currentUserID: currentUserID, partnerUserID: partnerUserID)
        )
        logger.info("[Settings] Settings saved; partner configured: \(!partnerUserID.isEmpty)")
    }
}
