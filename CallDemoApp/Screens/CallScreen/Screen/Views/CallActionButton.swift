import SwiftUI

struct CallActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 64, height: 64)
                    .glassEffect(.regular.tint(color).interactive(), in: .circle)
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.white)
        }
    }
}
