import AppKit
import Combine
import ServiceManagement

@MainActor
final class AppModel: ObservableObject {
    private enum Key {
        static let locked = "locked"
        static let left = "left"
        static let bottom = "bottom"
        static let hasPosition = "hasPosition"
    }

    @Published private(set) var isLocked: Bool
    @Published private(set) var startsAtLogin: Bool

    private let defaults: UserDefaults
    private weak var panel: NSPanel?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [Key.locked: true])
        isLocked = defaults.bool(forKey: Key.locked)
        startsAtLogin = SMAppService.mainApp.status == .enabled
    }

    var lockMenuTitle: String {
        isLocked ? "Unlock to Move" : "Enable Click-Through"
    }

    func attach(panel: NSPanel) {
        self.panel = panel
        applyInteractionMode()
    }

    func toggleLocked() {
        isLocked.toggle()
        defaults.set(isLocked, forKey: Key.locked)
        applyInteractionMode()
        savePosition()
    }

    func toggleLaunchAtLogin() {
        do {
            if startsAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSSound.beep()
        }
        startsAtLogin = SMAppService.mainApp.status == .enabled
    }

    func savedOrigin(size: CGFloat) -> CGPoint {
        guard defaults.bool(forKey: Key.hasPosition) else {
            let frame = NSScreen.main?.visibleFrame ?? .zero
            return CGPoint(x: frame.maxX - size - 24, y: frame.maxY - size - 24)
        }
        return CGPoint(x: defaults.double(forKey: Key.left), y: defaults.double(forKey: Key.bottom))
    }

    func savePosition() {
        guard let origin = panel?.frame.origin else { return }
        defaults.set(origin.x, forKey: Key.left)
        defaults.set(origin.y, forKey: Key.bottom)
        defaults.set(true, forKey: Key.hasPosition)
    }

    private func applyInteractionMode() {
        panel?.ignoresMouseEvents = isLocked
        panel?.isMovableByWindowBackground = !isLocked
        if let panel, let contentView = panel.contentView {
            panel.invalidateCursorRects(for: contentView)
        }
    }
}
