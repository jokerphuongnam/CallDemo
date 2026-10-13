import CancelBag
import Combine
import ScreenViewModel

public extension CancelBag {
    /// Cancels this bag when the screen effect `id` is cancelled or the model is released.
    /// A new effect with the same id cancels this bag first.
    @MainActor
    func effect<Action>(id: some Hashable) -> Effect<Action> {
        let bag = self
        return .onDisappear(id: id) {
            bag.cancel()
        }
    }

    /// Cancelling this bag also cancels the screen effect stored under `id`.
    @discardableResult
    func store<Action>(_ model: ScreenModel<Action>, id: some Hashable) -> Int {
        AnyCancellable { [weak model] in
            let model = model
            Task { @MainActor in
                model?.cancel(id)
            }
        }.store(self)
    }
}
