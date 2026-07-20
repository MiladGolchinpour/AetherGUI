import Foundation

extension AetherManager {
    func addLog(level: LogLevel, message: String) {
        let entry = LogEntry(id: UUID(), timestamp: Date(), level: level, message: message)
        logs.append(entry)

        if message.contains("socks5 server listening") || message.contains("socks5 listening") {
            connectionState = .connected
            if systemProxyEnabled {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.enableSystemProxy()
                }
            }
        } else if message.contains("hunting for") {
            connectionState = .scanning
        } else if message.contains("selected") && (message.contains("gateway") || message.contains("endpoint")) {
            connectionState = .connecting
        } else if message.contains("handshake successful") {
            connectionState = .connecting
        }

        if logs.count > 1000 { logs.removeFirst(200) }
    }
}
