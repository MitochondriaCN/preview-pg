# preview-pg

Preview reading progress collector and Übersicht widget.

This project reads macOS Preview's saved PDF view state, calculates reading
progress for PDFs in a study folder, writes a JSON file, and displays it with
an Übersicht desktop widget.

## Files

- `Sources/study_progress.swift`: reads PDF page counts and Preview view state,
  then writes `progress.json`.
- `widgets/study-progress.jsx`: Übersicht widget that renders progress bars.
- `scripts/run-study-progress.sh`: launchd entry script.
- `launchd/com.xianliticn.study-progress.plist`: LaunchAgent configured to run
  every 30 minutes.
- `tools/inspect_preview_viewstate.swift`: small debugging helper for Preview's
  view state plist.

## Build

```sh
mkdir -p .build/swift-module-cache
swiftc -module-cache-path .build/swift-module-cache \
  Sources/study_progress.swift \
  -o .build/study-progress-refresh
```

## Install Manually

```sh
APP_DIR="$HOME/Library/Application Support/UbersichtStudyProgress"
WIDGET_DIR="$HOME/Library/Application Support/Übersicht/widgets"

mkdir -p "$APP_DIR" "$WIDGET_DIR" "$HOME/Library/LaunchAgents"
cp .build/study-progress-refresh "$APP_DIR/study-progress-refresh"
cp scripts/run-study-progress.sh "$APP_DIR/run-daily.sh"
cp widgets/study-progress.jsx "$WIDGET_DIR/study-progress.jsx"
cp launchd/com.xianliticn.study-progress.plist "$HOME/Library/LaunchAgents/"
chmod 755 "$APP_DIR/study-progress-refresh" "$APP_DIR/run-daily.sh"
launchctl unload "$HOME/Library/LaunchAgents/com.xianliticn.study-progress.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.xianliticn.study-progress.plist"
```

The default source folder is:

```text
~/Desktop/考研/基础期
```

The default output file is:

```text
~/Library/Application Support/UbersichtStudyProgress/progress.json
```
