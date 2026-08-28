import Combine

extension Cancellable {
    @discardableResult
    func store(_ bag: CancelBag) -> Int {
        return bag.insert {
            self.cancel()
        }
    }
}

extension CancelBag {
    @discardableResult
    func store(_ bag: CancelBag) -> Int? {
        bag.insert(self)
    }
}
