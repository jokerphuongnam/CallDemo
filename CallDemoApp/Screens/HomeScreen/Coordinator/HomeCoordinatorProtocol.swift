import SwiftUI

@MainActor
protocol HomeCoordinatorProtocol: AnyObject {
    var path: NavigationPath { get set }
    func popToRoot()
}
