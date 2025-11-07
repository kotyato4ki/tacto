import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var isLauncherVisible = false
    @Published private(set) var isPomodoroVisible = false

    let searchVM: SearchViewModel
    let pomodoroTimerVM: PomodoroTimerViewModel

    var onShowLauncher: (() -> Void)?
    var onHideLauncher: (() -> Void)?
    var onHidePomodoro: (() -> Void)?

    init(searchVM: SearchViewModel, pomodoroTimerVM: PomodoroTimerViewModel) {
        self.searchVM = searchVM
        self.pomodoroTimerVM = pomodoroTimerVM
        
        self.searchVM.onSubmit = { [weak self] command in
            guard let self, let command = command else { return }
            command.action()
            if command.keyword == "pomodoro" {
                self.hideLauncher()
            } else {
                self.hideLauncher()
            }
        }
    }

    func showLauncher() {
        guard !isLauncherVisible else { return }
        isLauncherVisible = true
        onShowLauncher?()
    }

    func hideLauncher() {
        guard isLauncherVisible else { return }
        isLauncherVisible = false
        onHideLauncher?()
    }

    func toggleLauncher() {
        isLauncherVisible ? hideLauncher() : showLauncher()
    }

    func hidePomodoro() {
        guard isPomodoroVisible else { return }
        isPomodoroVisible = false
        onHidePomodoro?()
    }
    
    func togglePomodoro() {
        hidePomodoro()
    }
}
