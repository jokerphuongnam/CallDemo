import Foundation

final class DefaultCallUseCaseImpl: CallUseCaseProtocol {
    private let repository: UserSettingsRepositoryProtocol
    private let signalingRepository: SignalingRepositoryProtocol
    private let callManager: CallManagerProtocol
    private let userIDManager: UserIDManagerProtocol

    init(
        repository: UserSettingsRepositoryProtocol,
        signalingRepository: SignalingRepositoryProtocol,
        callManager: CallManagerProtocol,
        userIDManager: UserIDManagerProtocol
    ) {
        self.repository = repository
        self.signalingRepository = signalingRepository
        self.callManager = callManager
        self.userIDManager = userIDManager
    }

    var hasCurrentUserID: Bool {
        !settings.currentUserID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canStartOutgoingCall: Bool {
        hasCurrentUserID
        && !settings.partnerUserID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var currentDisplayID: String {
        userIDManager.displayID(from: settings.currentUserID)
    }

    var partnerDisplayID: String {
        userIDManager.displayID(from: settings.partnerUserID)
    }

    func prepareSignaling() async throws -> SignalingPreparation {
        let currentUserID = userIDManager.signalingID(from: settings.currentUserID)
        return try await signalingRepository.prepare(userID: currentUserID)
    }

    func startOutgoingCall() -> ActiveCall? {
        guard canStartOutgoingCall else { return nil }
        let settings = settings
        return callManager.startCall(
            from: userIDManager.signalingID(from: settings.currentUserID),
            to: userIDManager.signalingID(from: settings.partnerUserID),
            peerDisplayID: userIDManager.displayID(from: settings.partnerUserID)
        )
    }

    func makeIncomingCall(from peerName: String) -> ActiveCall? {
        guard hasCurrentUserID else { return nil }
        return callManager.receiveCall(
            for: userIDManager.signalingID(from: settings.currentUserID),
            from: peerName
        )
    }

    func answer(_ call: ActiveCall) -> ActiveCall {
        callManager.answer(call)
    }

    func endCall() {
        callManager.endCall()
    }

    private var settings: UserSettings {
        repository.getSettings()
    }
}
