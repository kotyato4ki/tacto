import AppKit
import SwiftUI

final class LauncherWindowService {
    private let window: NSPanel
    private var localClickMonitor: Any?
    private var globalClickMonitor: Any?
    private var observers: [NSObjectProtocol] = []

    init<Content: View>(rootView: Content) {
        let size = NSSize(width: 740, height: 180)   // чуть выше — под списки
        let rect = NSRect(origin: .zero, size: size)

        let panel = NSPanel(
            contentRect: rect,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        let effect = NSVisualEffectView()
        effect.material = .hudWindow
        effect.state = .active
        effect.blendingMode = .behindWindow
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 16
        effect.layer?.masksToBounds = true
        panel.contentView = effect

        let host = NSHostingController(rootView: rootView)
        let v = host.view
        v.translatesAutoresizingMaskIntoConstraints = false
        effect.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: effect.leadingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: effect.trailingAnchor, constant: -12),
            v.topAnchor.constraint(equalTo: effect.topAnchor, constant: 12),
            v.bottomAnchor.constraint(equalTo: effect.bottomAnchor, constant: -12)
        ])

        self.window = panel
    }

    func show() {
        guard let screen = NSScreen.main else { return }
        let vf = screen.visibleFrame
        let x = vf.midX - window.frame.width / 2
        let y = vf.midY - window.frame.height / 2 + vf.height * 0.1
        window.setFrameOrigin(NSPoint(x: x, y: y))

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        startMonitors()
    }

    func hide() {
        stopMonitors()
        window.orderOut(nil)
    }

    private func startMonitors() {
        stopMonitors()

        // Клик ВНУТРИ приложения (локальный)
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }
            if event.window !== self.window { self.hide() }
            return event
        }

        // Клик ВНЕ приложения (глобальный)
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hide()
        }

        // Потеря активности приложения (Cmd+Tab и т.п.)
        let obs = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.hide()
        }
        observers.append(obs)
    }

    private func stopMonitors() {
        if let m = localClickMonitor { NSEvent.removeMonitor(m) }
        if let m = globalClickMonitor { NSEvent.removeMonitor(m) }
        localClickMonitor = nil
        globalClickMonitor = nil
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }

    deinit { stopMonitors() }
}
