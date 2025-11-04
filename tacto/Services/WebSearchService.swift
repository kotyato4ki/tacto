import AppKit

enum WebEngine {
    case google, yandex

    var baseURL: String {
        switch self {
        case .google: return "https://www.google.com/search?q="
        case .yandex: return "https://ya.ru/search/?text="
        }
    }
}

enum WebSearchService {
    static func open(query: String, engine: WebEngine = .google) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = engine.baseURL + encoded
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
