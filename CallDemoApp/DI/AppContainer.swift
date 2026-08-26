import Foundation
import Swinject
import SwinjectAutoregistration

@MainActor
enum AppContainer {
    static func make() -> Resolver {
        let container = Container()
        registerDependencies(in: container)
        return container.synchronize()
    }

    private static func registerDependencies(in container: Container) {
        registerSystemDependencies(in: container)
        registerStorages(in: container)
        registerRepositories(in: container)
        registerManagers(in: container)
        registerUseCases(in: container)
        registerViewModels(in: container)
        registerCoordinators(in: container)
        registerFactories(in: container)
    }

    private static func registerSystemDependencies(in container: Container) {
        container.register(Resolver.self) { resolver in resolver }
        container.register(UserDefaults.self) { _ in .standard }
    }

    private static func registerStorages(in container: Container) {
        container.autoregister(
            UserSettingsStorageProtocol.self,
            initializer: DefaultUserSettingsStorageImpl.init
        )
    }

    private static func registerRepositories(in container: Container) {
        container.autoregister(
            UserSettingsRepositoryProtocol.self,
            initializer: DefaultUserSettingsRepositoryImpl.init
        )
    }

    private static func registerManagers(in container: Container) {
        container.autoregister(
            AppLoggerProtocol.self,
            initializer: DefaultAppLoggerImpl.init
        )
        container.autoregister(
            UserIDManagerProtocol.self,
            initializer: DefaultUserIDManagerImpl.init
        )
        container.autoregister(
            CallManagerProtocol.self,
            initializer: DefaultCallManagerImpl.init
        )
    }

    private static func registerUseCases(in container: Container) {
        container.autoregister(
            CallUseCaseProtocol.self,
            initializer: DefaultCallUseCaseImpl.init
        )
        container.autoregister(
            SettingsUseCaseProtocol.self,
            initializer: DefaultSettingsUseCaseImpl.init
        )
    }

    private static func registerViewModels(in container: Container) {
        container.autoregister(
            CallViewModel.self,
            initializer: CallViewModel.init
        )
        container.autoregister(
            SettingsViewModel.self,
            initializer: SettingsViewModel.init
        )
    }

    private static func registerCoordinators(in container: Container) {
        container.autoregister(
            DefaultHomeCoordinatorImpl.self,
            initializer: DefaultHomeCoordinatorImpl.init
        )
    }

    private static func registerFactories(in container: Container) {
        container.autoregister(
            AppViewFactoryProtocol.self,
            initializer: DefaultAppViewFactoryImpl.init
        )
    }
}
