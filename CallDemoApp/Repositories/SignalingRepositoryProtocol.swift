protocol SignalingRepositoryProtocol {
    func requestCredentials(userID: String) async throws -> SignalingCredentials
    func prepare(userID: String) async throws -> SignalingPreparation
}
