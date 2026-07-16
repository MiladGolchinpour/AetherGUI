import SwiftUI

struct ContentView: View {
    @EnvironmentObject var aether: AetherManager
    @State private var selectedTab: Tab = .control

    enum Tab: String, CaseIterable, Identifiable {
        case control = "Control"
        case logs = "Logs"
        case settings = "Settings"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.10),
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.05, green: 0.05, blue: 0.12)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderBar()
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                tabBar
                    .padding(.horizontal, 22)
                    .padding(.bottom, 10)

                Divider().background(Color.white.opacity(0.06))

                ReloadBanner()

                switch selectedTab {
                case .control: ControlPanel()
                case .logs: LogsView()
                case .settings: SettingsView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(Tab.allCases) { tab in
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = tab } }) {
                    HStack(spacing: 5) {
                        Image(systemName: iconName(for: tab))
                            .font(.system(size: 11, weight: .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(selectedTab == tab ? .white : Color.aetherTextDim)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Group {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.aetherAccent.opacity(0.2))
                                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.aetherAccent.opacity(0.4), lineWidth: 1))
                            }
                        }
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            Spacer()
            StatusBadge(text: statusText, color: statusColor, pulsing: aether.connectionState.isActive)
        }
    }

    func iconName(for tab: Tab) -> String {
        switch tab {
        case .control: return "bolt.fill"
        case .logs: return "doc.text.magnifyingglass"
        case .settings: return "gearshape.2.fill"
        }
    }

    var statusColor: Color {
        switch aether.connectionState {
        case .disconnected: return Color.aetherTextDim
        case .scanning: return Color.aetherOrange
        case .connecting: return Color(red: 1.0, green: 0.85, blue: 0.20)
        case .connected: return Color.aetherGreen
        case .error: return Color.aetherRed
        }
    }

    var statusText: String {
        switch aether.connectionState {
        case .disconnected: return "IDLE"
        case .scanning: return "SCANNING"
        case .connecting: return "CONNECTING"
        case .connected: return "CONNECTED"
        case .error: return "ERROR"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AetherManager())
        .frame(width: 560, height: 500)
}
