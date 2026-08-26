final class DefaultCallManagerImpl: CallManagerProtocol {
    func startCall(
        from localUserID: String,
        to peerUserID: String,
        peerDisplayID: String
    ) -> ActiveCall {
        ActiveCall(
            localUserID: localUserID,
            peerName: peerDisplayID,
            direction: .outgoing,
            phase: .waitingForPeer
        )
    }

    func receiveCall(
        for localUserID: String,
        from peerName: String
    ) -> ActiveCall {
        ActiveCall(
            localUserID: localUserID,
            peerName: peerName,
            direction: .incoming,
            phase: .waitingForPeer
        )
    }

    func answer(
        _ call: ActiveCall
    ) -> ActiveCall {
        var connectedCall = call
        connectedCall.phase = .connecting
        return connectedCall
    }

    func endCall() {}
}
