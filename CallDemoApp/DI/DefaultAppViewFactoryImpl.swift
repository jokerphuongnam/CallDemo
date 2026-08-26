import SwiftUI
import Swinject

@MainActor
final class DefaultAppViewFactoryImpl: AppViewFactoryProtocol {
    private let resolver: Resolver

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeHomeCoordinatorScreen() -> HomeCoordinatorScreen {
        HomeCoordinatorScreen(
            coordinator: resolver.resolveRequired(DefaultHomeCoordinatorImpl.self),
            viewFactory: self
        )
    }

    func makeHomeScreen() -> HomeScreen {
        HomeScreen(
            callViewModel: resolver.resolveRequired(CallViewModel.self),
            viewFactory: self
        )
    }

    func makeSettingsView() -> SettingsView {
        SettingsView(viewModel: resolver.resolveRequired(SettingsViewModel.self))
    }

    func makeCallScreen(
        for call: Binding<ActiveCall?>,
        onAnswer: @escaping () -> Void,
        onEnd: @escaping () -> Void
    ) -> CallScreen {
        CallScreen(
            call: call,
            onAnswer: onAnswer,
            onEnd: onEnd
        )
    }
}
