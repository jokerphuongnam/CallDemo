import Foundation
import OSLog

final class DefaultAppLoggerImpl: AppLoggerProtocol {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CallDemoApp",
        category: "AppFlow"
    )

    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
}
