import AppKit
import Combine

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var aether: AetherManager?
    private var cancellables = Set<AnyCancellable>()

    func setup(with aether: AetherManager) {
        self.aether = aether

        aether.$showMenuBar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                if show {
                    self?.createStatusItem()
                } else {
                    self?.removeStatusItem()
                }
            }
            .store(in: &cancellables)

        aether.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateIcon()
                self?.updateMenuState()
            }
            .store(in: &cancellables)

        if aether.showMenuBar {
            createStatusItem()
        }
    }

    private func createStatusItem() {
        guard statusItem == nil else { return }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()
        buildMenu()
    }

    private func removeStatusItem() {
        guard let item = statusItem else { return }
        NSStatusBar.system.removeStatusItem(item)
        statusItem = nil
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }
        guard let aether = aether else { return }

        let iconName: String
        switch aether.connectionState {
        case .connected:
            iconName = "checkmark.circle.fill"
        case .scanning, .connecting:
            iconName = "arrow.triangle.2.circlepath"
        case .error:
            iconName = "exclamationmark.circle.fill"
        case .disconnected:
            iconName = "power"
        }

        let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Aether")
        image?.isTemplate = true
        button.image = image
    }

    private func buildMenu() {
        let menu = NSMenu()
        let isRunning = aether?.isRunning ?? false

        let statusItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: statusColor
        ]
        statusItem.attributedTitle = NSAttributedString(string: statusText, attributes: attrs)
        menu.addItem(statusItem)

        menu.addItem(.separator())

        let connectItem = NSMenuItem(title: isRunning ? "Disconnect" : "Connect", action: #selector(toggleConnection), keyEquivalent: "")
        connectItem.target = self
        connectItem.tag = 1
        menu.addItem(connectItem)

        menu.addItem(.separator())

        let proxyItem = NSMenuItem(title: "System Proxy", action: #selector(toggleProxy), keyEquivalent: "")
        proxyItem.target = self
        proxyItem.state = aether?.systemProxyEnabled == true ? .on : .off
        menu.addItem(proxyItem)

        menu.addItem(.separator())

        let showWindowItem = NSMenuItem(title: "Show Window", action: #selector(showWindow), keyEquivalent: "")
        showWindowItem.target = self
        menu.addItem(showWindowItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        self.statusItem?.menu = menu
    }

    private var statusText: String {
        guard let aether = aether else { return "IDLE" }
        switch aether.connectionState {
        case .connected: return "CONNECTED"
        case .scanning: return "SCANNING"
        case .connecting: return "CONNECTING"
        case .error: return "ERROR"
        case .disconnected: return "IDLE"
        }
    }

    private var statusColor: NSColor {
        guard let aether = aether else { return .secondaryLabelColor }
        switch aether.connectionState {
        case .connected: return .systemGreen
        case .scanning: return .systemOrange
        case .connecting: return .systemYellow
        case .error: return .systemRed
        case .disconnected: return .secondaryLabelColor
        }
    }

    private func updateMenuState() {
        guard let menu = statusItem?.menu else { return }
        let isRunning = aether?.isRunning ?? false

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: statusColor
        ]

        for item in menu.items {
            if !item.isEnabled && item.action == nil {
                item.attributedTitle = NSAttributedString(string: statusText, attributes: attrs)
            }
            if item.tag == 1 {
                item.title = isRunning ? "Disconnect" : "Connect"
            }
            if item.title == "System Proxy" {
                item.state = aether?.systemProxyEnabled == true ? .on : .off
            }
        }
    }

    @objc private func toggleConnection() {
        guard let aether = aether else { return }
        if aether.isRunning {
            aether.stop()
        } else {
            aether.start()
        }
    }

    @objc private func toggleProxy() {
        guard let aether = aether else { return }
        aether.systemProxyEnabled.toggle()
        updateMenuState()
    }

    @objc private func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            if window.isVisible {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
