import Foundation

struct Command: Identifiable {
    let id = UUID()
    let title: String
    let keyword: String
    let action: () -> Void
}
