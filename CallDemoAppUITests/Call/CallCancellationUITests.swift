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
        let app = launchConfiguredApp(currentUserID: "receiver")
        let simulateIncomingButton = app.buttons["home.simulateIncomingButton"]
        XCTAssertTrue(waitUntilEnabled(simulateIncomingButton, timeout: 5))
        simulateIncomingButton.tap()

        let answerButton = app.buttons["call.answerButton"]
        let endButton = app.buttons["call.endButton"]
        XCTAssertTrue(answerButton.waitForExistence(timeout: 5))
        XCTAssertFalse(answerButton.isEnabled)
        endButton.tap()

        XCTAssertTrue(app.buttons["home.simulateIncomingButton"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertFalse(app.staticTexts["call.statusText"].exists)
    }

    func testEndingIncomingCallWhileConnectingWebRTCCancelsProgress() {
        let app = launchConfiguredApp(currentUserID: "receiver")
        let simulateIncomingButton = app.buttons["home.simulateIncomingButton"]
        XCTAssertTrue(waitUntilEnabled(simulateIncomingButton, timeout: 5))
        simulateIncomingButton.tap()

        let answerButton = app.buttons["call.answerButton"]
        XCTAssertTrue(answerButton.waitForExistence(timeout: 5))
        XCTAssertTrue(waitUntilEnabled(answerButton, timeout: 5))
        answerButton.tap()

        let callStatus = app.staticTexts["call.statusText"]
        XCTAssertTrue(
            waitUntilValue(
                callStatus,
                equals: "Đang kết nối WebRTC…",
                timeout: 2
            )
        )
        app.buttons["call.endButton"].tap()

        XCTAssertTrue(app.buttons["home.simulateIncomingButton"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertFalse(callStatus.exists)
    }
}
