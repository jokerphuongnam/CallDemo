import Combine
import Testing
@testable import CallDemoApp

struct CancellableCancelBagTests {
    @Test("A Combine cancellable is cancelled with its bag")
    func cancellableIsCancelled() {
        let bag = CancelBag()
        var isCancelled = false
        let cancellable = AnyCancellable {
            isCancelled = true
        }

        cancellable.store(bag)
        bag.reset()

        #expect(isCancelled)
    }
}
