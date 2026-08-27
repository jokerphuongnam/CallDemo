import SwiftUI

struct HomeScreen: View {
    @State private var callViewModel: CallViewModel
    private let viewFactory: AppViewFactoryProtocol
    @State private var isShowingSettings = false

    init(callViewModel: CallViewModel, viewFactory: AppViewFactoryProtocol) {
        self.callViewModel = callViewModel
        self.viewFactory = viewFactory
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.65), .indigo, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Call Demo").font(.largeTitle.bold())
                Text(callViewModel.statusText).foregroundStyle(.secondary)
                GlassEffectContainer(spacing: 16) {
                    VStack(spacing: 16) {
                        Button("Chuẩn bị WebSocket", systemImage: "network") {
                            callViewModel.requestSignalingCredentials()
                        }
                        .accessibilityIdentifier("home.prepareWebSocketButton")
                        .buttonStyle(.glass)
                        .disabled(
                            !callViewModel.hasCurrentUserID
                                || callViewModel.signalingState == .preparing
                        )

                        Text(callViewModel.signalingPreparationText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("home.signalingPreparationText")

                        Button(callButtonTitle, systemImage: "phone.fill") {
                            callViewModel.startCall()
                        }
                        .accessibilityIdentifier("home.callButton")
                        .buttonStyle(.glassProminent)
                        .disabled(!callViewModel.canUseCallActions)
                        .animation(.smooth, value: callViewModel.canUseCallActions)

                        Button("Giả lập cuộc gọi đến", systemImage: "phone.arrow.down.left") {
                            callViewModel.receiveCall()
                        }
                        .accessibilityIdentifier("home.simulateIncomingButton")
                        .buttonStyle(.glass)
                        .disabled(!callViewModel.canUseCallActions)
                        .animation(.smooth, value: callViewModel.canUseCallActions)
                    }
                }
            }
            .padding(32)
            .glassEffect(.regular, in: .rect(cornerRadius: 32))
            .padding()
        }
        .navigationTitle("Calls")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if callViewModel.hasCurrentUserID {
                    Label(callViewModel.displayUserID, systemImage: "person.crop.circle.fill")
                        .font(.subheadline.weight(.medium))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape") {
                    isShowingSettings = true
                }
                .accessibilityIdentifier("home.settingsButton")
            }
        }
        .sheet(
            isPresented: $isShowingSettings,
            onDismiss: {
                withAnimation(.smooth) {
                    callViewModel.refreshSettings()
                }
            },
            content: viewFactory.makeSettingsView
        )
        .fullScreenCover(item: $callViewModel.activeCall) { _ in
            viewFactory.makeCallScreen(
                for: $callViewModel.activeCall,
                onAnswer: callViewModel.answerCall,
                onEnd: callViewModel.endCall
            )
        }
    }

    private var callButtonTitle: String {
        callViewModel.canStartOutgoingCall
            ? "Call \(callViewModel.partnerDisplayUserID)" : "Nhập Partner ID"
    }
}
