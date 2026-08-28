public struct AsyncBroadcast<Element>: AsyncSequence, Sendable {
    public typealias AsyncIterator = AsyncStream<Element>.Iterator

    private let storage: AsyncBroadcastStorage<Element>

    var subscriberCount: Int {
        storage.subscriberCount
    }

    fileprivate init(source: AsyncStream<Element>) {
        storage = AsyncBroadcastStorage(
            source: source,
            bufferingPolicy: .unbounded
        )
    }

    public func makeAsyncIterator() -> AsyncIterator {
        storage.makeAsyncIterator()
    }
}

public extension AsyncStream {
    var broadcast: AsyncBroadcast<Element> {
        AsyncBroadcast(source: self)
    }
}
