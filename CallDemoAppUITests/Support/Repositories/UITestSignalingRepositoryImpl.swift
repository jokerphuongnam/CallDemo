import Foundation

final class UITestSignalingRepositoryImpl: SignalingRepositoryProtocol {
    private let result: UITestSignalingResult

    init(result: UITestSignalingResult) {
        self.result = result
    }

    func requestCredentials(userID: String) async throws -> SignalingCredentials {
        try await prepareResult()
        return credentials
    }

    func prepare(userID: String) async throws -> SignalingPreparation {
        try await prepareResult()
        return SignalingPreparation(
            webSocketURL: URL(string: "wss://ui-test.example/ws")!,
            credentials: credentials
        )
    }

    func connect(
        preparation: SignalingPreparation,
        userID: String,
        role: SignalingRole
    ) async throws {
        try await prepareResult()
    }

    func disconnect() {}

    private var credentials: SignalingCredentials {
        SignalingCredentials(
            token: "ui-test-token",
            expiresAtMilliseconds: 0,
            secretHash: "ui-test-secret-hash"
        )
    }

    private func prepareResult() async throws {
        if result == .failure {
            throw UITestSignalingRepositoryError.simulatedFailure
        }
    }
}
