enum CallPhase {
    case waitingForPeer
    case waitingForCallee
    case waitingForIncomingCall
    case ringing
    case connecting
    case connected
}
