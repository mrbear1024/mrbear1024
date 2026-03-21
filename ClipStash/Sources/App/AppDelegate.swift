import AppKit
import SwiftUI

/// Application delegate that manages the clipboard monitor, global hotkey, and history panel
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = ClipboardStore()
    private lazy var monitor = ClipboardMonitor(store: store)
    private let hotkeyManager = HotkeyManager()
    private var panel: HistoryPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start clipboard monitoring
        monitor.start()

        // Register global hotkey (Cmd+Shift+V)
        hotkeyManager.register { [weak self] in
            self?.togglePanel()
        }

        // Build the history panel
        setupPanel()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
        hotkeyManager.unregister()
    }

    // MARK: - Panel Management

    private func setupPanel() {
        let historyView = HistoryView(
            monitor: monitor,
            onSelect: { [weak self] item in
                self?.selectItem(item)
            },
            onDismiss: { [weak self] in
                self?.hidePanel()
            }
        )

        let hostingView = NSHostingView(rootView: historyView)
        panel = HistoryPanel(contentView: hostingView)
    }

    func togglePanel() {
        guard let panel else { return }
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        panel?.showCentered()
    }

    private func hidePanel() {
        panel?.dismiss()
    }

    private func selectItem(_ item: ClipboardItem) {
        // Write selected item back to clipboard
        monitor.writeToClipboard(item)
        // Dismiss the panel
        hidePanel()
    }

    // MARK: - Menu Actions

    @objc func clearHistory() {
        monitor.clearHistory()
    }
}
