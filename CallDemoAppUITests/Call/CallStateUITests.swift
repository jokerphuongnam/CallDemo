import XCTest

final class CallStateUITests: CallDemoAppUITestCase {
    func testOutgoingCallWaitsForSignalingBeforeRinging() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver"
        )

        let callButton = app.buttons["home.callButton"]
        XCTAssertTrue(waitUntilEnabled(callButton, timeout: 5))
        callButton.tap()

        let callStatus = app.staticTexts["call.statusText"]
        XCTAssertEqual(callStatus.label, "Đang kết nối signaling…")
        XCTAssertTrue(
            waitUntilValue(
                callStatus,
                equals: "Đã vào WebSocket với vai trò caller",
                timeout: 5
            )
        )
        XCTAssertFalse(waitUntilValue(callStatus, equals: "Đã kết nối", timeout: 3))
    }

    func testCalleeWaitsForARealIncomingCallAfterJoiningWebSocket() {
        let app = launchConfiguredApp(
            currentUserID: "receiver",
            partnerUserID: "caller"
        )

        let receiveCallButton = app.buttons["home.receiveCallButton"]
        XCTAssertTrue(receiveCallButton.waitForExistence(timeout: 10))
        XCTAssertTrue(waitUntilEnabled(receiveCallButton, timeout: 5))
        receiveCallButton.tap()

        let answerButton = app.buttons["call.answerButton"]
        XCTAssertTrue(answerButton.waitForExistence(timeout: 10))
        XCTAssertFalse(answerButton.isEnabled)
        let callStatus = app.staticTexts["call.statusText"]
        XCTAssertTrue(
            waitUntilValue(
                callStatus,
                equals: "Đang chờ caller gọi đến…",
                timeout: 5
            )
        )
        XCTAssertFalse(answerButton.isEnabled)
        XCTAssertTrue(app.buttons["call.endButton"].waitForExistence(timeout: 5))
    }
}
