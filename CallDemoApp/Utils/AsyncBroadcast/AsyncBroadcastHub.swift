import Foundation

final class AsyncBroadcastHub<Element>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]
    private var isFinished = false

    var subscriberCount: Int {
        lock.withLock {
            continuations.count
        }
    }

    func stream(
        bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
    ) -> AsyncStream<Element> {
        let subscriptionID = UUID()
        let pair = AsyncStream<Element>.makeStream(bufferingPolicy: bufferingPolicy)

        pair.continuation.onTermination = { [weak self] _ in
            guard let self else { return }
            removeContinuation(for: subscriptionID)
        }

        let shouldFinish = lock.withLock {
            guard !isFinished else { return true }
            continuations[subscriptionID] = pair.continuation
            return false
        }

        if shouldFinish {
            pair.continuation.finish()
        }
        return pair.stream
    }

    func send(_ element: Element) {
        let currentContinuations = lock.withLock {
            Array(continuations.values)
        }

        currentContinuations.forEach { continuation in
            continuation.yield(element)
        }
    }

    func finish() {
        let currentContinuations = lock.withLock {
            isFinished = true
            let currentContinuations = Array(continuations.values)
            continuations.removeAll()
            return currentContinuations
        }

        currentContinuations.forEach { continuation in
            continuation.finish()
        }
    }

    private func removeContinuation(for subscriptionID: UUID) {
        lock.withLock {
            _ = continuations.removeValue(forKey: subscriptionID)
        }
    }
}
