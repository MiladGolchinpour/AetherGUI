import SwiftUI

enum ProtocolMode: String, CaseIterable, Identifiable {
    case masque = "MASQUE"
    case wireguard = "WireGuard"
    case gool = "WARP-in-WARP"
    var id: String { rawValue }
}

enum ScanMode: String, CaseIterable, Identifiable {
    case turbo = "Turbo"
    case balanced = "Balanced"
    case thorough = "Thorough"
    case stealth = "Stealth"
    case ironclad = "Ironclad"
    var id: String { rawValue }
}

enum TransportMode: String, CaseIterable, Identifiable {
    case quic = "QUIC (H3)"
    case h2 = "HTTP/2 (TCP)"
    var id: String { rawValue }
}

enum IPMode: String, CaseIterable, Identifiable {
    case ipv4 = "IPv4"
    case ipv6 = "IPv6"
    case dual = "Dual"
    var id: String { rawValue }
}

enum ObfuscationProfile: String, CaseIterable, Identifiable {
    case off = "Off"
    case light = "Light (Firewall)"
    case balanced = "Balanced"
    case gfw = "GFW (Aggressive)"
    var id: String { rawValue }
}

enum ConnectionState: Equatable {
    case disconnected
    case scanning
    case connecting
    case connected
    case error(String)

    var isActive: Bool {
        switch self {
        case .scanning, .connecting: return true
        default: return false
        }
    }
}

// MARK: - UserDefaults Keys

enum UDKey {
    static let protocol_    = "aether.protocol"
    static let scanMode     = "aether.scanMode"
    static let transport    = "aether.transportMode"
    static let ipMode       = "aether.ipMode"
    static let obfuscation  = "aether.obfuscation"
    static let bindAddress  = "aether.bindAddress"
    static let quickRec     = "aether.quickReconnect"
    static let ech          = "aether.echEnabled"
    static let fragment     = "aether.fragmentEnabled"
    static let fragSize     = "aether.fragmentSize"
    static let fragDelay    = "aether.fragmentDelay"
    static let keepalive    = "aether.keepalive"
    static let systemProxy  = "aether.systemProxyEnabled"
    static let showMenuBar  = "aether.showMenuBar"
}

// MARK: - Log Types

struct LogEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let level: LogLevel
    let message: String
}

enum LogLevel {
    case info
    case warn
    case error
    case success

    var color: Color {
        switch self {
        case .info: return .primary
        case .warn: return .orange
        case .error: return .red
        case .success: return .green
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .warn: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .success: return "checkmark.circle"
        }
    }
}
