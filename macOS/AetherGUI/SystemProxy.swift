import Foundation

extension AetherManager {
    func enableSystemProxy() {
        let port = parseSocksPort()
        guard let service = activeNetworkService() else {
            DispatchQueue.main.async { self.addLog(level: .error, message: "Could not find active network service for proxy") }
            return
        }
        do {
            try networksetup(["-setsocksfirewallproxy", service, "127.0.0.1", "\(port)"])
            try networksetup(["-setsocksfirewallproxystate", service, "on"])
            DispatchQueue.main.async {
                self.systemProxyActive = true
                self.addLog(level: .success, message: "System SOCKS proxy enabled on \(service) → 127.0.0.1:\(port)")
            }
        } catch {
            DispatchQueue.main.async { self.addLog(level: .error, message: "Failed to enable system proxy: \(error.localizedDescription)") }
        }
    }

    func disableSystemProxy() {
        guard let service = activeNetworkService() else {
            DispatchQueue.main.async { self.addLog(level: .warn, message: "No active network service found for proxy disable") }
            return
        }
        do {
            try networksetup(["-setsocksfirewallproxystate", service, "off"])
            try networksetup(["-setwebproxystate", service, "off"])
            try networksetup(["-setsecurewebproxystate", service, "off"])
            DispatchQueue.main.async {
                self.systemProxyActive = false
                self.addLog(level: .success, message: "System proxy disabled on \(service)")
            }
        } catch {
            DispatchQueue.main.async { self.addLog(level: .error, message: "Failed to disable system proxy: \(error.localizedDescription)") }
        }
    }

    private func parseSocksPort() -> Int {
        let parts = bindAddress.split(separator: ":")
        if let last = parts.last, let port = Int(last) { return port }
        return 1819
    }

    private func activeNetworkService() -> String? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        proc.arguments = ["-listallnetworkservices"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = FileHandle.nullDevice
        do {
            try proc.run()
            proc.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return nil }
            for line in output.components(separatedBy: "\n") {
                let t = line.trimmingCharacters(in: .whitespaces)
                if t.isEmpty || t.hasPrefix("***") || t == "An asterisk" { continue }
                if t.lowercased().contains("wi-fi") || t.lowercased().contains("wifi") { return t }
            }
            for line in output.components(separatedBy: "\n") {
                let t = line.trimmingCharacters(in: .whitespaces)
                if !t.isEmpty && !t.hasPrefix("***") && !t.hasPrefix("An asterisk") { return t }
            }
        } catch {}
        return nil
    }

    private func networksetup(_ args: [String]) throws {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        proc.arguments = args
        proc.standardOutput = FileHandle.nullDevice
        proc.standardError = FileHandle.nullDevice
        try proc.run()
        proc.waitUntilExit()
        guard proc.terminationStatus == 0 else {
            throw NSError(domain: "networksetup", code: Int(proc.terminationStatus),
                          userInfo: [NSLocalizedDescriptionKey: "networksetup failed"])
        }
    }
}
