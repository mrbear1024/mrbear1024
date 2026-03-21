import Foundation

/// Handles persistent storage of clipboard history items
final class ClipboardStore {
    private let historyURL: URL
    private let imagesDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let appDir = appSupport.appendingPathComponent(Constants.appSupportDirectoryName)
        let imagesDir = appDir.appendingPathComponent(Constants.imagesDirectoryName)

        // Create directories if needed
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)

        self.historyURL = appDir.appendingPathComponent(Constants.historyFilename)
        self.imagesDirectory = imagesDir

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    /// Load all clipboard items from disk
    func loadAll() -> [ClipboardItem] {
        guard FileManager.default.fileExists(atPath: historyURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: historyURL)
            var items = try decoder.decode([ClipboardItem].self, from: data)
            // Load image thumbnails for image items
            for i in items.indices where items[i].contentType == .image {
                items[i].imageData = loadImageData(for: items[i].id)
            }
            return items
        } catch {
            print("ClipStash: Failed to load history: \(error)")
            return []
        }
    }

    /// Save all clipboard items to disk
    func save(_ items: [ClipboardItem]) {
        // Strip image data before saving JSON (images stored separately)
        let itemsForJSON = items.map { item -> ClipboardItem in
            if item.contentType == .image {
                var copy = item
                copy.imageData = nil
                return copy
            }
            return item
        }

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            do {
                let data = try self.encoder.encode(itemsForJSON)
                try data.write(to: self.historyURL, options: .atomic)
            } catch {
                print("ClipStash: Failed to save history: \(error)")
            }
        }
    }

    /// Save image data to disk
    func saveImageData(_ data: Data, for id: UUID) {
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).png")
        DispatchQueue.global(qos: .utility).async {
            try? data.write(to: url, options: .atomic)
        }
    }

    /// Load image data from disk
    func loadImageData(for id: UUID) -> Data? {
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).png")
        return try? Data(contentsOf: url)
    }

    /// Delete image data from disk
    func deleteImageData(for id: UUID) {
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).png")
        try? FileManager.default.removeItem(at: url)
    }

    /// Clear all stored data
    func clearAll() {
        try? FileManager.default.removeItem(at: historyURL)
        if let contents = try? FileManager.default.contentsOfDirectory(
            at: imagesDirectory, includingPropertiesForKeys: nil)
        {
            for url in contents {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}
