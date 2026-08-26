import SwiftUI

struct CallScreen: View {
    @Binding var call: ActiveCall?
    let onAnswer: () -> Void
    let onEnd: () -> Void

    var body: some View {
        if let call {
            ZStack {
                LinearGradient(colors: [.indigo.opacity(0.8), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 96))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(18)
                        .glassEffect(.regular, in: .circle)
                    Text(call.peerName)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text(callStatus)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    
                    GlassEffectContainer(spacing: 56) {
                        HStack(spacing: 56) {
                            if call.direction == .incoming && call.phase == .ringing {
                                CallActionButton(title: "Nhận", systemImage: "phone.fill", color: .green, action: onAnswer)
                            }
                            CallActionButton(title: call.phase == .ringing ? "Từ chối" : "Kết thúc",
                                             systemImage: "phone.down.fill", color: .red, action: onEnd)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
    }

    private var callStatus: String {
        switch call?.phase {
        case .ringing: "Cuộc gọi đến"
        case .connecting: "Đang gọi…"
        case .connected: "Đã kết nối"
        case .none: ""
        }
    }
}
