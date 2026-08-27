import NetworkManager

@RestAPIService()
protocol NetworkManagerCredentialNetworkProtocol: CredentialNetworkProtocol {
    @POST("api/v1/token")
    func fetchCredentials(
        body: CredentialRequestNetworkModel
    ) async throws -> Response<CredentialResponseNetworkModel>
}
