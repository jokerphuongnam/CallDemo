import Foundation
import Observation

@MainActor
@Observable
final class CallViewModel {
    private let useCase: CallUseCaseProtocol
    private let logger: AppLoggerProtocol
    @ObservationIgnored private let callProgressCancelBag = CancelBag()
    @ObservationIgnored private let signalingCancelBag = CancelBag()

    var activeCall: ActiveCall?
    private(set) var hasCurrentUserID = false
    private(set) var canStartOutgoingCall = false
    private(set) var displayUserID = ""
    private(set) var partnerDisplayUserID = ""

    var canUseCallActions: Bool {
        canStartOutgoingCall
    }

    var canReceiveCall: Bool {
        hasCurrentUserID
    }

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
        let previousDisplayUserID = displayUserID
        let previousPartnerDisplayUserID = partnerDisplayUserID
        hasCurrentUserID = useCase.hasCurrentUserID
        canStartOutgoingCall = useCase.canStartOutgoingCall
        displayUserID = useCase.currentDisplayID
        partnerDisplayUserID = useCase.partnerDisplayID

        let didChangeIdentity =
            previousDisplayUserID != displayUserID
            || previousPartnerDisplayUserID != partnerDisplayUserID
        if didChangeIdentity {
            signalingCancelBag.reset()
            useCase.disconnectSignaling()
        }
        logger.info("[Call] Settings refreshed")
    }

    func startCall() {
        logger.info("[Call] Start call tapped")
        guard canUseCallActions else {
            logger.info("[Call] Start call rejected: missing current or partner ID")
            return
        }
        activeCall = useCase.startOutgoingCall()
        logger.info(
            activeCall == nil
                ? "[Call] Start call rejected: missing current or partner ID"
                : "[Call] Outgoing call created"
        )

        guard let callID = activeCall?.id else { return }
        prepareAndJoinSignaling(
            role: .caller,
            callID: callID
        )
    }

    func receiveCall() {
        logger.info("[Call] Receive call tapped")
        guard canReceiveCall else {
            logger.info("[Call] Incoming call rejected: missing current ID")
            return
        }
        let peerName = partnerDisplayUserID.isEmpty ? "Partner" : partnerDisplayUserID
        activeCall = useCase.makeIncomingCall(from: peerName)

        guard let callID = activeCall?.id else {
            logger.info("[Call] Incoming call rejected: missing current ID")
            return
        }

        prepareAndJoinSignaling(
            role: .callee,
            callID: callID
        )
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
        callProgressCancelBag.reset()
        signalingCancelBag.reset()
        useCase.disconnectSignaling()
        useCase.endCall()
        activeCall = nil
        logger.info("[Call] Active call cleared; call screen will dismiss")
    }

    private func prepareAndJoinSignaling(
        role: SignalingRole,
        callID: UUID
    ) {
        signalingCancelBag.reset()
        let useCase = useCase
        let logger = logger
        logger.info("[Signaling] Preparing connection information for \(role)")
        Task { [weak self] in
            do {
                try await useCase.joinSignaling(as: role)
                guard !Task.isCancelled else { return }
                guard let self else { return }
                markSocketAuthenticated(callID: callID, role: role)
            } catch {
                guard !Task.isCancelled else { return }
                guard let self else { return }
                logger.info("[Signaling] Preparation or WebSocket connection failed: \(error)")
                activeCall = nil
            }
        }
        .store(signalingCancelBag)
    }

    private func scheduleWebRTCConnected(callID: UUID) {
        callProgressCancelBag.reset()
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            guard let self else { return }
            markWebRTCConnected(callID: callID)
        }
        .store(callProgressCancelBag)
    }

    private func markSocketAuthenticated(
        callID: UUID,
        role: SignalingRole
    ) {
        guard activeCall?.id == callID else { return }
        if role == .caller {
            activeCall?.phase = .waitingForCallee
            logger.info("[Call] Authenticated as caller; waiting for callee")
        } else {
            activeCall?.phase = .waitingForIncomingCall
            logger.info("[Call] Authenticated as callee; waiting for incoming call")
        }
    }

    private func markWebRTCConnected(callID: UUID) {
        guard activeCall?.id == callID else { return }
        activeCall?.phase = .connected
        logger.info("[Call] WebRTC connection established")
    }
}
