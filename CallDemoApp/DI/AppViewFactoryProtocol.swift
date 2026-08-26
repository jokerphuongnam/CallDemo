import SwiftUI

@MainActor
protocol AppViewFactoryProtocol: AnyObject {
    func makeHomeCoordinatorScreen() -> HomeCoordinatorScreen
    func makeHomeScreen() -> HomeScreen
    func makeSettingsView() -> SettingsView
    func makeCallScreen(
        for call: Binding<ActiveCall?>,
        onAnswer: @escaping () -> Void,
        onEnd: @escaping () -> Void
    ) -> CallScreen
}
