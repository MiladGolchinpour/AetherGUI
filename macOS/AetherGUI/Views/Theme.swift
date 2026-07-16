import SwiftUI

// MARK: - Custom Colors

extension Color {
    static let aetherAccent = Color(red: 0.30, green: 0.55, blue: 1.0)
    static let aetherAccentGlow = Color(red: 0.30, green: 0.55, blue: 1.0).opacity(0.3)
    static let aetherGreen = Color(red: 0.20, green: 0.85, blue: 0.50)
    static let aetherOrange = Color(red: 1.0, green: 0.60, blue: 0.20)
    static let aetherRed = Color(red: 1.0, green: 0.35, blue: 0.35)
    static let aetherText = Color(red: 0.92, green: 0.92, blue: 0.96)
    static let aetherTextDim = Color(red: 0.55, green: 0.55, blue: 0.65)
    static let aetherBorder = Color.white.opacity(0.06)
    static let aetherPurple = Color(red: 0.55, green: 0.35, blue: 1.0)
}

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.aetherBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Segmented Picker

struct SegmentedPicker<T: Hashable & Identifiable & CaseIterable>: View where T.AllCases == [T] {
    @Binding var selection: T
    let label: (T) -> String
    let icon: ((T) -> String)?

    init(selection: Binding<T>, label: @escaping (T) -> String, icon: ((T) -> String)? = nil) {
        self._selection = selection
        self.label = label
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(T.allCases) { item in
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selection = item } }) {
                    HStack(spacing: 4) {
                        if let icon = icon?(item) {
                            Image(systemName: icon).font(.system(size: 10, weight: .semibold))
                        }
                        Text(label(item))
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .foregroundColor(selection == item ? .white : Color.aetherTextDim)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Group {
                            if selection == item {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(Color.aetherAccent)
                                    .shadow(color: Color.aetherAccentGlow, radius: 5, x: 0, y: 2)
                            }
                        }
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.black.opacity(0.3)))
    }
}

// MARK: - Accent Toggle

struct AccentToggle: View {
    let title: String
    @Binding var isOn: Bool
    var subtitle: String?

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.aetherText)
                    .lineLimit(1)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(Color.aetherTextDim)
                        .lineLimit(1)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(PillToggleStyle())
                .labelsHidden()
                .fixedSize()
        }
    }
}

struct PillToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { configuration.isOn.toggle() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(configuration.isOn ? Color.aetherAccent : Color.white.opacity(0.1))
                    .frame(width: 42, height: 24)
                    .overlay(
                        Circle().fill(.white).frame(width: 18, height: 18)
                            .offset(x: configuration.isOn ? 9 : -9)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.aetherAccent)
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color.aetherText)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.aetherAccent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.aetherAccent.opacity(0.2), lineWidth: 1)
                )
        )
        .fixedSize()
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let text: String
    let color: Color
    var pulsing: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle().fill(color).frame(width: 6, height: 6)
                if pulsing {
                    Circle().fill(color).frame(width: 6, height: 6)
                        .scaleEffect(1.8).opacity(0.4)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: pulsing)
                }
            }
            Text(text)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(color.opacity(0.12))
                .overlay(Capsule(style: .continuous).stroke(color.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: - Reload Banner

struct ReloadBanner: View {
    @EnvironmentObject var aether: AetherManager

    var body: some View {
        if aether.needsReload {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.aetherOrange)
                Text("Settings changed")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.aetherText)
                Spacer()
                Button(action: { aether.reload() }) {
                    Text("Reconnect")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.aetherAccent))
                }
                .buttonStyle(.plain)
                Button(action: { aether.needsReload = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.aetherTextDim)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.aetherOrange.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.aetherOrange.opacity(0.3), lineWidth: 1))
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: aether.needsReload)
        }
    }
}
