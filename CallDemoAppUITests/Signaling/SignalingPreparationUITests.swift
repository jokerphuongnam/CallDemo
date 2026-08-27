import XCTest

final class SignalingPreparationUITests: CallDemoAppUITestCase {
    func testCallActionsStayDisabledUntilSignalingIsReady() {
        let app = launchConfiguredApp(
            currentUserID: "caller",
            partnerUserID: "receiver",
            prepareSignaling: false
        )
        let callButton = app.buttons["home.callButton"]
        let incomingButton = app.buttons["home.simulateIncomingButton"]

        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)

        let preparationStartedAt = Date()
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
        XCTAssertGreaterThanOrEqual(
            Date().timeIntervalSince(preparationStartedAt),
            1.8
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
        let incomingButton = app.buttons["home.simulateIncomingButton"]
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
