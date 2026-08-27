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
        XCTAssertTrue(waitUntilValue(callStatus, equals: "Đang đổ chuông…", timeout: 5))
        XCTAssertFalse(waitUntilValue(callStatus, equals: "Đã kết nối", timeout: 3))
    }

    func testIncomingAnswerWaitsForSimulatedPartner() {
        let app = launchConfiguredApp(
            currentUserID: "receiver",
            partnerUserID: "caller"
        )

        let simulateIncomingButton = app.buttons["home.simulateIncomingButton"]
        XCTAssertTrue(simulateIncomingButton.waitForExistence(timeout: 10))
        XCTAssertTrue(waitUntilEnabled(simulateIncomingButton, timeout: 5))
        simulateIncomingButton.tap()

        let answerButton = app.buttons["call.answerButton"]
        XCTAssertTrue(answerButton.waitForExistence(timeout: 10))
        XCTAssertFalse(answerButton.isEnabled)
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
        XCTAssertTrue(waitUntilValue(callStatus, equals: "Đã kết nối", timeout: 5))
        XCTAssertTrue(app.buttons["call.endButton"].waitForExistence(timeout: 5))
    }
}
