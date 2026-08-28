import Foundation

protocol SignalingWebSocketNetworkProtocol: AnyObject {
    var rawMessages: AsyncStream<String> { get }

    func connect(
        to url: URL,
        authRequest: SignalingAuthRequestNetworkModel,
        role: SignalingRole
    ) async throws
    func disconnect()
}
