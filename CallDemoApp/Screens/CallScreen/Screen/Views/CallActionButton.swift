import SwiftUI

struct CallActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 64, height: 64)
                    .glassEffect(
                        .regular.tint(isEnabled ? color : .gray).interactive(),
                        in: .circle
                    )
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.white)
        }
        .accessibilityIdentifier(
            "call.\(systemImage == "phone.fill" ? "answerButton" : "endButton")"
        )
        .disabled(!isEnabled)
        .animation(.smooth, value: isEnabled)
    }
}
