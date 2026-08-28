import Foundation
import Testing
@testable import CallDemoApp

struct TimerCancelBagTests {
    @Test("A timer is invalidated with its bag")
    func timerIsInvalidated() {
        let bag = CancelBag()
        let timer = Timer(timeInterval: 60, repeats: false) { _ in }

        timer.store(bag)
        bag.reset()

        #expect(!timer.isValid)
    }
}
