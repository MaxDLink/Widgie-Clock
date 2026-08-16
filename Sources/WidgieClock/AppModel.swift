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
        static let useFahrenheit = "useFahrenheit"
    }

    static let weatherRefreshNanoseconds: UInt64 = 5 * 60 * 1_000_000_000

    @Published private(set) var isLocked: Bool
    @Published private(set) var startsAtLogin: Bool
    @Published private(set) var useFahrenheit: Bool
    @Published private(set) var temperatureText = "—"
    @Published private(set) var cityName = ""

    private let defaults: UserDefaults
    private weak var panel: NSPanel?
    private var weatherTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.locked: true,
            Key.useFahrenheit: true,
        ])
        isLocked = defaults.bool(forKey: Key.locked)
        useFahrenheit = defaults.bool(forKey: Key.useFahrenheit)
        startsAtLogin = SMAppService.mainApp.status == .enabled
        startWeatherLoop()
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

    var unitsMenuTitle: String {
        useFahrenheit ? "Switch to Celsius" : "Switch to Fahrenheit"
    }

    func toggleUnits() {
        useFahrenheit.toggle()
        defaults.set(useFahrenheit, forKey: Key.useFahrenheit)
        Task { await refreshWeather() }
    }

    func savedOrigin(width: CGFloat, height: CGFloat) -> CGPoint {
        guard defaults.bool(forKey: Key.hasPosition) else {
            let frame = NSScreen.main?.visibleFrame ?? .zero
            return CGPoint(x: frame.maxX - width - 24, y: frame.maxY - height - 24)
        }
        return CGPoint(x: defaults.double(forKey: Key.left), y: defaults.double(forKey: Key.bottom))
    }

    func startWeatherLoop() {
        weatherTask?.cancel()
        weatherTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                await self.refreshWeather()
                try? await Task.sleep(nanoseconds: Self.weatherRefreshNanoseconds)
            }
        }
    }

    func refreshWeather() async {
        do {
            let snapshot = try await WeatherService.fetch(useFahrenheit: useFahrenheit)
            temperatureText = "\(Int(snapshot.temperature.rounded()))°"
            cityName = snapshot.city
        } catch {
            if temperatureText == "—" {
                temperatureText = "—"
            }
        }
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
