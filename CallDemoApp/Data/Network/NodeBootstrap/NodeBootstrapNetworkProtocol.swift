import NetworkManager

protocol NodeBootstrapNetworkProtocol: Sendable {
    func fetchNodes() async throws -> Response<NodeBootstrapResponseNetworkModel>
}
