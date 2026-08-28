import Foundation

extension Timer {
    @discardableResult
    func store(_ bag: CancelBag) -> Int {
        bag.insert {
            self.invalidate()
        }
    }
}
