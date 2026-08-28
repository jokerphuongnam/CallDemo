import Foundation
import Testing
@testable import CallDemoApp

struct DispatchWorkItemCancelBagTests {
    @Test("A dispatch work item is cancelled with its bag")
    func workItemIsCancelled() {
        let bag = CancelBag()
        let workItem = DispatchWorkItem {}

        workItem.store(bag)
        bag.reset()

        #expect(workItem.isCancelled)
    }
}
