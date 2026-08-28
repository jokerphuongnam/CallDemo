import Combine
import Foundation

final class CancelBag: Cancellable {
    private struct Entry {
        let cancellable: AnyCancellable
        let childBag: CancelBag?
    }

    private static let hierarchyLock = NSLock()

    private let lock = NSLock()
    private var entries: [Int: Entry] = [:]
    private var isCancelled = false

    var count: Int {
        lock.withLock {
            entries.count
        }
    }

    var isEmpty: Bool {
        lock.withLock {
            entries.isEmpty
        }
    }

    @discardableResult
    func insert(_ cancellation: @escaping () -> Void) -> Int {
        let cancellable = AnyCancellable(cancellation)
        let result = lock.withLock {
            let id = makeUniqueID()
            guard !isCancelled else { return (id, false) }
            entries[id] = Entry(cancellable: cancellable, childBag: nil)
            return (id, true)
        }

        if !result.1 {
            cancellable.cancel()
        }
        return result.0
    }

    @discardableResult
    func remove(_ id: Int) -> Bool {
        let cancellable = lock.withLock {
            entries.removeValue(forKey: id)?.cancellable
        }

        cancellable?.cancel()
        return cancellable != nil
    }

    func reset() {
        cancelEntries(shouldClose: false)
    }

    func cancel() {
        cancelEntries(shouldClose: true)
    }

    deinit {
        cancel()
    }

    @discardableResult
    func insert(_ childBag: CancelBag) -> Int? {
        Self.hierarchyLock.withLock {
            guard childBag !== self else { return nil }
            guard !childBag.containsDescendant(self) else { return nil }

            let cancellable = AnyCancellable {
                childBag.cancel()
            }
            let result = lock.withLock {
                guard !isCancelled else { return (0, false) }
                let id = makeUniqueID()
                entries[id] = Entry(cancellable: cancellable, childBag: childBag)
                return (id, true)
            }

            if !result.1 {
                cancellable.cancel()
                return nil
            }
            return result.0
        }
    }

    private func cancelEntries(shouldClose: Bool) {
        let storedCancellables = lock.withLock {
            if shouldClose {
                isCancelled = true
            }
            let storedCancellables = entries.values.map(\.cancellable)
            entries.removeAll()
            return storedCancellables
        }

        storedCancellables.forEach { $0.cancel() }
    }

    private func containsDescendant(_ target: CancelBag) -> Bool {
        var bagsToInspect = [self]
        var inspectedBags = Set<ObjectIdentifier>()

        while let bag = bagsToInspect.popLast() {
            if bag === target {
                return true
            }

            let identifier = ObjectIdentifier(bag)
            guard inspectedBags.insert(identifier).inserted else { continue }
            let childBags = bag.lock.withLock {
                bag.entries.values.compactMap(\.childBag)
            }
            bagsToInspect.append(contentsOf: childBags)
        }

        return false
    }

    private func makeUniqueID() -> Int {
        var id: Int

        repeat {
            id = Int.random(in: 1...Int.max)
        } while entries[id] != nil

        return id
    }
}
