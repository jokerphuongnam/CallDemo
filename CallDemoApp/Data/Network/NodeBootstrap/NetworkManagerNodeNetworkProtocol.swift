import NetworkManager

@RestAPIService()
protocol NetworkManagerNodeNetworkProtocol: NodeBootstrapNetworkProtocol {
    @GET("api/v1/nodes")
    func fetchNodes() async throws -> Response<NodeBootstrapResponseNetworkModel>
}
