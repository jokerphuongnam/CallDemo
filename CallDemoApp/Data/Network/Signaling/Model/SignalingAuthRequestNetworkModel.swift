struct SignalingAuthRequestNetworkModel: Encodable {
    let token: String
    let addr: String
    let type = "auth"
}
