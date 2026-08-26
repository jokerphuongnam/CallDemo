import Foundation

struct ActiveCall: Identifiable {
    let id = UUID()
    let localUserID: String
    let peerName: String
    let direction: CallDirection
    var phase: CallPhase
}
