import XCTest

final class CallDemoAppUITests: CallDemoAppUITestCase {
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
        let incomingButton = app.buttons["home.receiveCallButton"]

        XCTAssertTrue(incomingButton.waitForExistence(timeout: 10))

        if incomingButton.isEnabled {
            incomingButton.tap()

            let answerButton = app.buttons["call.answerButton"]
            if answerButton.waitForExistence(timeout: 10) {
                XCTAssertTrue(app.buttons["call.endButton"].waitForExistence(timeout: 5))
            }
        }
    }
}
