import AppKit
import UniformTypeIdentifiers

enum ClipboardKind: Equatable, Codable {
    case text(String)
    case image(data: Data, size: NSSize)
    case files([URL])

    enum CodingKeys: String, CodingKey { case type, text, imageData, width, height, filePaths }

    enum KindTag: String, Codable { case text, image, files }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let tag = try c.decode(KindTag.self, forKey: .type)
        switch tag {
        case .text:
            self = .text(try c.decode(String.self, forKey: .text))
        case .image:
            let data = try c.decode(Data.self, forKey: .imageData)
            let w = try c.decode(CGFloat.self, forKey: .width)
            let h = try c.decode(CGFloat.self, forKey: .height)
            self = .image(data: data, size: NSSize(width: w, height: h))
        case .files:
            let paths = try c.decode([String].self, forKey: .filePaths)
            self = .files(paths.map { URL(fileURLWithPath: $0) })
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let s):
            try c.encode(KindTag.text, forKey: .type)
            try c.encode(s, forKey: .text)
        case .image(let data, let size):
            try c.encode(KindTag.image, forKey: .type)
            try c.encode(data, forKey: .imageData)
            try c.encode(size.width, forKey: .width)
            try c.encode(size.height, forKey: .height)
        case .files(let urls):
            try c.encode(KindTag.files, forKey: .type)
            try c.encode(urls.map { $0.path }, forKey: .filePaths)
        }
    }
}

struct ClipboardItem: Identifiable, Equatable, Codable {
    let id = UUID()
    let timestamp: Date
    let kind: ClipboardKind

    var displayText: String {
        switch kind {
        case .text(let string):
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count <= 80 { return trimmed }
            let idx = trimmed.index(trimmed.startIndex, offsetBy: 80)
            return String(trimmed[..<idx]) + "…"
        case .image(_, let size):
            let w = Int(size.width.rounded())
            let h = Int(size.height.rounded())
            return "Image \(w)×\(h)"
        case .files(let urls):
            if urls.count == 1 { return urls[0].lastPathComponent }
            let first = urls[0].lastPathComponent
            return "\(first) +\(urls.count - 1) more"
        }
    }
}

final class ClipboardService {
    static let shared = ClipboardService()

    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private var timer: Timer?
    private var saveWorkItem: DispatchWorkItem?

    private(set) var items: [ClipboardItem] = []
    private let maxItems = 100
    private let maxTotalBytes: Int = 20 * 1024 * 1024 // ~20 MB
    private let maxAgeDays: Int = 30

    private var storeURL: URL {
        let fm = FileManager.default
        let baseDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support", isDirectory: true)
        let appDir = baseDir.appendingPathComponent("tacto", conformingTo: .directory)
        if !fm.fileExists(atPath: appDir.path) {
            try? fm.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.appendingPathComponent("clipboard_history.json")
    }

    private init() {
        changeCount = pasteboard.changeCount
        loadFromDisk()
        pruneLimits()
        start()
    }

    deinit { stop() }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            self?.poll()
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount

        // 1) Files (highest priority)
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL], !urls.isEmpty {
            let item = ClipboardItem(timestamp: Date(), kind: .files(urls))
            if items.first?.kind != item.kind {
                items.insert(item, at: 0)
                if items.count > maxItems { items.removeLast(items.count - maxItems) }
                pruneLimits()
                scheduleSave()
            }
            return
        }

        // 2) Image
        if let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage], let img = images.first {
            var size = img.size
            if size == .zero, let rep = img.representations.first {
                size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            }
            if let tiff = img.tiffRepresentation {
                let item = ClipboardItem(timestamp: Date(), kind: .image(data: tiff, size: size))
                if items.first?.kind != item.kind {
                    items.insert(item, at: 0)
                    if items.count > maxItems { items.removeLast(items.count - maxItems) }
                    pruneLimits()
                    scheduleSave()
                }
                return
            }
        }

        // 3) Text
        if let str = pasteboard.string(forType: .string) {
            let normalized = str.replacingOccurrences(of: "\u{200B}", with: "")
            guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let item = ClipboardItem(timestamp: Date(), kind: .text(normalized))
            if items.first?.kind != item.kind {
                items.insert(item, at: 0)
                if items.count > maxItems { items.removeLast(items.count - maxItems) }
                pruneLimits()
                scheduleSave()
            }
        }
    }

    func filteredItems(matching term: String?) -> [ClipboardItem] {
        guard let t = term?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return items }
        return items.filter { item in
            switch item.kind {
            case .text(let s):
                return s.range(of: t, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            case .image:
                return "image".range(of: t, options: [.caseInsensitive]) != nil
            case .files(let urls):
                return urls.contains { $0.lastPathComponent.range(of: t, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            }
        }
    }

    func setClipboard(to item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.kind {
        case .text(let s):
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(s, forType: .string)
        case .image(let data, _):
            if let img = NSImage(data: data) {
                pasteboard.writeObjects([img])
            }
        case .files(let urls):
            pasteboard.writeObjects(urls as [NSURL])
        }
    }

    func pasteIntoFrontmostApp(_ item: ClipboardItem) {
        setClipboard(to: item)
        // Give time for our window  to hide before sending Cmd+V
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            self.sendCmdV()
        }
    }
    

    private func sendCmdV() {
        // kVK_ANSI_V = 0x09
        let keyCode: CGKeyCode = 0x09
        let src = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    // MARK: - Persistence
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.saveToDisk() }
        saveWorkItem = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    private func saveToDisk() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(items)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            // ignore for now
        }
    }

    private func loadFromDisk() {
        let fm = FileManager.default
        guard fm.fileExists(atPath: storeURL.path) else { return }
        do {
            let data = try Data(contentsOf: storeURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([ClipboardItem].self, from: data)
            self.items = decoded
        } catch {
            // ignore corrupt store
            self.items = []
        }
    }

    private func pruneLimits() {
        // by age
        let maxAge: TimeInterval = Double(maxAgeDays) * 24 * 60 * 60
        let now = Date()
        items.removeAll { now.timeIntervalSince($0.timestamp) > maxAge }

        // by count (already capped on insert, but enforce after load)
        if items.count > maxItems { items = Array(items.prefix(maxItems)) }

        // by total bytes (approx)
        var total = 0
        var pruned: [ClipboardItem] = []
        for item in items {
            let sz: Int
            switch item.kind {
            case .text(let s):
                sz = s.lengthOfBytes(using: .utf8)
            case .image(let data, _):
                sz = data.count
            case .files(let urls):
                sz = urls.reduce(0) { $0 + $1.path.lengthOfBytes(using: .utf8) }
            }
            if total + sz <= maxTotalBytes {
                pruned.append(item)
                total += sz
            } else {
                break
            }
        }
        items = pruned
    }
}


