import Observation
import ScreenViewModel

enum SettingsAction: ScreenAction {
    case save
}

@MainActor
@Observable
final class SettingsViewModel: ScreenModel<SettingsAction> {
    private let useCase: SettingsUseCaseProtocol
    private let logger: AppLoggerProtocol

    var currentUserID = ""
    var partnerUserID = ""

    init(useCase: SettingsUseCaseProtocol, logger: AppLoggerProtocol) {
        self.useCase = useCase
        self.logger = logger
        super.init()
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

    override func observable(action: SettingsAction, cancel _: Cancel) -> Effect<SettingsAction> {
        switch action {
        case .save:
            logger.info("[Settings] Save tapped")
            useCase.saveSettings(
                UserSettings(currentUserID: currentUserID, partnerUserID: partnerUserID)
            )
            logger.info("[Settings] Settings saved; partner configured: \(!partnerUserID.isEmpty)")
            return .none
        }
    }
}
