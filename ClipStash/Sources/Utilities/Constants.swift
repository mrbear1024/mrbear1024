import Foundation

enum Constants {
    /// Maximum number of clipboard items to keep in history
    static let maxHistoryCount = 500

    /// Polling interval for clipboard changes (seconds)
    static let pollingInterval: TimeInterval = 0.5

    /// Global hotkey: Cmd+Shift+V
    /// Virtual key code for 'V' is 0x09 (9)
    static let hotkeyKeyCode: UInt32 = 0x09
    /// Modifiers: Cmd + Shift
    static let hotkeyModifiers: UInt32 = 0x0100 | 0x0200  // cmdKey | shiftKey

    /// Application support directory name
    static let appSupportDirectoryName = "ClipStash"

    /// History JSON filename
    static let historyFilename = "history.json"

    /// Images subdirectory name
    static let imagesDirectoryName = "images"

    /// Maximum text preview length in the list
    static let maxPreviewLength = 80

    /// Image thumbnail size for in-memory display
    static let thumbnailSize: CGFloat = 40

    /// History panel width
    static let panelWidth: CGFloat = 420

    /// History panel height
    static let panelHeight: CGFloat = 520
}
