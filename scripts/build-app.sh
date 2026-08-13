#!/bin/sh
set -eu

swift build -c release

APP_DIR=".build/Widgie Clock.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

mkdir -p "$MACOS_DIR"
cp ".build/release/WidgieClock" "$MACOS_DIR/WidgieClock"
cp "Support/Info.plist" "$CONTENTS_DIR/Info.plist"

echo "$APP_DIR"
