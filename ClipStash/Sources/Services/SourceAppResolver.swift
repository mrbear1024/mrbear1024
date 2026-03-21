import AppKit

/// Resolves information about the currently active (frontmost) application
enum SourceAppResolver {
    /// Returns the bundle ID and display name of the current frontmost app
    static func currentSourceApp() -> (bundleID: String?, name: String?) {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return (nil, nil)
        }
        return (app.bundleIdentifier, app.localizedName)
    }

    /// Returns the icon for an app given its bundle identifier
    static func icon(for bundleID: String) -> NSImage? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}
