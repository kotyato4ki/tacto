import Foundation
import Carbon.HIToolbox

final class HotKeyService {
    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    private let onPress: () -> Void

    struct Combo { let keyCode: UInt32; let modifiers: UInt32 }

    init(onActivate: @escaping () -> Void,
         combos: [Combo] = [
            // opt Space — основной
            Combo(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)),
            // ⌘⇧ Space — запасной, если основной занят
            Combo(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | shiftKey))
         ]) {
        self.onPress = onActivate

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
            // print("InstallEventHandler failed with status \(installStatus)")
        }

        for (idx, combo) in combos.enumerated() {
            var ref: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: OSType(0x464C4331), id: UInt32(idx + 1))
            let status = RegisterEventHotKey(
                combo.keyCode,
                combo.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &ref
            )
            if status == noErr {
                hotKeyRefs.append(ref)
            } else {
                hotKeyRefs.append(nil)
                // print("RegisterEventHotKey failed: combo \(combo) status \(status)")
            }
        }
    }

    deinit {
        for hk in hotKeyRefs { if let hk { UnregisterEventHotKey(hk) } }
        if let handler = eventHandler { RemoveEventHandler(handler) }
    }
}
