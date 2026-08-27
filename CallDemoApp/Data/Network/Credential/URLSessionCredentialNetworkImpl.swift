import Foundation
import NetworkManager

final class URLSessionCredentialNetworkImpl: CredentialNetworkProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL?

    init(session: URLSession, baseURL: URL? = nil) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchCredentials(
        body: CredentialRequestNetworkModel
    ) async throws -> Response<CredentialResponseNetworkModel> {
        let endpoint = try makeEndpoint(path: "api/v1/token")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, urlResponse) = try await session.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw CredentialNetworkError.invalidStatusCode(httpResponse.statusCode)
        }

        return Response(
            data: try JSONDecoder().decode(CredentialResponseNetworkModel.self, from: data),
            statusCode: httpResponse.statusCode,
            headers: httpResponse.stringHeaders,
            cookies: HTTPCookie.cookies(
                withResponseHeaderFields: httpResponse.stringHeaders,
                for: endpoint
            )
        )
    }

    private func makeEndpoint(path: String) throws -> URL {
        if let baseURL {
            return URL(string: path, relativeTo: baseURL)
                ?? baseURL.appendingPathComponent(path)
        }
        let baseURLString = Bundle.main.configurationValue(for: .signalingBaseURL)
        guard let baseURL = URL(string: baseURLString) else {
            throw URLError(.badURL)
        }
        return URL(string: path, relativeTo: baseURL) ?? baseURL.appendingPathComponent(path)
    }
}

enum CredentialNetworkError: Error {
    case invalidStatusCode(Int)
}

private extension HTTPURLResponse {
    var stringHeaders: [String: String] {
        allHeaderFields.reduce(into: [:]) { result, item in
            result[String(describing: item.key)] = String(describing: item.value)
        }
    }
}
