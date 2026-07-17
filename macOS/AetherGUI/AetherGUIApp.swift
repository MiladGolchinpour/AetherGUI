import SwiftUI

@main
struct AetherGUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var aether = AetherManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(aether)
                .frame(minWidth: 600, minHeight: 560)
                .onAppear {
                    appDelegate.menuBarManager.setup(with: aether)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 620, height: 600)
        .defaultPosition(.center)

        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(aether)
        }
        #endif
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let menuBarManager = MenuBarManager()
}
