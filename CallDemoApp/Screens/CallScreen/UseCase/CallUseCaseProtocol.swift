protocol CallUseCaseProtocol {
    var hasCurrentUserID: Bool { get }
    var canStartOutgoingCall: Bool { get }
    var currentDisplayID: String { get }
    var partnerDisplayID: String { get }

    func prepareSignaling() async throws -> SignalingPreparation
    func startOutgoingCall() -> ActiveCall?
    func makeIncomingCall(from peerName: String) -> ActiveCall?
    func answer(_ call: ActiveCall) -> ActiveCall
    func endCall()
}
