import XCTest

class CallDemoAppUITestCase: XCTestCase {
    enum EnvironmentKey {
        static let currentUserID = "CALL_DEMO_CURRENT_USER_ID"
        static let partnerUserID = "CALL_DEMO_PARTNER_USER_ID"
        static let userDefaultsSuite = "CALL_DEMO_USER_DEFAULTS_SUITE"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func launchConfiguredApp(
        currentUserID: String,
        partnerUserID: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[EnvironmentKey.userDefaultsSuite] =
            "CallDemoAppUITests.\(UUID().uuidString)"
        app.launch()

        let settingsButton = app.buttons["home.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        let currentUserIDField = app.textFields["settings.currentUserIDField"]
        XCTAssertTrue(currentUserIDField.waitForExistence(timeout: 5))
        currentUserIDField.tap()
        currentUserIDField.typeText(currentUserID)

        if let partnerUserID {
            let partnerUserIDField = app.textFields["settings.partnerUserIDField"]
            XCTAssertTrue(partnerUserIDField.exists)
            partnerUserIDField.tap()
            partnerUserIDField.typeText(partnerUserID)
        }

        let saveButton = app.buttons["settings.saveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        return app
    }

    func configureUserIDsIfProvided(in app: XCUIApplication) {
        let environment = ProcessInfo.processInfo.environment
        let currentUserID = nonEmptyValue(environment[EnvironmentKey.currentUserID])
        let partnerUserID = nonEmptyValue(environment[EnvironmentKey.partnerUserID])

        guard currentUserID != nil || partnerUserID != nil else { return }

        let settingsButton = app.buttons["home.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        var didChangeStoredIDs = false

        if let currentUserID {
            didChangeStoredIDs =
                fillTextIfEmpty(
                    in: app.textFields["settings.currentUserIDField"],
                    with: currentUserID
                ) || didChangeStoredIDs
        }

        if let partnerUserID {
            didChangeStoredIDs =
                fillTextIfEmpty(
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

    func waitUntilEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "enabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    func waitUntilValue(
        _ element: XCUIElement,
        equals expectedValue: String,
        timeout: TimeInterval
    ) -> Bool {
        let predicate = NSPredicate(format: "label == %@", expectedValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @discardableResult
    private func fillTextIfEmpty(in textField: XCUIElement, with text: String) -> Bool {
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        let newValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let storedValue = (textField.value as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let hasStoredValue =
            storedValue?.isEmpty == false
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
