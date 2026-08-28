import Foundation

final class AsyncBroadcastStorage<Element>: @unchecked Sendable {
    private let lock = NSLock()
    private let hub = AsyncBroadcastHub<Element>()
    private let cancelBag = CancelBag()
    private let bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
    private var source: AsyncStream<Element>?

    var subscriberCount: Int {
        hub.subscriberCount
    }

    init(
        source: AsyncStream<Element>,
        bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
    ) {
        self.source = source
        self.bufferingPolicy = bufferingPolicy
    }

    func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        let stream = hub.stream(bufferingPolicy: bufferingPolicy)
        startSourceIfNeeded()
        return stream.makeAsyncIterator()
    }

    deinit {
        cancelBag.cancel()
        hub.finish()
    }

    private func startSourceIfNeeded() {
        let sourceToConsume = lock.withLock {
            defer { source = nil }
            return source
        }

        guard let sourceToConsume else { return }
        let hub = hub

        Task {
            for await element in sourceToConsume {
                hub.send(element)
            }
            hub.finish()
        }
        .store(cancelBag)
    }
}
