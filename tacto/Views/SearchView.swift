import SwiftUI

struct SearchView: View {
    @ObservedObject var vm: SearchViewModel
    var onClose: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                TextField("Type a command…", text: $vm.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .focused($focused)
                    .onSubmit { vm.submitSelected() }   // Enter
            }
            .padding(.vertical, 8)

            if !vm.suggestions.isEmpty {
                VStack(spacing: 4) {
                    // без enumerated(): идём по индексам
                    ForEach(vm.suggestions.indices, id: \.self) { i in
                        let cmd = vm.suggestions[i]
                        SuggestionRow(
                            title: cmd.title,
                            keyword: cmd.keyword,
                            selected: i == vm.selectedIndex
                        )
                        .onTapGesture {
                            vm.selectedIndex = i
                            vm.submitSelected()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 14)
        .frame(width: 720)
        .onAppear { focused = true }
        .onExitCommand { vm.cancel() } // Esc
        .background(
            KeyEventMonitor(onEvent: { event in
                switch event.keyCode {
                case 125: vm.moveSelection(1);  return true   // ↓
                case 126: vm.moveSelection(-1); return true   // ↑
                case 36, 76: vm.submitSelected(); return true // Return / Keypad Enter
                case 53: vm.cancel();            return true  // Esc
                default: return false
                }
            })
        )
    }
}

/// Отдельная строка — разгружает тайпчекер и делает код читабельнее
private struct SuggestionRow: View {
    let title: String
    let keyword: String
    let selected: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selected ? .accentColor : .primary)
            Spacer()
            Text(keyword)
                .foregroundColor(.secondary)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}

// Локальный монитор клавиатуры
private struct KeyEventMonitor: NSViewRepresentable {
    let onEvent: (NSEvent) -> Bool

    final class Coordinator { var monitor: Any? }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        context.coordinator.monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            onEvent(event) ? nil : event
        }
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let m = coordinator.monitor { NSEvent.removeMonitor(m) }
        coordinator.monitor = nil
    }
}
