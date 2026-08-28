import Foundation
import Testing
@testable import CallDemoApp

struct URLSessionWebSocketTaskCancelBagTests {
    @Test("A WebSocket task is cancelled with its bag")
    func webSocketTaskIsCancelled() async throws {
        let bag = CancelBag()
        let url = try #require(URL(string: "wss://example.invalid"))
        let task = URLSession.shared.webSocketTask(
            with: url
        )

        task.store(bag)
        task.resume()
        bag.reset()

        for _ in 0..<20 {
            guard task.state != .canceling && task.state != .completed else { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(task.state == .canceling || task.state == .completed)
    }
}
