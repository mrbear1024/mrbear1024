import SwiftUI

/// A single row in the clipboard history list
struct ClipboardItemRow: View {
    let item: ClipboardItem
    let index: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Source app icon
            if let icon = item.sourceAppIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .cornerRadius(6)
            } else {
                Image(systemName: "doc.on.clipboard")
                    .frame(width: 28, height: 28)
                    .foregroundColor(.secondary)
            }

            // Content preview
            VStack(alignment: .leading, spacing: 2) {
                ContentPreview(item: item)

                // Timestamp
                Text(item.timestamp, style: .relative)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Keyboard shortcut badge (⌘1 through ⌘9)
            if index < 9 {
                Text("⌘\(index + 1)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.15))
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
