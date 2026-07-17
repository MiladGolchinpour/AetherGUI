import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var aether: AetherManager

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Interface", icon: "paintbrush")
                        AccentToggle(title: "Menu Bar Icon", isOn: $aether.showMenuBar,
                                     subtitle: "Show connection status in the menu bar")
                    }
                    .padding(14)
                }

                GlassCard {
                    HStack {
                        SectionHeader(title: "Configs", icon: "folder")
                        Spacer()
                        Label("Configs are saved in ~/Library/Application Support/Aether/", systemImage: "info.circle")
                            .font(.system(size: 10)).foregroundColor(Color.aetherTextDim)
                            .lineLimit(2)
                    }
                    .padding(14)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "About", icon: "info.circle")
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Aether GUI")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.aetherText)
                                Text("macOS wrapper for Cloudflare WARP proxy")
                                    .font(.system(size: 10)).foregroundColor(Color.aetherTextDim)
                            }
                            Spacer()
                            Text("v0.1.1")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.aetherTextDim)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Capsule(style: .continuous).fill(Color.white.opacity(0.06)))
                        }

                        Divider().background(Color.white.opacity(0.06))

                        Label("Binary: bundled in app", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 10)).foregroundColor(Color.aetherGreen)

                        Divider().background(Color.white.opacity(0.06))

                        Button(action: {
                            if let url = URL(string: "https://github.com/CluvexStudio/Aether") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Aether Core by CluvexStudio")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(Color.aetherAccent)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            if let url = URL(string: "https://github.com/MiladGolchinpour/AetherGUI") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Aether GUI Repository")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(Color.aetherAccent)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                }
            }
            .padding(22)
        }
    }
}
