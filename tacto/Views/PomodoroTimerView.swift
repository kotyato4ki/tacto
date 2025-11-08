//
//  PomodoroTimerView.swift
//  tacto
//
//  Created by лизо4ка курунок on 07.11.2025.
//

import SwiftUI

struct PomodoroTimerView: View {
    @ObservedObject var vm: PomodoroTimerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if vm.isActive {
                VStack(spacing: 4) {
                    Text("⏱️ Timer")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("\(vm.remainingSeconds / 60):\(String(format: "%02d", vm.remainingSeconds % 60))")
                        .font(.system(.title, design: .monospaced))
                        .bold()
                        .padding(.bottom, 4)

                    Button(role: .destructive) {
                        vm.stop()
                    } label: {
                        Label("Stop", systemImage: "stop.circle.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                }
                .frame(width: 160)
                .padding(.vertical, 8)
            } else {
                Text("Нет активного таймера")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 6)

                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: {
                        showTodayStatsWindow()
                    }) {
                        Label("Show statistics", systemImage: "chart.bar")
                    }
                }
                .buttonStyle(.plain)
                .labelStyle(.titleAndIcon)
                .padding(.top, 4)
            }
        }
        .padding(12)
        .frame(width: 200)
    }
    
    func showTodayStatsWindow() {
        let view = StatisticView().frame(width: 400, height: 500)
        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hosting)
        window.setContentSize(NSSize(width: 400, height: 500))
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.title = "Tacto Statistics"
        NSApp.activate(ignoringOtherApps: true)
    }
}
