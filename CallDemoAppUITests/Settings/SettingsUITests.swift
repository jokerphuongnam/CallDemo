import XCTest

final class SettingsUITests: CallDemoAppUITestCase {
    func testOpenSettings() {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["home.settingsButton"]

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        XCTAssertTrue(app.textFields["settings.currentUserIDField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["settings.partnerUserIDField"].exists)
    }

    func testSavingSettingsRequiresSignalingBeforeEnablingCallActions() {
        let app = XCUIApplication()
        app.launchEnvironment[EnvironmentKey.userDefaultsSuite] =
            "CallDemoAppUITests.\(UUID().uuidString)"
        app.launchEnvironment[EnvironmentKey.signalingStub] = "success"
        app.launch()

        let callButton = app.buttons["home.callButton"]
        let incomingButton = app.buttons["home.simulateIncomingButton"]
        XCTAssertTrue(callButton.waitForExistence(timeout: 10))
        XCTAssertTrue(incomingButton.exists)
        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)

        app.buttons["home.settingsButton"].tap()

        let currentUserIDField = app.textFields["settings.currentUserIDField"]
        let partnerUserIDField = app.textFields["settings.partnerUserIDField"]
        XCTAssertTrue(currentUserIDField.waitForExistence(timeout: 5))
        currentUserIDField.tap()
        currentUserIDField.typeText("caller")
        partnerUserIDField.tap()
        partnerUserIDField.typeText("receiver")
        app.buttons["settings.saveButton"].tap()

        XCTAssertFalse(callButton.isEnabled)
        XCTAssertFalse(incomingButton.isEnabled)

        prepareSignaling(in: app)
        XCTAssertTrue(waitUntilEnabled(callButton, timeout: 5))
        XCTAssertTrue(waitUntilEnabled(incomingButton, timeout: 5))
    }
}
