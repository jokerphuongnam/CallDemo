import Foundation

extension Bundle {
    func configurationValue(for key: ConfigurationKey) -> String {
        guard let value = object(forInfoDictionaryKey: key.rawValue) as? String,
              !value.isEmpty else {
            preconditionFailure("Missing configuration value for \(key.rawValue)")
        }
        return value
    }
}
