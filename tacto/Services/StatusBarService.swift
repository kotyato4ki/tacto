import AppKit

final class StatusBarService {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let onToggle: () -> Void
    private let onQuit: () -> Void

    init(onToggle: @escaping () -> Void, onQuit: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onQuit = onQuit

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: "Launcher")
            button.target = self
            button.action = #selector(handleClick)
            // Разрешаем реагировать и на правый клик
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let openItem = NSMenuItem(title: "Open Launcher", action: #selector(openLauncher), keyEquivalent: "")
        openItem.target = self
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(openItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
    }

    @objc private func handleClick() {
        guard let event = NSApp.currentEvent else { onToggle(); return }
        if event.type == .rightMouseUp {
            statusItem.popUpMenu(menu)
        } else {
            onToggle()
        }
    }

    @objc private func openLauncher() { onToggle() }
    @objc private func quitApp() { onQuit() }
}
