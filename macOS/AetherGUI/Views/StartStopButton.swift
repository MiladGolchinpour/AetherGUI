import SwiftUI

struct StartStopButton: View {
    @EnvironmentObject var aether: AetherManager
    @State private var isHovering = false

    var isRunning: Bool { aether.isRunning }
    var glowColor: Color { isRunning ? Color.aetherRed.opacity(0.3) : Color.aetherAccentGlow }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                if isRunning { aether.stop() } else { aether.start() }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(isRunning ? "Disconnect" : "Connect")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(
                            colors: isRunning
                                ? [Color.aetherRed, Color(red: 0.8, green: 0.2, blue: 0.2)]
                                : [Color.aetherAccent, Color.aetherPurple],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                    if isHovering {
                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.white.opacity(0.08))
                    }
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1))
            .shadow(color: glowColor, radius: 14, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { isHovering = h } }
    }
}
