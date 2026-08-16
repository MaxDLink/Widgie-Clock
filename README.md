# Widgie Clock

A floating analog clock with current outside temperature.

It stays above other windows. Drag the clock to move it. Use the tray icon if you want click-through instead.

Temperature comes from [Open-Meteo](https://open-meteo.com/) (no API key). Location is inferred from public IP via [ipwho.is](https://ipwho.is/). Weather refreshes every 5 minutes.

## Requirements

- Windows 10 or later
- Node.js 18 or later

## Run

```powershell
cd windows
npm install
npm start
```

The widget appears in the top-right of the primary display. Use the **tray icon** (near the clock in the taskbar) for the menu.

## Package an installer

```powershell
cd windows
npm install
npm run dist
```

Output lands in `windows/dist/`:

- portable `.exe` you can run without installing
- NSIS installer

## Tray menu

| Item | Action |
|---|---|
| **Unlock to Move** | Let the clock receive clicks and drag it to a new position |
| **Enable Click-Through** | Pass clicks through to apps below the clock |
| **Switch to Celsius / Fahrenheit** | Toggle temperature units |
| **Refresh Weather** | Fetch temperature immediately |
| **Start at Login** | Launch the widget when Windows signs in |
| **Quit Widgie Clock** | Quit the app |

Position, lock state, units, and login setting are stored in the Electron user-data folder.

## Project layout

```
windows/                 Desktop widget
  src/main.js            Frameless always-on-top window + tray
  src/renderer/          Analog face, digital time, temperature
  test/                  Clock-math tests
```

## License

MIT. Original work © 2026 Eric Link.
