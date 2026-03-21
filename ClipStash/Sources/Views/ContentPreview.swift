import SwiftUI

/// Displays a preview of clipboard item content based on its type
struct ContentPreview: View {
    let item: ClipboardItem

    var body: some View {
        switch item.contentType {
        case .plainText, .richText:
            Text(item.preview)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .image:
            if let data = item.imageData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.thumbnailSize)
                    .cornerRadius(4)
            } else {
                Label("Image", systemImage: "photo")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

        case .fileReference:
            HStack(spacing: 6) {
                Image(systemName: "doc")
                    .foregroundColor(.secondary)
                Text(item.fileName ?? item.fileURL ?? "File")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
