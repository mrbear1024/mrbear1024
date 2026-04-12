import SwiftUI

/// Main history view with search bar and scrollable list of clipboard items
struct HistoryView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var selectedIndex = 0
    let onSelect: (ClipboardItem) -> Void
    let onDismiss: () -> Void

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return monitor.items
        }
        return monitor.items.filter { item in
            switch item.contentType {
            case .plainText, .richText:
                return item.textContent?.localizedCaseInsensitiveContains(searchText) ?? false
            case .fileReference:
                let name = item.fileName ?? item.fileURL ?? ""
                return name.localizedCaseInsensitiveContains(searchText)
            case .image:
                return "image".localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search clipboard history...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .onSubmit {
                        selectCurrentItem()
                    }
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Item list
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text(monitor.items.isEmpty ? "Clipboard history is empty" : "No matching items")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) {
                                index, item in
                                ClipboardItemRow(
                                    item: item,
                                    index: index,
                                    isSelected: index == selectedIndex
                                )
                                .id(index)
                                .onTapGesture {
                                    selectedIndex = index
                                    onSelect(item)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: selectedIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: Constants.panelWidth, height: Constants.panelHeight)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .onAppear {
            selectedIndex = 0
        }
        .onChange(of: searchText) { _ in
            selectedIndex = 0
        }
        // Handle keyboard events
        .background(
            KeyEventHandlingView(
                onArrowUp: {
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                },
                onArrowDown: {
                    if selectedIndex < filteredItems.count - 1 {
                        selectedIndex += 1
                    }
                },
                onEnter: {
                    selectCurrentItem()
                },
                onEscape: {
                    onDismiss()
                },
                onCmdNumber: { number in
                    let index = number - 1
                    if index >= 0 && index < filteredItems.count {
                        onSelect(filteredItems[index])
                    }
                }
            )
        )
    }

    private func selectCurrentItem() {
        guard !filteredItems.isEmpty, selectedIndex < filteredItems.count else { return }
        onSelect(filteredItems[selectedIndex])
    }
}

// MARK: - Visual Effect View (for translucent background)

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Key Event Handling

struct KeyEventHandlingView: NSViewRepresentable {
    let onArrowUp: () -> Void
    let onArrowDown: () -> Void
    let onEnter: () -> Void
    let onEscape: () -> Void
    let onCmdNumber: (Int) -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onArrowUp = onArrowUp
        view.onArrowDown = onArrowDown
        view.onEnter = onEnter
        view.onEscape = onEscape
        view.onCmdNumber = onCmdNumber
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.onArrowUp = onArrowUp
        nsView.onArrowDown = onArrowDown
        nsView.onEnter = onEnter
        nsView.onEscape = onEscape
        nsView.onCmdNumber = onCmdNumber
    }
}

class KeyCaptureView: NSView {
    var onArrowUp: (() -> Void)?
    var onArrowDown: (() -> Void)?
    var onEnter: (() -> Void)?
    var onEscape: (() -> Void)?
    var onCmdNumber: ((Int) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Cmd+1 through Cmd+9
        if modifiers.contains(.command) {
            if let characters = event.charactersIgnoringModifiers,
               let number = Int(characters), number >= 1 && number <= 9
            {
                onCmdNumber?(number)
                return
            }
        }

        switch event.keyCode {
        case 126:  // Up arrow
            onArrowUp?()
        case 125:  // Down arrow
            onArrowDown?()
        case 36:  // Return/Enter
            onEnter?()
        case 53:  // Escape
            onEscape?()
        default:
            super.keyDown(with: event)
        }
    }
}
