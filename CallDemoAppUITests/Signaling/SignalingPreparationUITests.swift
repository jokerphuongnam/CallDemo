import XCTest

final class SignalingPreparationUITests: CallDemoAppUITestCase {
    func testOutgoingCallPreparesThenJoinsAsCaller() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver"
        )
        let callButton = app.buttons["home.callButton"]
        XCTAssertTrue(callButton.isEnabled)
        callButton.tap()

        let status = app.staticTexts["call.statusText"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertEqual(status.label, "Đang kết nối signaling…")
        XCTAssertTrue(
            waitUntilValue(
                status,
                equals: "Đã vào WebSocket với vai trò caller",
                timeout: 5
            )
        )
    }

    func testIncomingCallPreparesThenJoinsAsCallee() {
        let app = launchConfiguredApp(
            currentUserID: "receiver",
            partnerUserID: "caller"
        )
        let receiveButton = app.buttons["home.receiveCallButton"]
        XCTAssertTrue(receiveButton.isEnabled)
        receiveButton.tap()

        let status = app.staticTexts["call.statusText"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertEqual(status.label, "Đang kết nối signaling…")
        XCTAssertTrue(
            waitUntilValue(
                status,
                equals: "Đang chờ caller gọi đến…",
                timeout: 5
            )
        )
    }

    func testCallScreenDismissesWhenAutomaticPreparationFails() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver",
            signalingResult: "failure"
        )
        let callButton = app.buttons["home.callButton"]
        XCTAssertTrue(callButton.isHittable)
        callButton.tap()

        Thread.sleep(forTimeInterval: 1.5)
        let endButton = app.buttons["call.endButton"]
        XCTAssertFalse(endButton.exists)
        XCTAssertTrue(callButton.isHittable)
        XCTAssertTrue(callButton.isEnabled)
    }
}
