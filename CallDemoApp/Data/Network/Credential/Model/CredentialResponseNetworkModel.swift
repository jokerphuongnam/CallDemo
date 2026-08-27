struct CredentialResponseNetworkModel: Decodable, Sendable {
    let token: String
    let expiresAtMilliseconds: Int64
    let secretHash: String

    private enum CodingKeys: String, CodingKey {
        case token
        case privateToken
        case expiresAtMs
        case secretHash
        case secretHashSnake = "secret_hash"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token =
            try container.decodeIfPresent(String.self, forKey: .privateToken)
            ?? container.decode(String.self, forKey: .token)

        if let value = try? container.decode(Int64.self, forKey: .expiresAtMs) {
            expiresAtMilliseconds = value
        } else {
            let value = try container.decode(String.self, forKey: .expiresAtMs)
            guard let milliseconds = Int64(value) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .expiresAtMs,
                    in: container,
                    debugDescription: "expiresAtMs must be Unix milliseconds"
                )
            }
            expiresAtMilliseconds = milliseconds
        }

        secretHash =
            try container.decodeIfPresent(String.self, forKey: .secretHash)
            ?? container.decode(String.self, forKey: .secretHashSnake)
    }
}
