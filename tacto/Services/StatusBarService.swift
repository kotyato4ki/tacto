import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarService {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let onToggleWindows: () -> Void
    private let onQuit: () -> Void
    private var pomodoroWindow: NSWindow?
    private let pomodoroTimerVM: PomodoroTimerViewModel
    private let onToggleLauncherToHide: () -> Void
    private var popover: NSPopover
    private let onOpenTasks: () -> Void
    private let onOpenCreateTasks: () -> Void
    private var cancellables = Set<AnyCancellable>()

    init(onToggleWindows: @escaping () -> Void, onQuit: @escaping () -> Void, pomodoroTimerVM: PomodoroTimerViewModel, onToggleLauncherToHide: @escaping () -> Void, onOpenTasks: @escaping () -> Void, onOpenCreateTasks: @escaping () -> Void) {
        self.onToggleWindows = onToggleWindows
        self.onQuit = onQuit
        self.pomodoroTimerVM = pomodoroTimerVM
        self.onToggleLauncherToHide = onToggleLauncherToHide
        self.popover = NSPopover()
        self.onOpenTasks = onOpenTasks
        self.onOpenCreateTasks = onOpenCreateTasks

        setupStatusItem()
        setupPopover()
        bindToViewModel()

        let openItem = NSMenuItem(title: "Open Launcher", action: #selector(openLauncher), keyEquivalent: "l")
        openItem.target = self
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        let showTimerItem = NSMenuItem(title: "Timer", action: #selector(togglePopover), keyEquivalent: "p")
        showTimerItem.target = self
        let tasksItem = NSMenuItem(title: "Tasks", action: #selector(openTasks), keyEquivalent: "t")
        tasksItem.target = self
        let createTaskItem = NSMenuItem(title: "Create Task", action: #selector(openCreateTasks), keyEquivalent: "c")
        createTaskItem.target = self
        
        menu.addItem(openItem)
        menu.addItem(.separator())
        menu.addItem(showTimerItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        menu.addItem(.separator())
        menu.addItem(tasksItem)
        menu.addItem(createTaskItem)
    }
    
    private func setupStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: "Launcher")
            button.target = self
            button.imagePosition = .imageLeading
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            button.font = font
        }
    }
    
    private func setupPopover() {
        let contentView = PomodoroTimerView(vm: pomodoroTimerVM)
        popover.contentSize = NSSize(width: 130, height: 80)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    private func bindToViewModel() {
        pomodoroTimerVM.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] seconds in
                guard let button = self?.statusItem.button else { return }
                if self?.pomodoroTimerVM.isActive == true && seconds > 0  {
                    let minutes = seconds / 60
                    let secs = seconds % 60
                    button.title = String(format: "%d:%02d", minutes, secs)
                } else {
                    button.title = ""
                }
            }
            .store(in: &cancellables)

        pomodoroTimerVM.$isActive
            .receive(on: RunLoop.main)
            .sink { [weak self] isActive in
                guard let _ = self?.statusItem.button else { return }
            }
            .store(in: &cancellables)
    }

    @objc private func handleClick() {
        guard let event = NSApp.currentEvent else {
            onToggleWindows()
            return
        }
        if event.type == .rightMouseUp {
            statusItem.popUpMenu(menu)
        } else {
            onToggleWindows()
        }
    }

    @objc private func openLauncher() {
        onToggleWindows()
    }

    @objc private func quitApp() {
        onQuit()
    }

    @objc private func showTimer() {
        if pomodoroWindow == nil {
            let hosting = NSHostingController(rootView: PomodoroTimerView(vm: pomodoroTimerVM))
            pomodoroWindow = NSWindow(contentViewController: hosting)
            pomodoroWindow?.setFrame(NSRect(x: 0, y: 0, width: 220, height: 120), display: true)
            pomodoroWindow?.level = .floating
            pomodoroWindow?.center()
        }
        onToggleLauncherToHide()
        pomodoroWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func openTasks() { self.onOpenTasks() }
    @objc private func openCreateTasks() { self.onOpenCreateTasks() }
}
