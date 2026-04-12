import Carbon
import Cocoa

/// Manages global hotkey registration using the Carbon API
/// Default hotkey: Cmd+Shift+V
final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var callback: (() -> Void)?

    /// Signature identifier for our hotkey (ASCII "CLPS")
    private let signature: OSType = 0x434C5053

    deinit {
        unregister()
    }

    /// Register the global hotkey with the given callback
    func register(
        keyCode: UInt32 = Constants.hotkeyKeyCode,
        modifiers: UInt32 = Constants.hotkeyModifiers,
        handler: @escaping () -> Void
    ) {
        self.callback = handler

        // Define the event type we want to listen for
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Install the event handler
        let handlerResult = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard handlerResult == noErr else {
            print("ClipStash: Failed to install event handler: \(handlerResult)")
            return
        }

        // Define the hotkey ID
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)

        // Register the hotkey
        let registerResult = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerResult != noErr {
            print("ClipStash: Failed to register hotkey: \(registerResult)")
        }
    }

    /// Unregister the global hotkey
    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    /// Called when the hotkey is pressed
    fileprivate func handleHotKey() {
        DispatchQueue.main.async { [weak self] in
            self?.callback?()
        }
    }
}

/// Carbon event handler callback function
private func hotKeyEventHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData else { return OSStatus(eventNotHandledErr) }
    let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    manager.handleHotKey()
    return noErr
}
