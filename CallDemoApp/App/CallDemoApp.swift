import SwiftUI

@main
struct CallDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let viewFactory: AppViewFactoryProtocol

    init() {
        viewFactory = AppContainer.make().resolveRequired(AppViewFactoryProtocol.self)
    }

    var body: some Scene {
        WindowGroup {
            viewFactory.makeHomeCoordinatorScreen()
        }
    }
}
