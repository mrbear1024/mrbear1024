import SwiftUI

@main
struct ClipStashApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("ClipStash", systemImage: "doc.on.clipboard") {
            VStack(alignment: .leading, spacing: 4) {
                Button("Show History (⌘⇧V)") {
                    appDelegate.togglePanel()
                }
                .keyboardShortcut("v", modifiers: [.command, .shift])

                Divider()

                Button("Clear History") {
                    appDelegate.clearHistory()
                }

                Divider()

                Button("Quit ClipStash") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
    }
}
