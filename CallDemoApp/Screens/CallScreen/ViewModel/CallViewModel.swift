import Observation

@MainActor
@Observable
final class CallViewModel {
    private let useCase: CallUseCaseProtocol
    private let logger: AppLoggerProtocol

    var activeCall: ActiveCall?

    init(useCase: CallUseCaseProtocol, logger: AppLoggerProtocol) {
        self.useCase = useCase
        self.logger = logger
    }

    var hasCurrentUserID: Bool { useCase.hasCurrentUserID }
    var canStartOutgoingCall: Bool { useCase.canStartOutgoingCall }
    var displayUserID: String { useCase.currentDisplayID }
    var partnerDisplayUserID: String { useCase.partnerDisplayID }

    var statusText: String {
        guard hasCurrentUserID else { return "Vào Settings để nhập ID hiện tại" }
        return activeCall == nil ? "Sẵn sàng với ID: \(displayUserID)" : "Đang có cuộc gọi"
    }

    func startCall() {
        logger.info("[Call] Start call tapped")
        activeCall = useCase.startOutgoingCall()
        logger.info(
            activeCall == nil
                ? "[Call] Start call rejected: missing current or partner ID"
                : "[Call] Outgoing call created"
        )
    }

    func receiveCall(from peerName: String) {
        logger.info("[Call] Simulate incoming call tapped")
        activeCall = useCase.makeIncomingCall(from: peerName)
        logger.info(
            activeCall == nil
                ? "[Call] Incoming call rejected: missing current ID"
                : "[Call] Incoming call created from \(peerName)"
        )
    }

    func answerCall() {
        logger.info("[Call] Answer tapped")
        guard let activeCall else {
            logger.info("[Call] Answer ignored: no active call")
            return
        }
        self.activeCall = useCase.answer(activeCall)
        logger.info("[Call] Call phase changed to connected")
    }

    func endCall() {
        logger.info("[Call] End call tapped")
        useCase.endCall()
        activeCall = nil
        logger.info("[Call] Active call cleared; call screen will dismiss")
    }
}
