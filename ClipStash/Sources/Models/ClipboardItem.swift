import AppKit
import Foundation

/// Represents the type of content stored in a clipboard item
enum ClipboardContentType: String, Codable {
    case plainText
    case richText
    case image
    case fileReference
}

/// A single clipboard history entry
struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let contentType: ClipboardContentType

    /// Plain text content (for text items, also used as preview for rich text)
    var textContent: String?

    /// Rich text data (RTF format)
    var richTextData: Data?

    /// Image data stored as PNG (nil if image is stored on disk)
    var imageData: Data?

    /// File URL string (for file references)
    var fileURL: String?

    /// Original file name (for file references)
    var fileName: String?

    /// Bundle identifier of the app where the copy originated
    var sourceAppBundleID: String?

    /// Display name of the source app
    var sourceAppName: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        contentType: ClipboardContentType,
        textContent: String? = nil,
        richTextData: Data? = nil,
        imageData: Data? = nil,
        fileURL: String? = nil,
        fileName: String? = nil,
        sourceAppBundleID: String? = nil,
        sourceAppName: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.contentType = contentType
        self.textContent = textContent
        self.richTextData = richTextData
        self.imageData = imageData
        self.fileURL = fileURL
        self.fileName = fileName
        self.sourceAppBundleID = sourceAppBundleID
        self.sourceAppName = sourceAppName
    }

    /// Returns a short preview string for display in the history list
    var preview: String {
        switch contentType {
        case .plainText, .richText:
            let text = textContent ?? ""
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > Constants.maxPreviewLength {
                return String(trimmed.prefix(Constants.maxPreviewLength)) + "..."
            }
            return trimmed

        case .image:
            return "[Image]"

        case .fileReference:
            return fileName ?? fileURL ?? "[File]"
        }
    }

    /// Returns the source app icon, or a default icon
    var sourceAppIcon: NSImage? {
        guard let bundleID = sourceAppBundleID,
              let appURL = NSWorkspace.shared.urlForApplication(
                  withBundleIdentifier: bundleID)
        else {
            return NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }

    /// Check if this item has the same content as another item (for deduplication)
    func hasSameContent(as other: ClipboardItem) -> Bool {
        guard contentType == other.contentType else { return false }
        switch contentType {
        case .plainText, .richText:
            return textContent == other.textContent
        case .image:
            return imageData == other.imageData
        case .fileReference:
            return fileURL == other.fileURL
        }
    }
}
