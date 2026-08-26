import XCTest

final class CallDemoAppUITests: XCTestCase {
    private enum EnvironmentKey {
        static let currentUserID = "CALL_DEMO_CURRENT_USER_ID"
        static let partnerUserID = "CALL_DEMO_PARTNER_USER_ID"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOpenSettings() {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["home.settingsButton"]

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        XCTAssertTrue(app.textFields["settings.currentUserIDField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["settings.partnerUserIDField"].exists)
    }

    func testTapCallIfAvailable() {
        let app = XCUIApplication()
        app.launch()
        configureUserIDsIfProvided(in: app)
        let callButton = app.buttons["home.callButton"]

        XCTAssertTrue(callButton.waitForExistence(timeout: 10))

        if callButton.isEnabled {
            callButton.tap()
            XCTAssertTrue(app.buttons["call.endButton"].waitForExistence(timeout: 10))
        }
    }

    func testTapReceiveCallIfAvailable() {
        let app = XCUIApplication()
        app.launch()
        configureUserIDsIfProvided(in: app)
        let incomingButton = app.buttons["home.simulateIncomingButton"]

        XCTAssertTrue(incomingButton.waitForExistence(timeout: 10))

        if incomingButton.isEnabled {
            incomingButton.tap()

            let answerButton = app.buttons["call.answerButton"]
            if answerButton.waitForExistence(timeout: 10) {
                answerButton.tap()
                XCTAssertTrue(app.buttons["call.endButton"].waitForExistence(timeout: 5))
            }
        }
    }

    private func configureUserIDsIfProvided(in app: XCUIApplication) {
        let environment = ProcessInfo.processInfo.environment
        let currentUserID = nonEmptyValue(environment[EnvironmentKey.currentUserID])
        let partnerUserID = nonEmptyValue(environment[EnvironmentKey.partnerUserID])

        guard currentUserID != nil || partnerUserID != nil else { return }

        let settingsButton = app.buttons["home.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        var didChangeStoredIDs = false

        if let currentUserID {
            didChangeStoredIDs = fillTextIfEmpty(
                in: app.textFields["settings.currentUserIDField"],
                with: currentUserID
            ) || didChangeStoredIDs
        }

        if let partnerUserID {
            didChangeStoredIDs = fillTextIfEmpty(
                in: app.textFields["settings.partnerUserIDField"],
                with: partnerUserID
            ) || didChangeStoredIDs
        }

        guard didChangeStoredIDs else {
            app.buttons["Cancel"].tap()
            return
        }

        let saveButton = app.buttons["settings.saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isEnabled, "Current user ID is required before saving")
        saveButton.tap()
    }

    @discardableResult
    private func fillTextIfEmpty(in textField: XCUIElement, with text: String) -> Bool {
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        let newValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let storedValue = (textField.value as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let hasStoredValue = storedValue?.isEmpty == false
            && storedValue != textField.placeholderValue

        guard !hasStoredValue, !newValue.isEmpty else { return false }

        textField.tap()
        textField.typeText(newValue)
        return true
    }

    private func nonEmptyValue(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
