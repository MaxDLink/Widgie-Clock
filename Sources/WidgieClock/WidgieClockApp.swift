import AppKit
import SwiftUI

@main
struct WidgieClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model: AppModel

    init() {
        let model = AppModel()
        _model = StateObject(wrappedValue: model)
        AppDelegate.model = model
    }

    var body: some Scene {
        MenuBarExtra("Widgie Clock", systemImage: "clock") {
            Button(model.lockMenuTitle) {
                model.toggleLocked()
            }

            Toggle("Start at Login", isOn: Binding(
                get: { model.startsAtLogin },
                set: { _ in model.toggleLaunchAtLogin() }
            ))

            Divider()

            Button("Quit Widgie Clock") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static var model: AppModel?
    private var panelController: ClockPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        guard let model = Self.model else { return }
        panelController = ClockPanelController(model: model)
    }
}
