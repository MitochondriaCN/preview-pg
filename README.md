# preview-pg

[中文版README](README_zh.md)——注意：中文版是正本，此为译本。

Periodically exports your PDF reading progress from macOS Preview as JSON.
You can also give it a folder so it only exports progress for PDFs inside that
folder.

An [Übersicht](https://github.com/felixhageloh/uebersicht) widget is included
as a demo use case.

**Made by Codex.** Praise be to Codex.

## Files

- `Sources/study_progress.swift`: reads PDF page counts, calculates Preview's
  view state, then writes `progress.json`.
- `scripts/run-study-progress.sh`: launchd entry point.
- `launchd/com.xianliticn.study-progress.plist`: LaunchAgent configured to run
  every 30 minutes.
- `tools/inspect_preview_viewstate.swift`: small debugging helper for Preview's
  view state plist.
- `widgets/study-progress.jsx`: Übersicht widget for displaying reading
  progress bars. It looks roughly like this: ~~alas, the grad-school entrance
  exam life~~  
![Widget demo](widget-demo.png)

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

The default folder scanned for PDFs is:

```text
~/Desktop/考研/基础期
```

As for why it is that folder, see [Origin](#origin).

The default output file is:

```text
~/Library/Application Support/UbersichtStudyProgress/progress.json
```

## Origin

While preparing for the postgraduate entrance exam, yours truly had to read a
lot of books, often in several tracks at once. That made progress annoying to
track, since I had to open Preview just to see the current page number. So I
asked Codex to make me this little tool. The prompt:

> Set up an automation. Let me describe what I need:
>
> On my Desktop there is a folder called "考研/基础期". It contains several books,
> all of which I need to study for the exam. Übersicht is already installed on
> my computer and can display widgets on the desktop. What I need now is:
>
> 1. Run once and only once per day: open these books and check what page they
>    are on in the Preview app, i.e. check my reading progress.
> 2. Write an Übersicht widget for the desktop, shown as progress bars, with
>    separate progress for each book.
> 3. The whole process should be invisible to me; ideally it should run in the
>    background without interrupting my work.
>
> ---
>
> Actually, collecting once every 30 minutes feels better.

And so it came to pass.

This project is purely for my own use, but if you are interested, please enjoy
it freely. Whatever criticism you offer, I shall accept; whatever PR you send,
I shall merge.
