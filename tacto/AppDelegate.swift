import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appVM: AppViewModel?
    private var windowService: LauncherWindowService?
    private var statusBar: StatusBarService?
    private var hotKey: HotKeyService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // VM верхнего уровня
        let pomodoroTimerVM = PomodoroTimerViewModel()
        let searchVM = SearchViewModel(pomodoroTimerVM: pomodoroTimerVM)
        let appVM = AppViewModel(searchVM: searchVM, pomodoroTimerVM: pomodoroTimerVM)
        self.appVM = appVM

        // Вью (SwiftUI), которое будет в плавающем окне
        let rootView = SearchView(vm: searchVM, onClose: { [weak self] in
            self?.appVM?.hideLauncher()
        })

        // Сервисы платформы
        let windowService = LauncherWindowService(rootView: rootView)
        self.windowService = windowService

        let statusBar = StatusBarService(
            onToggleWindows: { [weak self] in
                guard let self else { return }
                if let appVM = self.appVM, appVM.isPomodoroVisible {
                    appVM.hidePomodoro()
                } else if let appVM = self.appVM, appVM.isLauncherVisible {
                    appVM.hideLauncher()
                } else {
                    self.appVM?.showLauncher()
                }
            },
            onQuit: { NSApp.terminate(nil) },
            pomodoroTimerVM: appVM.pomodoroTimerVM,
            onToggleLauncherToHide: { [weak self] in
                self?.appVM?.hideLauncher()
            }
        )
        
        self.statusBar = statusBar

        let hotKey = HotKeyService(optionSpaceHandler: { [weak self] in
            self?.appVM?.toggleLauncher() }
        )
        self.hotKey = hotKey

        // Подписка VM → UI-сервис
        appVM.onShowLauncher = { [weak self] in self?.windowService?.show() }
        appVM.onHideLauncher = { [weak self] in self?.windowService?.hide() }
    }
}
