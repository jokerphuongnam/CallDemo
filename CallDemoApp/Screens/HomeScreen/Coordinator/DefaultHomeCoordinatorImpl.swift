import Observation
import SwiftUI

@MainActor
@Observable
final class DefaultHomeCoordinatorImpl: HomeCoordinatorProtocol {
    var path = NavigationPath()

    func popToRoot() {
        path = NavigationPath()
    }
}
