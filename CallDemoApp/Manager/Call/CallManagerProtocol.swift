protocol CallManagerProtocol: AnyObject {
    func startCall(from localUserID: String, to peerUserID: String, peerDisplayID: String) -> ActiveCall
    func receiveCall(for localUserID: String, from peerName: String) -> ActiveCall
    func answer(_ call: ActiveCall) -> ActiveCall
    func endCall()
}
