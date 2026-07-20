import Foundation
import SwiftUI
import Combine

class AetherManager: ObservableObject {
    @Published var connectionState: ConnectionState = .disconnected
    @Published var logs: [LogEntry] = []
    @Published var needsReload: Bool = false

    @Published var selectedProtocol: ProtocolMode {
        didSet { UserDefaults.standard.set(selectedProtocol.rawValue, forKey: UDKey.protocol_) }
    }
    @Published var scanMode: ScanMode {
        didSet { UserDefaults.standard.set(scanMode.rawValue, forKey: UDKey.scanMode) }
    }
    @Published var transportMode: TransportMode {
        didSet { UserDefaults.standard.set(transportMode.rawValue, forKey: UDKey.transport) }
    }
    @Published var ipMode: IPMode {
        didSet { UserDefaults.standard.set(ipMode.rawValue, forKey: UDKey.ipMode) }
    }
    @Published var obfuscation: ObfuscationProfile {
        didSet { UserDefaults.standard.set(obfuscation.rawValue, forKey: UDKey.obfuscation) }
    }
    @Published var bindAddress: String {
        didSet {
            UserDefaults.standard.set(bindAddress, forKey: UDKey.bindAddress)
            if isRunning && bindAddress != oldValue { restart() }
        }
    }
    @Published var quickReconnect: Bool {
        didSet { UserDefaults.standard.set(quickReconnect, forKey: UDKey.quickRec) }
    }
    @Published var echEnabled: Bool {
        didSet { UserDefaults.standard.set(echEnabled, forKey: UDKey.ech) }
    }
    @Published var fragmentEnabled: Bool {
        didSet { UserDefaults.standard.set(fragmentEnabled, forKey: UDKey.fragment) }
    }
    @Published var fragmentSize: String {
        didSet { UserDefaults.standard.set(fragmentSize, forKey: UDKey.fragSize) }
    }
    @Published var fragmentDelay: String {
        didSet { UserDefaults.standard.set(fragmentDelay, forKey: UDKey.fragDelay) }
    }
    @Published var keepalive: Int {
        didSet { UserDefaults.standard.set(keepalive, forKey: UDKey.keepalive) }
    }
    @Published var systemProxyEnabled: Bool {
        didSet {
            UserDefaults.standard.set(systemProxyEnabled, forKey: UDKey.systemProxy)
            if systemProxyEnabled && connectionState == .connected {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.enableSystemProxy()
                }
            } else if !systemProxyEnabled && systemProxyActive {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.disableSystemProxy()
                }
            }
        }
    }

    @Published var systemProxyActive: Bool = false

    @Published var showMenuBar: Bool {
        didSet { UserDefaults.standard.set(showMenuBar, forKey: UDKey.showMenuBar) }
    }

    private var process: Process?
    private var userStopped: Bool = false

    var isRunning: Bool {
        if let proc = process { return proc.isRunning }
        return false
    }

    init() {
        let d = UserDefaults.standard

        let savedProtocol = d.string(forKey: UDKey.protocol_) ?? ProtocolMode.masque.rawValue
        self.selectedProtocol = ProtocolMode(rawValue: savedProtocol) ?? .masque

        let savedScan = d.string(forKey: UDKey.scanMode) ?? ScanMode.turbo.rawValue
        self.scanMode = ScanMode(rawValue: savedScan) ?? .turbo

        let savedTransport = d.string(forKey: UDKey.transport) ?? TransportMode.quic.rawValue
        self.transportMode = TransportMode(rawValue: savedTransport) ?? .quic

        let savedIP = d.string(forKey: UDKey.ipMode) ?? IPMode.ipv4.rawValue
        self.ipMode = IPMode(rawValue: savedIP) ?? .ipv4

        let savedObf = d.string(forKey: UDKey.obfuscation) ?? ObfuscationProfile.balanced.rawValue
        self.obfuscation = ObfuscationProfile(rawValue: savedObf) ?? .balanced

        self.bindAddress = d.string(forKey: UDKey.bindAddress) ?? "127.0.0.1:1819"
        self.quickReconnect = d.object(forKey: UDKey.quickRec) != nil ? d.bool(forKey: UDKey.quickRec) : true
        self.echEnabled = d.bool(forKey: UDKey.ech)
        self.fragmentEnabled = d.bool(forKey: UDKey.fragment)
        self.fragmentSize = d.string(forKey: UDKey.fragSize) ?? "16-32"
        self.fragmentDelay = d.string(forKey: UDKey.fragDelay) ?? "2-10"
        self.keepalive = d.object(forKey: UDKey.keepalive) != nil ? d.integer(forKey: UDKey.keepalive) : 5
        self.systemProxyEnabled = d.bool(forKey: UDKey.systemProxy)
        self.showMenuBar = d.bool(forKey: UDKey.showMenuBar)
    }

    func markSettingsChanged() {
        if isRunning { needsReload = true }
    }

    func reload() {
        needsReload = false
        if isRunning { restart() }
    }

    // MARK: - Build args

    func buildArguments() -> [String] {
        var args: [String] = []
        args.append(contentsOf: ["--bind", bindAddress])

        switch selectedProtocol {
        case .masque:
            args.append("--masque")
            if transportMode == .h2 { args.append("--h2") }
        case .wireguard: args.append("--wg")
        case .gool: args.append("--gool")
        }

        args.append(contentsOf: ["--scan", scanMode.rawValue.lowercased()])

        switch ipMode {
        case .ipv4: args.append("-4")
        case .ipv6: args.append("-6")
        case .dual: args.append("--dual")
        }

        switch obfuscation {
        case .off: args.append(contentsOf: ["--noize", "off"])
        case .light: args.append(contentsOf: ["--noize", "light"])
        case .balanced: args.append(contentsOf: ["--noize", "balanced"])
        case .gfw: args.append(contentsOf: ["--noize", "gfw"])
        }

        args.append(contentsOf: quickReconnect ? ["--quick-reconnect"] : ["--no-quick-reconnect"])

        if echEnabled && selectedProtocol == .masque {
            args.append(contentsOf: ["--ech", "auto"])
        }

        if fragmentEnabled && transportMode == .h2 {
            args.append(contentsOf: ["--fragment", "--fragment-size", fragmentSize, "--fragment-delay", fragmentDelay])
        }

        if selectedProtocol == .wireguard || selectedProtocol == .gool {
            args.append(contentsOf: ["--keepalive", String(keepalive)])
        }

        return args
    }

    // MARK: - Start / Stop / Restart

    func start() {
        guard !isRunning else { return }
        userStopped = false
        needsReload = false

        guard let binaryPath = findAetherBinary() else {
            addLog(level: .error, message: "Could not find aether binary in app bundle. Place it in the app's Resources folder.")
            connectionState = .error("Binary not found")
            return
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: binaryPath)
        proc.arguments = buildArguments()

        let fm = FileManager.default
        let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        let appSupportAether = (supportDir as NSString).appendingPathComponent("Aether")
        if !fm.fileExists(atPath: appSupportAether) {
            try? fm.createDirectory(atPath: appSupportAether, withIntermediateDirectories: true)
        }
        proc.currentDirectoryURL = URL(fileURLWithPath: appSupportAether)

        let outPipe = Pipe()
        let errPipe = Pipe()
        proc.standardOutput = outPipe
        proc.standardError = errPipe

        outPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async { self?.addLog(level: .info, message: str.trimmingCharacters(in: .newlines)) }
            }
        }

        errPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async { self?.addLog(level: .info, message: str.trimmingCharacters(in: .newlines)) }
            }
        }

        proc.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.connectionState = .disconnected
                if self.systemProxyActive {
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        self?.disableSystemProxy()
                    }
                }
                if !self.userStopped {
                    self.addLog(level: .info, message: "Aether process exited (status \(process.terminationStatus))")
                }
                self.process = nil
            }
        }

        do {
            connectionState = .scanning
            addLog(level: .info, message: "Starting aether with args: \(proc.arguments?.joined(separator: " ") ?? "")")
            try proc.run()
            process = proc
        } catch {
            addLog(level: .error, message: "Failed to start aether: \(error.localizedDescription)")
            connectionState = .error(error.localizedDescription)
        }
    }

    func stop() {
        userStopped = true
        process?.terminate()
        process = nil
        connectionState = .disconnected
        if systemProxyActive {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.disableSystemProxy()
            }
        }
        addLog(level: .info, message: "Stopped aether")
    }

    func restart() {
        let wasRunning = isRunning
        if isRunning {
            userStopped = true
            process?.terminate()
            process = nil
            if systemProxyActive {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.disableSystemProxy()
                }
            }
        }
        needsReload = false
        if wasRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.start()
            }
        }
    }

    func clearLogs() { logs.removeAll() }

    // MARK: - Binary discovery

    private func findAetherBinary() -> String? {
        let fm = FileManager.default

        if let res = Bundle.main.resourcePath {
            let bundled = (res as NSString).appendingPathComponent("aether")
            if fm.fileExists(atPath: bundled) {
                try? fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: bundled)
                if fm.isExecutableFile(atPath: bundled) { return bundled }
            }
        }

        let fallbacks = [
            NSHomeDirectory() + "/Library/Application Support/Aether/aether",
            "/usr/local/bin/aether",
        ]
        for path in fallbacks {
            if fm.isExecutableFile(atPath: path) { return path }
        }
        return nil
    }
}
