import SwiftUI
import Testing
import ViewInspector

@testable import CallDemoApp

@MainActor
@Suite("CallActionButton")
struct CallActionButtonTests {
    @Test("Renders the correct title and disabled state")
    func rendersDisabledState() throws {
        let view = CallActionButton(
            title: "Answer",
            systemImage: "phone.fill",
            color: .green,
            isEnabled: false,
            action: {}
        )

        let inspectedView = try view.inspect()
        #expect(try inspectedView.find(text: "Answer").string() == "Answer")
        #expect(try inspectedView.button().isDisabled())
    }
}
