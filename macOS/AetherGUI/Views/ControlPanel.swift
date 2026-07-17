import SwiftUI

struct ControlPanel: View {
    @EnvironmentObject var aether: AetherManager

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                StartStopButton()

                GlassCard {
                    HStack(spacing: 10) {
                        SectionHeader(title: "Protocol", icon: "network")
                        Spacer()
                        SegmentedPicker(selection: $aether.selectedProtocol, label: { $0.rawValue }) { mode in
                            switch mode {
                            case .masque: return "bolt.fill"
                            case .wireguard: return "lock.shield"
                            case .gool: return "arrow.triangle.2.circlepath"
                            }
                        }
                    }
                    .padding(14)
                }

                GlassCard {
                    HStack(spacing: 10) {
                        SectionHeader(title: "Scan", icon: "gauge.with.dots.needle.67percent")
                        Spacer()
                        SegmentedPicker(selection: $aether.scanMode, label: { $0.rawValue }) { mode in
                            switch mode {
                            case .turbo: return "bolt.fill"
                            case .balanced: return "equal.circle"
                            case .thorough: return "magnifyingglass"
                            case .stealth: return "eye.slash"
                            }
                        }
                    }
                    .padding(14)
                }

                if aether.selectedProtocol == .masque {
                    GlassCard {
                        HStack(spacing: 10) {
                            SectionHeader(title: "Transport", icon: "arrow.up.arrow.down")
                            Spacer()
                            SegmentedPicker(selection: $aether.transportMode, label: { $0.rawValue }) { mode in
                                switch mode {
                                case .quic: return "bolt.horizontal.fill"
                                case .h2: return "cable.connector"
                                }
                            }
                        }
                        .padding(14)
                    }
                }

                GlassCard {
                    HStack(spacing: 10) {
                        SectionHeader(title: "Network", icon: "globe")
                        Spacer()
                        SegmentedPicker(selection: $aether.ipMode, label: { $0.rawValue }, icon: nil)
                    }
                    .padding(14)
                }

                GlassCard {
                    HStack(spacing: 10) {
                        SectionHeader(title: "Obfuscation", icon: "theatermasks")
                        Spacer()
                        SegmentedPicker(selection: $aether.obfuscation, label: { $0.rawValue }, icon: nil)
                    }
                    .padding(14)
                }

                GlassCard {
                    HStack(spacing: 10) {
                        SectionHeader(title: "SOCKS5 Bind", icon: "mappin.and.ellipse")
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "link").font(.system(size: 12)).foregroundColor(Color.aetherAccent)
                            TextField("127.0.0.1:1819", text: $aether.bindAddress)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.aetherText)
                                .padding(7)
                                .frame(minWidth: 120)
                                .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .stroke(Color.aetherBorder, lineWidth: 1)))
                            Button(action: { aether.bindAddress = "127.0.0.1:1819" }) {
                                Text("Reset")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.aetherTextDim)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                                            .stroke(Color.aetherBorder, lineWidth: 1)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(14)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        AccentToggle(title: "Quick Reconnect", isOn: $aether.quickReconnect,
                                     subtitle: "Auto-reconnect with last gateway")
                        Divider().background(Color.white.opacity(0.06))
                        AccentToggle(title: "System Proxy", isOn: $aether.systemProxyEnabled,
                                     subtitle: "Automatically set proxy on connect")

                        if aether.selectedProtocol == .masque {
                            AccentToggle(title: "ECH", isOn: $aether.echEnabled,
                                         subtitle: "Encrypted Client Hello")
                        }
                        if aether.selectedProtocol == .masque && aether.transportMode == .h2 {
                            AccentToggle(title: "Fragment ClientHello", isOn: $aether.fragmentEnabled,
                                         subtitle: "Fragment TLS on HTTP/2")
                            if aether.fragmentEnabled {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Size").font(.system(size: 9, weight: .medium)).foregroundColor(Color.aetherTextDim)
                                        TextField("16-32", text: $aether.fragmentSize)
                                            .textFieldStyle(.plain).font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(Color.aetherText).padding(5)
                                            .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.black.opacity(0.3)))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Delay").font(.system(size: 9, weight: .medium)).foregroundColor(Color.aetherTextDim)
                                        TextField("2-10", text: $aether.fragmentDelay)
                                            .textFieldStyle(.plain).font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(Color.aetherText).padding(5)
                                            .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.black.opacity(0.3)))
                                    }
                                    Spacer()
                                }
                            }
                        }
                        if aether.selectedProtocol == .wireguard || aether.selectedProtocol == .gool {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Keepalive").font(.system(size: 9, weight: .medium)).foregroundColor(Color.aetherTextDim)
                                    Text("\(aether.keepalive)s")
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(Color.aetherText)
                                }
                                Spacer()
                                Stepper("", value: $aether.keepalive, in: 1...60).labelsHidden()
                            }
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(Color.black.opacity(0.2)))
                        }
                    }
                    .padding(14)
                }
            }
            .padding(22)
        }
        .onChange(of: aether.selectedProtocol) { aether.markSettingsChanged() }
        .onChange(of: aether.scanMode) { aether.markSettingsChanged() }
        .onChange(of: aether.transportMode) { aether.markSettingsChanged() }
        .onChange(of: aether.ipMode) { aether.markSettingsChanged() }
        .onChange(of: aether.obfuscation) { aether.markSettingsChanged() }
        .onChange(of: aether.quickReconnect) { aether.markSettingsChanged() }
        .onChange(of: aether.echEnabled) { aether.markSettingsChanged() }
        .onChange(of: aether.fragmentEnabled) { aether.markSettingsChanged() }
        .onChange(of: aether.keepalive) { aether.markSettingsChanged() }
    }
}
