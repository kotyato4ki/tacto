import AppKit

enum FileAccessService {
    static func openWithPermission(url: URL) {
        let panel = NSOpenPanel()
        panel.directoryURL = url.deletingLastPathComponent()
        panel.nameFieldStringValue = url.lastPathComponent
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Grant access to open this file"

        panel.begin { response in
            guard response == .OK, let selected = panel.url else { return }

            // Сохраняем security-scoped bookmark (по желанию — можно читать потом при старте)
            if let bookmark = try? selected.bookmarkData(options: .withSecurityScope,
                                                        includingResourceValuesForKeys: nil,
                                                        relativeTo: nil) {
                UserDefaults.standard.set(bookmark, forKey: "LastAccessBookmark")
            }

            // Открываем файл
            selected.startAccessingSecurityScopedResource()
            NSWorkspace.shared.open(selected)
            selected.stopAccessingSecurityScopedResource()
        }
    }
}
