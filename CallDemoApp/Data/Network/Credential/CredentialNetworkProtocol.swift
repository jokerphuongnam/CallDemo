import NetworkManager

protocol CredentialNetworkProtocol: Sendable {
    func fetchCredentials(
        body: CredentialRequestNetworkModel
    ) async throws -> Response<CredentialResponseNetworkModel>
}
