import Foundation
import NetworkManager
import Swinject
import SwinjectAutoregistration

@MainActor
enum AppContainer {
    private static let userDefaultsSuiteEnvironmentKey = "CALL_DEMO_USER_DEFAULTS_SUITE"
    private static let signalingStubEnvironmentKey = "CALL_DEMO_SIGNALING_STUB"

    static func make() -> Resolver {
        let container = Container()
        registerDependencies(in: container)
        return container.synchronize()
    }

    private static func registerDependencies(in container: Container) {
        registerSystemDependencies(in: container)
        registerNetworks(in: container)
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
        container.register(UserDefaults.self) { _ in makeUserDefaults() }
        container.register(URLSession.self) { _ in .shared }
        container.register(NetworkSession.self) { _ in makeNetworkSession() }
    }

    private static func makeNetworkSession() -> NetworkSession {
        let baseURLString = Bundle.main.configurationValue(for: .signalingBaseURL)
        guard let baseURL = URL(string: baseURLString) else {
            preconditionFailure("SIGNALING_BASE_URL is invalid: \(baseURLString)")
        }

        return NetworkSession(
            baseUrl: baseURL,
            client: URLSessionClient.shared,
            converterFactory: JSONDecodableConverterFactory(),
            headers: ["Content-Type": "application/json"],
            interceptors: [LoggingInterceptor(level: .all)]
        )
    }

    private static func registerNetworks(in container: Container) {
        container.register(CredentialNetworkProtocol.self) { resolver in
            NetworkManagerCredentialNetworkProtocolImpl(
                session: resolver.resolveRequired(NetworkSession.self)
            )
        }
        container.register(NodeBootstrapNetworkProtocol.self) { resolver in
            NetworkManagerNodeNetworkProtocolImpl(
                session: resolver.resolveRequired(NetworkSession.self)
            )
        }
        container.autoregister(
            SignalingWebSocketNetworkProtocol.self,
            initializer: DefaultSignalingWebSocketNetworkImpl.init
        )
    }

    private static func makeUserDefaults() -> UserDefaults {
        guard
            let suiteName = ProcessInfo.processInfo.environment[userDefaultsSuiteEnvironmentKey],
            !suiteName.isEmpty,
            let userDefaults = UserDefaults(suiteName: suiteName)
        else {
            return .standard
        }

        return userDefaults
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
        if let stubResult = signalingStubResult {
            container.register(SignalingRepositoryProtocol.self) { _ in
                UITestSignalingRepositoryImpl(result: stubResult)
            }
        } else {
            container.autoregister(
                SignalingRepositoryProtocol.self,
                initializer: DefaultSignalingRepositoryImpl.init
            )
        }
    }

    private static var signalingStubResult: UITestSignalingResult? {
        let value = ProcessInfo.processInfo.environment[signalingStubEnvironmentKey]
        return value.flatMap(UITestSignalingResult.init(rawValue:))
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
