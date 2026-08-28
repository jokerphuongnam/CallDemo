import Foundation

final class DefaultSignalingWebSocketNetworkImpl: SignalingWebSocketNetworkProtocol {
    private let session: URLSession
    private let rawMessageContinuation: AsyncStream<String>.Continuation
    let rawMessages: AsyncStream<String>
    private let cancelBag = CancelBag()
    private var task: URLSessionWebSocketTask?

    init(session: URLSession) {
        self.session = session
        (rawMessages, rawMessageContinuation) = AsyncStream.makeStream()
    }

    func connect(
        to url: URL,
        authRequest: SignalingAuthRequestNetworkModel,
        role: SignalingRole
    ) async throws {
        disconnect()
        let task = session.webSocketTask(with: url)
        self.task = task
        task.store(cancelBag)
        task.resume()

        print("[Signaling][WebSocket][Connecting][\(role.rawValue)] \(url.absoluteString)")
        let authData = try JSONEncoder().encode(authRequest)
        guard let authJSON = String(data: authData, encoding: .utf8) else {
            throw SignalingWebSocketNetworkError.invalidAuthenticationFrame
        }
        try await task.send(.string(authJSON))
        print("[Signaling][WebSocket][Auth Frame Sent][\(role.rawValue)]")

        try await waitForAuthentication(on: task)
        startReceiveLoop(task: task)
    }

    func disconnect() {
        cancelBag.reset()
        task = nil
    }

    private func waitForAuthentication(
        on task: URLSessionWebSocketTask
    ) async throws {
        while true {
            let rawMessage = try await task.receive().rawText
            print("[Signaling][WebSocket][Incoming Raw JSON] \(rawMessage)")
            guard let messageType = rawMessage.messageType else {
                rawMessageContinuation.yield(rawMessage)
                continue
            }
            if messageType == "auth_success" || messageType == "joined" {
                print("[Signaling][WebSocket][Authenticated]")
                return
            }
            if messageType == "error" {
                throw SignalingWebSocketNetworkError.authenticationFailed(rawMessage)
            }
            rawMessageContinuation.yield(rawMessage)
        }
    }

    private func startReceiveLoop(task: URLSessionWebSocketTask) {
        cancelBag.reset()
        Task { [weak self] in
            while !Task.isCancelled {
                do {
                    let rawMessage = try await task.receive().rawText
                    guard let self else { return }
                    print("[Signaling][WebSocket][Incoming Raw JSON] \(rawMessage)")
                    rawMessageContinuation.yield(rawMessage)
                } catch {
                    guard !Task.isCancelled else { return }
                    print("[Signaling][WebSocket][Receive Failed] \(error)")
                    return
                }
            }
        }
        .store(cancelBag)
    }
}

enum SignalingWebSocketNetworkError: Error {
    case invalidAuthenticationFrame
    case authenticationFailed(String)
}

private extension URLSessionWebSocketTask.Message {
    var rawText: String {
        switch self {
        case .string(let text):
            text
        case .data(let data):
            String(data: data, encoding: .utf8) ?? data.base64EncodedString()
        @unknown default:
            ""
        }
    }
}

private extension String {
    var messageType: String? {
        guard
            let data = data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return object["type"] as? String
    }
}
