import AppKit
import Combine

/// Monitors the system clipboard for changes and maintains a history of clipboard items
final class ClipboardMonitor: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private var skipNextChange = false
    private let store: ClipboardStore

    init(store: ClipboardStore) {
        self.store = store
        self.items = store.loadAll()
    }

    /// Start monitoring the clipboard
    func start() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(
            withTimeInterval: Constants.pollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    /// Stop monitoring the clipboard
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Write an item back to the system clipboard (for pasting a history item)
    func writeToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.contentType {
        case .plainText:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }

        case .richText:
            // Write both RTF and plain text for maximum compatibility
            if let rtfData = item.richTextData {
                pasteboard.setData(rtfData, forType: .rtf)
            }
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }

        case .image:
            if let data = item.imageData ?? store.loadImageData(for: item.id) {
                pasteboard.setData(data, forType: .png)
                // Also set as TIFF for broader compatibility
                if let image = NSImage(data: data), let tiffData = image.tiffRepresentation {
                    pasteboard.setData(tiffData, forType: .tiff)
                }
            }

        case .fileReference:
            if let urlString = item.fileURL, let url = URL(string: urlString) {
                pasteboard.writeObjects([url as NSURL])
            }
        }

        // Skip the next clipboard change to avoid re-capturing our own write
        skipNextChange = true
        lastChangeCount = pasteboard.changeCount
    }

    /// Clear all history
    func clearHistory() {
        items.removeAll()
        store.clearAll()
    }

    // MARK: - Private

    private func checkForChanges() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        if skipNextChange {
            skipNextChange = false
            return
        }

        guard let item = readClipboardItem(from: pasteboard) else { return }

        // Deduplicate: skip if identical to the most recent item
        if let mostRecent = items.first, mostRecent.hasSameContent(as: item) {
            return
        }

        items.insert(item, at: 0)

        // Prune if over limit
        if items.count > Constants.maxHistoryCount {
            let removed = items.removeLast()
            store.deleteImageData(for: removed.id)
        }

        // Persist
        store.save(items)
        if item.contentType == .image, let data = item.imageData {
            store.saveImageData(data, for: item.id)
        }
    }

    private func readClipboardItem(from pasteboard: NSPasteboard) -> ClipboardItem? {
        let (bundleID, appName) = SourceAppResolver.currentSourceApp()

        // Check for file URLs first
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL], let url = urls.first {
            return ClipboardItem(
                contentType: .fileReference,
                fileURL: url.absoluteString,
                fileName: url.lastPathComponent,
                sourceAppBundleID: bundleID,
                sourceAppName: appName
            )
        }

        // Check for images
        if let imageData = pasteboard.data(forType: .png) {
            return ClipboardItem(
                contentType: .image,
                imageData: imageData,
                sourceAppBundleID: bundleID,
                sourceAppName: appName
            )
        }
        if let tiffData = pasteboard.data(forType: .tiff),
           let image = NSImage(data: tiffData),
           let pngData = image.pngRepresentation
        {
            return ClipboardItem(
                contentType: .image,
                imageData: pngData,
                sourceAppBundleID: bundleID,
                sourceAppName: appName
            )
        }

        // Check for rich text
        if let rtfData = pasteboard.data(forType: .rtf) {
            let plainText = pasteboard.string(forType: .string)
            return ClipboardItem(
                contentType: .richText,
                textContent: plainText,
                richTextData: rtfData,
                sourceAppBundleID: bundleID,
                sourceAppName: appName
            )
        }

        // Check for plain text
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            return ClipboardItem(
                contentType: .plainText,
                textContent: text,
                sourceAppBundleID: bundleID,
                sourceAppName: appName
            )
        }

        return nil
    }
}

// MARK: - NSImage PNG Helper
extension NSImage {
    var pngRepresentation: Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}
