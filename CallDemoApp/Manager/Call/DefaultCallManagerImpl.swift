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
            phase: .connecting
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
            phase: .ringing
        )
    }

    func answer(
        _ call: ActiveCall
    ) -> ActiveCall {
        var connectedCall = call
        connectedCall.phase = .connected
        return connectedCall
    }

    func endCall() {}
}
