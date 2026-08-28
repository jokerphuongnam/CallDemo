import Foundation
import Testing
@testable import CallDemoApp

struct NotificationObserverCancelBagTests {
    @Test("A notification observer is removed with its bag")
    func observerIsRemoved() {
        let center = NotificationCenter()
        let name = Notification.Name("CancelBagTests.notification")
        let bag = CancelBag()
        var receivedNotificationCount = 0
        let observer = center.addObserver(
            forName: name,
            object: nil,
            queue: nil
        ) { _ in
            receivedNotificationCount += 1
        }

        observer.store(bag, center: center)
        center.post(name: name, object: nil)
        bag.reset()
        center.post(name: name, object: nil)

        #expect(receivedNotificationCount == 1)
    }
}
