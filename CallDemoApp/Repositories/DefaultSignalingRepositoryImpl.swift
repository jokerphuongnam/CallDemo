import Blake2
import Foundation

final class DefaultSignalingRepositoryImpl: SignalingRepositoryProtocol {
    private let credentialNetwork: CredentialNetworkProtocol
    private let nodeBootstrapNetwork: NodeBootstrapNetworkProtocol
    private let webSocketNetwork: SignalingWebSocketNetworkProtocol

    init(
        credentialNetwork: CredentialNetworkProtocol,
        nodeBootstrapNetwork: NodeBootstrapNetworkProtocol,
        webSocketNetwork: SignalingWebSocketNetworkProtocol
    ) {
        self.credentialNetwork = credentialNetwork
        self.nodeBootstrapNetwork = nodeBootstrapNetwork
        self.webSocketNetwork = webSocketNetwork
    }

    func requestCredentials(userID: String) async throws -> SignalingCredentials {
        let networkResponse = try await credentialNetwork.fetchCredentials(
            body: CredentialRequestNetworkModel(userId: userID)
        )
        let response = networkResponse.data
        return SignalingCredentials(
            token: response.token,
            expiresAtMilliseconds: response.expiresAtMilliseconds,
            secretHash: response.secretHash
        )
    }

    func prepare(userID: String) async throws -> SignalingPreparation {
        let credentials = try await requestCredentials(userID: userID)
        let nodeResponse = try await nodeBootstrapNetwork.fetchNodes()
        let nodes = nodeResponse.data
        let webSocketURL = try entryWebSocketURL(from: nodes)
        return SignalingPreparation(
            webSocketURL: webSocketURL,
            credentials: credentials
        )
    }

    func connect(
        preparation: SignalingPreparation,
        userID: String,
        role: SignalingRole
    ) async throws {
        let address = try signalingAddress(for: userID)
        try await webSocketNetwork.connect(
            to: preparation.webSocketURL,
            authRequest: SignalingAuthRequestNetworkModel(
                token: preparation.credentials.token,
                addr: address
            ),
            role: role
        )
    }

    func disconnect() {
        webSocketNetwork.disconnect()
    }

    private func signalingAddress(for userID: String) throws -> String {
        let normalizedUserID = userID.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = try Blake2b.hash(size: 20, data: Data(normalizedUserID.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func entryWebSocketURL(
        from payload: NodeBootstrapResponseNetworkModel
    ) throws -> URL {
        let entryURLs = payload.nodes
            .filter { $0.role?.caseInsensitiveCompare("Entry") == .orderedSame }
            .compactMap(\.wsUrl)
            .compactMap(URL.init(string:))
            .filter { $0.scheme?.lowercased() == "wss" }

        guard let webSocketURL = entryURLs.randomElement() else {
            throw NodeBootstrapNetworkError.missingEntryWebSocketURL
        }

#if DEBUG
        print("[Signaling][Nodes][Selected WebSocket URL] \(webSocketURL.absoluteString)")
#endif

        return webSocketURL
    }
}
