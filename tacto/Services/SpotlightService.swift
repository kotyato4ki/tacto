import AppKit

struct Hit {
    let url: URL
    let isApplication: Bool
    var displayName: String { url.deletingPathExtension().lastPathComponent }
}

final class SpotlightService: NSObject {
    private var query: NSMetadataQuery?
    private var observers: [NSObjectProtocol] = []
    
    deinit { stop() }

    func search(term: String, appsOnly: Bool, limit: Int = 10, completion: @escaping ([Hit]) -> Void) {
        stop()

        let t = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { completion([]); return }

        let q = NSMetadataQuery()
        self.query = q

        // имя файла содержит term (без учёта регистра)
        let namePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", NSMetadataItemFSNameKey, t)

        // фильтр по приложениям (.app) через contentTypeTree
        let appUTI = "com.apple.application-bundle"
        let appPredicate = NSPredicate(format: "%K CONTAINS %@", NSMetadataItemContentTypeTreeKey, appUTI)

        q.predicate = appsOnly ? NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, appPredicate])
                               : namePredicate

        q.searchScopes = [NSMetadataQueryIndexedLocalComputerScope, NSMetadataQueryUserHomeScope]

        // Слушатели
        let finish = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: q, queue: .main) { [weak self] _ in
            self?.deliverResults(limit: limit, completion: completion)
        }
        let update = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidUpdate, object: q, queue: .main) { [weak self] _ in
            self?.deliverResults(limit: limit, completion: completion)
        }
        observers = [finish, update]

        q.start()
    }
    
    func stop() {
        if let q = query {
            q.stop()
        }
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        query = nil
    }

    private func deliverResults(limit: Int, completion: @escaping ([Hit]) -> Void) {
        guard let q = query else {
            completion([])
            return
        }

        var hits: [Hit] = []
        let count = min(q.resultCount, limit)

        for i in 0..<count {
            guard let item = q.result(at: i) as? NSMetadataItem else { continue }

            let url = (item.value(forAttribute: NSMetadataItemURLKey) as? URL)
                ?? (item.value(forAttribute: NSMetadataItemPathKey) as? String).flatMap { URL(fileURLWithPath: $0) }

            guard let url else { continue }

            // 1. пробуем через contentTypeKey (macOS 11+)
            let isAppByType: Bool = {
                if let values = try? url.resourceValues(forKeys: [.contentTypeKey]),
                   let type = values.contentType {
                    return type.conforms(to: .applicationBundle)
                }
                return false
            }()

            // 2. запасной вариант — по расширению
            let isApp = isAppByType || (url.pathExtension == "app")

            hits.append(Hit(url: url, isApplication: isApp))
        }

        completion(hits)
    }
}
