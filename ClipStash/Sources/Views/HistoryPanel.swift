import AppKit
import SwiftUI

/// A floating, non-activating panel for displaying clipboard history
/// This panel does not steal focus from the currently active app
final class HistoryPanel: NSPanel {
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(
                x: 0, y: 0,
                width: Constants.panelWidth,
                height: Constants.panelHeight
            ),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
        self.animationBehavior = .utilityWindow

        self.contentView = contentView
    }

    /// Position the panel at the center of the current screen
    func showCentered() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.midY - frame.height / 2
        setFrameOrigin(NSPoint(x: x, y: y))

        makeKeyAndOrderFront(nil)
        // Ensure the search field gets focus
        if let firstResponder = contentView?.subviews.first {
            makeFirstResponder(firstResponder)
        }
    }

    /// Hide the panel
    func dismiss() {
        orderOut(nil)
    }

    override var canBecomeKey: Bool { true }
}
