import Cuckoo
import Testing

@testable import CallDemoApp

@Suite("DefaultCallUseCase", .serialized)
struct DefaultCallUseCaseTests {
    @Test("Allows outgoing calls when both IDs are available")
    func canStartOutgoingCallWhenBothIDsExist() {
        let testContext = makeTestContext(
            settings: UserSettings(
                currentUserID: "caller",
                partnerUserID: "receiver"
            )
        )

        #expect(testContext.useCase.canStartOutgoingCall)
        verify(testContext.repository, times(2)).getSettings()
    }

    @Test("Prevents outgoing calls when the partner ID is missing")
    func cannotStartOutgoingCallWhenPartnerIDIsEmpty() {
        let testContext = makeTestContext(
            settings: UserSettings(
                currentUserID: "caller",
                partnerUserID: "   "
            )
        )

        #expect(!testContext.useCase.canStartOutgoingCall)
        verify(testContext.repository, times(2)).getSettings()
    }

    private func makeTestContext(settings: UserSettings) -> TestContext {
        let repository = MockUserSettingsRepositoryProtocol()
        let signalingRepository = MockSignalingRepositoryProtocol()
        let callManager = MockCallManagerProtocol()
        let userIDManager = MockUserIDManagerProtocol()
        stub(repository) { stub in
            when(stub.getSettings()).thenReturn(settings)
        }
        let useCase = DefaultCallUseCaseImpl(
            repository: repository,
            signalingRepository: signalingRepository,
            callManager: callManager,
            userIDManager: userIDManager
        )
        return TestContext(repository: repository, useCase: useCase)
    }
}

private struct TestContext {
    let repository: MockUserSettingsRepositoryProtocol
    let useCase: DefaultCallUseCaseImpl
}
