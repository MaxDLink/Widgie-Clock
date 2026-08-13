# Widgie Clock for Mac

A floating analog clock for macOS. It stays above normal windows and uses click-through by default.

## Requirements

- macOS 13 or later
- Swift 6 or Xcode 16 or later

## Run

```sh
swift run WidgieClock
```

## Build the app

```sh
./scripts/build-app.sh
open ".build/Widgie Clock.app"
```

The app is unsigned. macOS may require you to approve it in **System Settings → Privacy & Security**.

## Menu bar

| Item | Action |
|---|---|
| **Unlock to Move** | Let the clock receive clicks and drag it to a new position |
| **Enable Click-Through** | Pass clicks through to apps below the clock |
| **Start at Login** | Add or remove the packaged app as a login item |
| **Quit Widgie Clock** | Quit the app |

Position and click-through state are stored in macOS user defaults.

## License

MIT
