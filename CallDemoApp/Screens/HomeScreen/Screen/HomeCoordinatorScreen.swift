import SwiftUI

struct HomeCoordinatorScreen: View {
    @State private var coordinator: DefaultHomeCoordinatorImpl
    private let viewFactory: AppViewFactoryProtocol

    init(coordinator: DefaultHomeCoordinatorImpl,
         viewFactory: AppViewFactoryProtocol) {
        self.coordinator = coordinator
        self.viewFactory = viewFactory
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            viewFactory.makeHomeScreen()
        }
    }
}
