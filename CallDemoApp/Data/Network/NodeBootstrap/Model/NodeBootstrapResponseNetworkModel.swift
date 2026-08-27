struct NodeBootstrapResponseNetworkModel: Decodable, Sendable {
    let nodes: [NodeNetworkModel]
}

struct NodeNetworkModel: Decodable, Sendable {
    let role: String?
    let nodeId: String
    let wsUrl: String?
}
