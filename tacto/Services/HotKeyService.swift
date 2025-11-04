import Foundation
import Carbon.HIToolbox

final class HotKeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let onPress: () -> Void

    init(optionSpaceHandler: @escaping () -> Void) {
        self.onPress = optionSpaceHandler

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData = userData else { return noErr }
                let me = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
                me.onPress()
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        if installStatus != noErr {
            // опционально: лог/обработка ошибки установки обработчика
            // print("InstallEventHandler failed with status \(installStatus)")
        }

        let hotKeyID = EventHotKeyID(signature: OSType(0x464C4331), id: 1)
        let keyCode = UInt32(kVK_Space)
        let modifiers = UInt32(optionKey) // ⌥

        let regStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if regStatus != noErr {
            // опционально: лог/обработка ошибки регистрации хоткея
            // print("RegisterEventHotKey failed with status \(regStatus)")
        }
    }

    deinit {
        if let hk = hotKeyRef { UnregisterEventHotKey(hk) }
        if let handler = eventHandler { RemoveEventHandler(handler) }
    }
}
