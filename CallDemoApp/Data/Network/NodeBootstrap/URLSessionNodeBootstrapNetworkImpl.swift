import Foundation
import NetworkManager

final class URLSessionNodeBootstrapNetworkImpl: NodeBootstrapNetworkProtocol, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func fetchNodes() async throws -> Response<NodeBootstrapResponseNetworkModel> {
        let endpoint = try makeEndpoint(path: "api/v1/nodes")
        let (data, urlResponse) = try await session.data(from: endpoint)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NodeBootstrapNetworkError.invalidStatusCode(httpResponse.statusCode)
        }

        let rawHeaders = httpResponse.allHeaderFields
        let headers = rawHeaders.reduce(into: [String: String]()) { result, item in
            result[String(describing: item.key)] = String(describing: item.value)
        }
        return Response(
            data: try JSONDecoder().decode(NodeBootstrapResponseNetworkModel.self, from: data),
            statusCode: httpResponse.statusCode,
            headers: headers,
            cookies: HTTPCookie.cookies(withResponseHeaderFields: headers, for: endpoint)
        )
    }

    private func makeEndpoint(path: String) throws -> URL {
        let baseURLString = Bundle.main.configurationValue(for: .signalingBaseURL)
        guard let baseURL = URL(string: baseURLString) else {
            throw URLError(.badURL)
        }
        return URL(string: path, relativeTo: baseURL) ?? baseURL.appendingPathComponent(path)
    }
}

enum NodeBootstrapNetworkError: Error {
    case invalidStatusCode(Int)
    case missingEntryWebSocketURL
}
