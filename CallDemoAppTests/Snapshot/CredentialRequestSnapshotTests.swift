import Foundation
import SnapshotTesting
import Testing

@testable import CallDemoApp

@Suite("Credential request snapshots", .snapshots)
struct CredentialRequestSnapshotTests {
    @Test("Keeps the credential request JSON stable")
    func credentialRequestJSON() throws {
        let request = CredentialRequestNetworkModel(
            userId: "@test-user:example.com"
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(request)
        let json = try #require(String(data: data, encoding: .utf8))

        assertSnapshot(of: json + "\n", as: .lines)
    }
}
