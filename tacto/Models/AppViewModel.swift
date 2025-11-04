import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var isLauncherVisible = false

    let searchVM: SearchViewModel
    var onShow: (() -> Void)?
    var onHide: (() -> Void)?

    init(searchVM: SearchViewModel) {
        self.searchVM = searchVM

        // Закрываем окно после выполнения/отмены
        self.searchVM.onSubmit = { [weak self] command in
            command?.action()    // action не опционален, команда — да
            self?.hideLauncher()
        }
        self.searchVM.onCancel = { [weak self] in
            self?.hideLauncher()
        }
    }

    func showLauncher() {
        guard !isLauncherVisible else { return }
        isLauncherVisible = true
        onShow?()
    }

    func hideLauncher() {
        guard isLauncherVisible else { return }
        isLauncherVisible = false
        onHide?()
    }

    func toggleLauncher() {
        isLauncherVisible ? hideLauncher() : showLauncher()
    }
}
