import Foundation
import Observation
import ScreenViewModel

enum CallAction: ScreenAction {
    case refreshSettings
    case startCall
    case receiveCall
    case answer
    case remoteAnswer
    case endCall
    case socketReady(UUID, SignalingRole)
    case socketFailed(String)
    case webrtcConnected(UUID)
}

@MainActor
@Observable
final class CallViewModel: ScreenModel<CallAction> {
    private let useCase: CallUseCaseProtocol
    private let logger: AppLoggerProtocol

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
        super.init()
        send(.refreshSettings)
    }

    var statusText: String {
        guard hasCurrentUserID else { return "Vào Settings để nhập ID hiện tại" }
        return activeCall == nil ? "Sẵn sàng với ID: \(displayUserID)" : "Đang có cuộc gọi"
    }

    override func observable(action: CallAction, cancel: Cancel) -> Effect<CallAction> {
        switch action {
        case .refreshSettings:
            return refreshSettings(cancel: cancel)
        case .startCall:
            return startCall()
        case .receiveCall:
            return receiveCall()
        case .answer:
            return answer()
        case .remoteAnswer:
            return remoteAnswer()
        case .endCall:
            return endCall(cancel: cancel)
        case .socketReady(let callID, let role):
            markSocketAuthenticated(callID: callID, role: role)
            return .none
        case .socketFailed(let error):
            logger.info("[Signaling] Preparation or WebSocket connection failed: \(error)")
            activeCall = nil
            return .none
        case .webrtcConnected(let callID):
            markWebRTCConnected(callID: callID)
            return .none
        }
    }

    private func refreshSettings(cancel: Cancel) -> Effect<CallAction> {
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
            cancel("signaling")
            useCase.disconnectSignaling()
        }
        logger.info("[Call] Settings refreshed")
        return .none
    }

    private func startCall() -> Effect<CallAction> {
        logger.info("[Call] Start call tapped")
        guard canUseCallActions else {
            logger.info("[Call] Start call rejected: missing current or partner ID")
            return .none
        }
        activeCall = useCase.startOutgoingCall()
        logger.info(
            activeCall == nil
                ? "[Call] Start call rejected: missing current or partner ID"
                : "[Call] Outgoing call created"
        )
        guard let callID = activeCall?.id else { return .none }
        return signalingTask(role: .caller, callID: callID)
    }

    private func receiveCall() -> Effect<CallAction> {
        logger.info("[Call] Receive call tapped")
        guard canReceiveCall else {
            logger.info("[Call] Incoming call rejected: missing current ID")
            return .none
        }
        let peerName = partnerDisplayUserID.isEmpty ? "Partner" : partnerDisplayUserID
        activeCall = useCase.makeIncomingCall(from: peerName)
        guard let callID = activeCall?.id else {
            logger.info("[Call] Incoming call rejected: missing current ID")
            return .none
        }
        return signalingTask(role: .callee, callID: callID)
    }

    private func answer() -> Effect<CallAction> {
        logger.info("[Call] Answer tapped")
        guard let activeCall else {
            logger.info("[Call] Answer ignored: no active call")
            return .none
        }
        self.activeCall = useCase.answer(activeCall)
        logger.info("[Call] WebRTC connection started")
        return webrtcTask(callID: activeCall.id)
    }

    private func remoteAnswer() -> Effect<CallAction> {
        logger.info("[Call] Remote answer event received")
        guard
            let activeCall,
            activeCall.direction == .outgoing,
            activeCall.phase == .ringing
        else {
            logger.info("[Call] Remote answer ignored: outgoing call is not ringing")
            return .none
        }
        self.activeCall?.phase = .connecting
        return webrtcTask(callID: activeCall.id)
    }

    private func endCall(cancel: Cancel) -> Effect<CallAction> {
        logger.info("[Call] End call tapped")
        cancel("signaling")
        cancel("webrtc")
        useCase.disconnectSignaling()
        useCase.endCall()
        activeCall = nil
        logger.info("[Call] Active call cleared; call screen will dismiss")
        return .none
    }

    private func signalingTask(role: SignalingRole, callID: UUID) -> Effect<CallAction> {
        let useCase = useCase
        logger.info("[Signaling] Preparing connection information for \(role)")
        return .task(.userInitiated, id: "signaling") { send in
            do {
                try await useCase.joinSignaling(as: role)
                guard !Task.isCancelled else { return }
                send(.socketReady(callID, role))
            } catch {
                guard !Task.isCancelled else { return }
                send(.socketFailed(String(describing: error)))
            }
        }
    }

    private func webrtcTask(callID: UUID) -> Effect<CallAction> {
        .task(.userInitiated, id: "webrtc") { send in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            send(.webrtcConnected(callID))
        }
    }

    private func markSocketAuthenticated(callID: UUID, role: SignalingRole) {
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
