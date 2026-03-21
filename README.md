# ClipStash

A native macOS clipboard history manager, similar to uPaste.

## Features

- **Menu bar app** — runs in the background with no Dock icon
- **Clipboard monitoring** — automatically captures text, images, and file references
- **Global hotkey** — press `⌘⇧V` to show the history panel
- **Search** — filter clipboard history with the search bar
- **Quick access** — use `⌘1` through `⌘9` to select items instantly
- **Keyboard navigation** — arrow keys to navigate, Enter to select, Escape to dismiss
- **Source app tracking** — shows the icon of the app where each item was copied
- **Persistent storage** — history survives app restarts
- **Deduplication** — consecutive identical copies are automatically merged

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Build

```bash
# Install XcodeGen if you don't have it
brew install xcodegen

# Generate Xcode project and build
cd ClipStash
xcodegen generate
xcodebuild -project ClipStash.xcodeproj -scheme ClipStash -configuration Release build

# Or use the Makefile from the repo root
make build
```

## Usage

1. Launch ClipStash — it appears as a clipboard icon in the menu bar
2. Copy or cut content as usual in any app
3. Press `⌘⇧V` to open the history panel
4. Navigate with arrow keys or search to find an item
5. Press `Enter` or `⌘1`-`⌘9` to select — the item is copied to your clipboard
6. Press `⌘V` to paste as normal

## Architecture

```
ClipStash/
├── Sources/
│   ├── App/           # App entry point, AppDelegate, Info.plist
│   ├── Models/        # ClipboardItem data model
│   ├── Services/      # ClipboardMonitor, ClipboardStore, HotkeyManager
│   ├── Views/         # HistoryPanel, HistoryView, ClipboardItemRow
│   └── Utilities/     # Constants
├── Resources/         # Asset catalogs
├── project.yml        # XcodeGen project spec
└── Makefile           # Build convenience targets
```

## Tech Stack

- **Swift 5.9** + **SwiftUI** — native macOS UI
- **AppKit** — NSPasteboard, NSPanel, NSStatusItem
- **Carbon API** — global hotkey registration
- **Zero external dependencies** — pure macOS SDK
