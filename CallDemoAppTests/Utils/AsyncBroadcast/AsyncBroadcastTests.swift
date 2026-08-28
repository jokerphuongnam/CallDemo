import Testing
@testable import CallDemoApp

struct AsyncBroadcastTests {
    @Test("All active subscribers receive each source element")
    func activeSubscribersReceiveEachSourceElement() async {
        let source = AsyncStream<Int>.makeStream()
        let broadcast = source.stream.broadcast
        var firstIterator = broadcast.makeAsyncIterator()
        var secondIterator = broadcast.makeAsyncIterator()

        source.continuation.yield(42)

        #expect(await firstIterator.next() == 42)
        #expect(await secondIterator.next() == 42)
    }

    @Test("A late subscriber only receives future elements")
    func lateSubscriberReceivesFutureElementsOnly() async {
        let source = AsyncStream<Int>.makeStream()
        let broadcast = source.stream.broadcast
        var firstIterator = broadcast.makeAsyncIterator()

        source.continuation.yield(5)
        let firstValue = await firstIterator.next()

        var lateIterator = broadcast.makeAsyncIterator()
        source.continuation.yield(7)
        source.continuation.yield(2)

        let firstSubscriberValues = [
            firstValue,
            await firstIterator.next(),
            await firstIterator.next()
        ].compactMap { $0 }
        let lateSubscriberValues = [
            await lateIterator.next(),
            await lateIterator.next()
        ].compactMap { $0 }

        #expect(firstSubscriberValues == [5, 7, 2])
        #expect(lateSubscriberValues == [7, 2])
    }

    @Test("Finishing the source completes current and future subscribers")
    func sourceCompletionFinishesSubscribers() async {
        let source = AsyncStream<Int>.makeStream()
        let broadcast = source.stream.broadcast
        var currentIterator = broadcast.makeAsyncIterator()

        source.continuation.finish()
        #expect(await currentIterator.next() == nil)

        var futureIterator = broadcast.makeAsyncIterator()
        #expect(await futureIterator.next() == nil)
        #expect(broadcast.subscriberCount == 0)
    }

    @Test("Releasing an iterator removes its subscription")
    func releasingIteratorRemovesSubscription() async {
        let source = AsyncStream<Int>.makeStream()
        let broadcast = source.stream.broadcast
        var iterator: AsyncStream<Int>.Iterator? = broadcast.makeAsyncIterator()

        #expect(broadcast.subscriberCount == 1)
        iterator = nil

        for _ in 0..<10 where broadcast.subscriberCount > 0 {
            await Task.yield()
        }
        #expect(iterator == nil)
        #expect(broadcast.subscriberCount == 0)
    }
}
