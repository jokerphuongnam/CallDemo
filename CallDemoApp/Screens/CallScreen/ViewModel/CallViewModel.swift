import Foundation
import Observation

@MainActor
@Observable
final class CallViewModel {
    private let useCase: CallUseCaseProtocol
    private let logger: AppLoggerProtocol
    @ObservationIgnored private var callProgressTask: Task<Void, Never>?

    var activeCall: ActiveCall?
    private(set) var hasCurrentUserID = false
    private(set) var canStartOutgoingCall = false
    private(set) var displayUserID = ""
    private(set) var partnerDisplayUserID = ""

    init(useCase: CallUseCaseProtocol, logger: AppLoggerProtocol) {
        self.useCase = useCase
        self.logger = logger
        refreshSettings()
    }

    var statusText: String {
        guard hasCurrentUserID else { return "Vào Settings để nhập ID hiện tại" }
        return activeCall == nil ? "Sẵn sàng với ID: \(displayUserID)" : "Đang có cuộc gọi"
    }

    func refreshSettings() {
        hasCurrentUserID = useCase.hasCurrentUserID
        canStartOutgoingCall = useCase.canStartOutgoingCall
        displayUserID = useCase.currentDisplayID
        partnerDisplayUserID = useCase.partnerDisplayID
        logger.info("[Call] Settings refreshed")
    }

    func startCall() {
        logger.info("[Call] Start call tapped")
        activeCall = useCase.startOutgoingCall()
        logger.info(
            activeCall == nil
                ? "[Call] Start call rejected: missing current or partner ID"
                : "[Call] Outgoing call created"
        )

        guard let callID = activeCall?.id else { return }
        scheduleSignalingReady(callID: callID)
    }

    func receiveCall() {
        logger.info("[Call] Simulate incoming call tapped")
        let peerName = partnerDisplayUserID.isEmpty ? "Partner" : partnerDisplayUserID
        activeCall = useCase.makeIncomingCall(from: peerName)

        guard let callID = activeCall?.id else {
            logger.info("[Call] Incoming call rejected: missing current ID")
            return
        }

        logger.info("[Call] Waiting for simulated partner to join signaling")
        scheduleSignalingReady(callID: callID)
    }

    func answerCall() {
        logger.info("[Call] Answer tapped")
        guard let activeCall else {
            logger.info("[Call] Answer ignored: no active call")
            return
        }
        self.activeCall = useCase.answer(activeCall)
        logger.info("[Call] WebRTC connection started")
        scheduleWebRTCConnected(callID: activeCall.id)
    }

    func handleRemoteAnswer() {
        logger.info("[Call] Remote answer event received")
        guard
            let activeCall,
            activeCall.direction == .outgoing,
            activeCall.phase == .ringing
        else {
            logger.info("[Call] Remote answer ignored: outgoing call is not ringing")
            return
        }

        self.activeCall?.phase = .connecting
        scheduleWebRTCConnected(callID: activeCall.id)
    }

    func endCall() {
        logger.info("[Call] End call tapped")
        callProgressTask?.cancel()
        useCase.endCall()
        activeCall = nil
        logger.info("[Call] Active call cleared; call screen will dismiss")
    }

    private func scheduleSignalingReady(callID: UUID) {
        callProgressTask?.cancel()
        callProgressTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.markSignalingReady(callID: callID)
        }
    }

    private func scheduleWebRTCConnected(callID: UUID) {
        callProgressTask?.cancel()
        callProgressTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.markWebRTCConnected(callID: callID)
        }
    }

    private func markSignalingReady(callID: UUID) {
        guard activeCall?.id == callID else { return }
        activeCall?.phase = .ringing
        logger.info("[Call] Signaling ready; call is ringing")
    }

    private func markWebRTCConnected(callID: UUID) {
        guard activeCall?.id == callID else { return }
        activeCall?.phase = .connected
        logger.info("[Call] WebRTC connection established")
    }
}
