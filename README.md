# Widgie Clock

A floating analog clock with current outside temperature. Forked from [ericlink/widgie-clock-mac](https://github.com/ericlink/widgie-clock-mac) and extended for Windows.

It stays above normal windows. Drag the clock to move it. Use the tray / menu bar if you want click-through instead.

Temperature comes from [Open-Meteo](https://open-meteo.com/) (no API key). Location is inferred from public IP via [ipwho.is](https://ipwho.is/). Weather refreshes every 5 minutes.

## Windows

### Requirements

- Windows 10 or later
- Node.js 18 or later

### Run

```powershell
cd windows
npm install
npm start
```

The widget appears in the top-right of the primary display. Use the **tray icon** (near the clock in the taskbar) for the menu.

### Package an installer

```powershell
cd windows
npm install
npm run dist
```

Output lands in `windows/dist/`:

- portable `.exe` you can run without installing
- NSIS installer

### Tray menu

| Item | Action |
|---|---|
| **Unlock to Move** | Let the clock receive clicks and drag it to a new position |
| **Enable Click-Through** | Pass clicks through to apps below the clock |
| **Switch to Celsius / Fahrenheit** | Toggle temperature units |
| **Refresh Weather** | Fetch temperature immediately |
| **Start at Login** | Launch the widget when Windows signs in |
| **Quit Widgie Clock** | Quit the app |

Position, lock state, units, and login setting are stored in the Electron user-data folder.

## macOS

### Requirements

- macOS 13 or later
- Swift 6 or Xcode 16 or later

### Run

```sh
swift run WidgieClock
```

### Build the app

```sh
./scripts/build-app.sh
open ".build/Widgie Clock.app"
```

The app is unsigned. macOS may require you to approve it in **System Settings → Privacy & Security**.

### Menu bar

| Item | Action |
|---|---|
| **Unlock to Move** | Let the clock receive clicks and drag it to a new position |
| **Enable Click-Through** | Pass clicks through to apps below the clock |
| **Switch to Celsius / Fahrenheit** | Toggle temperature units |
| **Refresh Weather** | Fetch temperature immediately |
| **Start at Login** | Add or remove the packaged app as a login item |
| **Quit Widgie Clock** | Quit the app |

Position, click-through, and unit preference are stored in macOS user defaults.

## Project layout

```
Sources/WidgieClock/     macOS SwiftUI / AppKit widget
Tests/WidgieClockTests/  Clock math + weather JSON tests
Support/Info.plist       macOS app bundle metadata
scripts/build-app.sh     Packages the macOS .app
windows/                 Electron widget for Windows
  src/main.js            Frameless always-on-top window + tray
  src/renderer/          Analog face, digital time, temperature
  test/                  Clock-math parity test
```

## License

MIT. Original macOS clock © 2026 Eric Link.
