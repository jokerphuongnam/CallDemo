import XCTest

final class CallCancellationUITests: CallDemoAppUITestCase {
    func testEndingOutgoingCallWhileJoiningSignalingCancelsProgress() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver"
        )

        let callButton = app.buttons["home.callButton"]
        XCTAssertTrue(waitUntilEnabled(callButton, timeout: 5))
        callButton.tap()

        let endButton = app.buttons["call.endButton"]
        XCTAssertTrue(endButton.waitForExistence(timeout: 5))
        endButton.tap()

        XCTAssertTrue(app.buttons["home.callButton"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertFalse(app.staticTexts["call.statusText"].exists)
    }

    func testEndingIncomingCallWhileWaitingForPartnerCancelsProgress() {
        let app = launchConfiguredApp(
            currentUserID: "receiver",
            partnerUserID: "caller"
        )
        let receiveCallButton = app.buttons["home.receiveCallButton"]
        XCTAssertTrue(waitUntilEnabled(receiveCallButton, timeout: 5))
        receiveCallButton.tap()

        let answerButton = app.buttons["call.answerButton"]
        let endButton = app.buttons["call.endButton"]
        XCTAssertTrue(answerButton.waitForExistence(timeout: 5))
        XCTAssertFalse(answerButton.isEnabled)
        endButton.tap()

        XCTAssertTrue(app.buttons["home.receiveCallButton"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertFalse(app.staticTexts["call.statusText"].exists)
    }

}
