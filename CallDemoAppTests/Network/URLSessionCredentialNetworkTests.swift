import Foundation
import Mocker
import Testing

@testable import CallDemoApp

@Suite("URLSessionCredentialNetwork")
struct URLSessionCredentialNetworkTests {
    @Test("Maps an HTTP credential response to the network model")
    func fetchCredentialsMapsSuccessfulResponse() async throws {
        let baseURL = try #require(URL(string: "https://api.example.com/"))
        let endpoint = try #require(URL(string: "api/v1/token", relativeTo: baseURL))
        let responseData = Data(
            """
            {
              "token": "test-token",
              "expiresAtMs": 123456789,
              "secret_hash": "test-secret"
            }
            """.utf8
        )
        Mock(
            url: endpoint,
            contentType: .json,
            statusCode: 200,
            data: [.post: responseData]
        ).register()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockingURLProtocol.self]
        let network = URLSessionCredentialNetworkImpl(
            session: URLSession(configuration: configuration),
            baseURL: baseURL
        )

        let response = try await network.fetchCredentials(
            body: CredentialRequestNetworkModel(userId: "@caller:example.com")
        )

        #expect(response.data.token == "test-token")
        #expect(response.data.expiresAtMilliseconds == 123_456_789)
        #expect(response.data.secretHash == "test-secret")
    }
}
