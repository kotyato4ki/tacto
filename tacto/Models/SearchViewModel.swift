import Foundation
import Combine
import AppKit

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var suggestions: [Command] = []
    @Published var selectedIndex: Int = 0   // текущая выделенная строка

    var onSubmit: ((Command?) -> Void)?
    var onCancel: (() -> Void)?

    private var allCommands: [Command] = []

    private let spotlightApps  = SpotlightService()
    private let spotlightFiles = SpotlightService()

    var defaultWebEngine: WebEngine = .google

    private var bag = Set<AnyCancellable>()
    private var generation = 0 // защита от гонок
    private var currentApps:  [Command] = []
    private var currentFiles: [Command] = []
    let pomodoroTimerVM: PomodoroTimerViewModel

    init(pomodoroTimerVM: PomodoroTimerViewModel) {
        self.pomodoroTimerVM = pomodoroTimerVM
        allCommands = [
            Command(title: "Open Tasks",  keyword: "tasks") { print("Action: Open Tasks") },
            Command(title: "Start Pomodoro 25", keyword: "pomodoro") { [weak self] in self?.pomodoroTimerVM.start(minutes: 25) },
            Command(title: "Clipboard", keyword: "clip") { print("Action: Open Clipboard Manager") },
            Command(title: "New Task", keyword: "task") { print("Action: Create New Task") }
        ]

        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.buildSuggestions(for: text)
            }
            .store(in: &bag)

        suggestions = allCommands
    }

    private func startPomodoroIfNecessary() {
        let pattern = #"pomodoro\s*(\d+)"#
        if let match = query.range(of: pattern, options: .regularExpression),
           let minutes = Int(query[match].components(separatedBy: " ").last ?? "") {
            pomodoroTimerVM.start(minutes: minutes)
        }
    }

    private func buildSuggestions(for text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            spotlightApps.stop()
            spotlightFiles.stop()
            currentApps.removeAll()
            currentFiles.removeAll()
            suggestions = allCommands
            selectedIndex = suggestions.isEmpty ? 0 : 0
            return
        }

        generation &+= 1
        let gen = generation
        currentApps.removeAll()
        currentFiles.removeAll()
        selectedIndex = 0

        var extraCommands: [Command] = []
        if let minutes = extractPomodoroMinutes(from: trimmed) {
            extraCommands.append(
                Command(
                    title: "Start Pomodoro for \(minutes) min",
                    keyword: "pomodoro",
                    action: { [weak self] in
                        self?.pomodoroTimerVM.start(minutes: minutes)
                    }
                )
            )
        }

        var baseSuggestions = extraCommands
        baseSuggestions.append(
            Command(title: "Search “\(trimmed)” on the Web", keyword: "web") {
                WebSearchService.open(query: trimmed, engine: self.defaultWebEngine)
            }
        )
        suggestions = baseSuggestions

        spotlightApps.stop()
        spotlightFiles.stop()

        spotlightApps.search(term: trimmed, appsOnly: true, limit: 6) { [weak self] hits in
            guard let self, gen == self.generation else { return }
            self.currentApps = hits.map { hit in
                Command(title: "Launch \(hit.displayName)", keyword: "app") {
                    let cfg = NSWorkspace.OpenConfiguration()
                    cfg.activates = true
                    NSWorkspace.shared.openApplication(at: hit.url, configuration: cfg, completionHandler: nil)
                }
            }
            self.publishMerged(for: trimmed, generation: gen, extra: extraCommands)
        }

        spotlightFiles.search(term: trimmed, appsOnly: false, limit: 10) { [weak self] hits in
            guard let self, gen == self.generation else { return }
            self.currentFiles = hits
                .filter { !$0.isApplication }
                .map { hit in
                    Command(title: "Open \(hit.displayName)", keyword: "file") {
                        NSWorkspace.shared.open(hit.url)
                    }
                }
            self.publishMerged(for: trimmed, generation: gen, extra: extraCommands)
        }
    }

    private func extractPomodoroMinutes(from text: String) -> Int? {
        let pattern = #"pomodoro[\s:]+(\d+)"#
        if let match = text.range(of: pattern, options: .regularExpression) {
            let captured = text[match].split(separator: " ").last
            return captured.flatMap { Int($0) }
        }
        return nil
    }

    private func publishMerged(for text: String, generation gen: Int, extra: [Command] = []) {
        guard gen == generation else { return }
        var merged: [Command] = []
        merged.append(contentsOf: extra)
        merged.append(contentsOf: currentApps)
        merged.append(contentsOf: currentFiles)
        merged.append(
            Command(title: "Search “\(text)” on the Web", keyword: "web") {
                WebSearchService.open(query: text, engine: self.defaultWebEngine)
            }
        )
        suggestions = merged
        if !suggestions.indices.contains(selectedIndex) {
            selectedIndex = suggestions.isEmpty ? 0 : 0
        }
    }

    // MARK: - Навигация
    func moveSelection(_ delta: Int) {
        guard !suggestions.isEmpty else { return }
        let newIndex = max(0, min(selectedIndex + delta, suggestions.count - 1))
        selectedIndex = newIndex
    }

    func submitSelected() {
        guard suggestions.indices.contains(selectedIndex) else {
            onSubmit?(nil)
            return
        }
        onSubmit?(suggestions[selectedIndex])
    }

    func cancel() {
        onCancel?()
    }
}
