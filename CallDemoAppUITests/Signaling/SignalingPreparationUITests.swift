import XCTest

final class SignalingPreparationUITests: CallDemoAppUITestCase {
    func testCallActionsStayDisabledUntilSignalingIsReady() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver",
            prepareSignaling: false
        )
        let callButton = app.buttons["home.callButton"]
        let incomingButton = app.buttons["home.receiveCallButton"]

        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)

        app.buttons["home.prepareWebSocketButton"].tap()
        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)

        let status = app.staticTexts["home.signalingPreparationText"]
        XCTAssertTrue(
            waitUntilValue(
                status,
                equals: "Thông tin WebSocket đã sẵn sàng",
                timeout: 5
            )
        )
        XCTAssertTrue(waitUntilEnabled(callButton, timeout: 2))
        XCTAssertTrue(waitUntilEnabled(incomingButton, timeout: 2))
    }

    func testCallActionsStayDisabledWhenSignalingFails() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver",
            prepareSignaling: false,
            signalingResult: "failure"
        )
        let callButton = app.buttons["home.callButton"]
        let incomingButton = app.buttons["home.receiveCallButton"]
        app.buttons["home.prepareWebSocketButton"].tap()

        let status = app.staticTexts["home.signalingPreparationText"]
        XCTAssertTrue(
            waitUntilValue(
                status,
                equals: "Chuẩn bị WebSocket thất bại",
                timeout: 5
            )
        )
        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)
    }
}
