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
            LinearGradient(colors: [.blue.opacity(0.65), .indigo, .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("Call Demo").font(.largeTitle.bold())
                Text(callViewModel.statusText).foregroundStyle(.secondary)
                GlassEffectContainer(spacing: 16) {
                    VStack(spacing: 16) {
                        Button(callButtonTitle, systemImage: "phone.fill") { callViewModel.startCall()
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(!callViewModel.canStartOutgoingCall)
                        
                        Button("Giả lập cuộc gọi đến", systemImage: "phone.arrow.down.left") {
                            callViewModel.receiveCall(from: "Alice")
                        }
                        .buttonStyle(.glass)
                        .disabled(!callViewModel.hasCurrentUserID)
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
            }
        }
        .sheet(isPresented: $isShowingSettings) { viewFactory.makeSettingsView() }
        .fullScreenCover(item: $callViewModel.activeCall) { call in
            viewFactory.makeCallScreen(
                for: $callViewModel.activeCall,
                onAnswer: callViewModel.answerCall,
                onEnd: callViewModel.endCall
            )
        }
    }
    
    private var callButtonTitle: String {
        callViewModel.canStartOutgoingCall ? "Call \(callViewModel.partnerDisplayUserID)" : "Nhập Partner ID"
    }
}
