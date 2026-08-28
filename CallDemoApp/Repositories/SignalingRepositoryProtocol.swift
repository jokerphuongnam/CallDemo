protocol SignalingRepositoryProtocol {
    func requestCredentials(userID: String) async throws -> SignalingCredentials
    func prepare(userID: String) async throws -> SignalingPreparation
    func connect(
        preparation: SignalingPreparation,
        userID: String,
        role: SignalingRole
    ) async throws
    func disconnect()
}
