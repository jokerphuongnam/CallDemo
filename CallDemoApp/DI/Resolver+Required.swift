import Swinject

extension Resolver {
    func resolveRequired<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolve(serviceType, name: nil) else {
            preconditionFailure("Missing DI registration for \(serviceType)")
        }
        return service
    }
}
