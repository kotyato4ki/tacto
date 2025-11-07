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
                    Text("🍅 Pomodoro")
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
                    }) {
                        Label("Statistics for today", systemImage: "chart.bar")
                    }

                    Button(action: {
                    }) {
                        Label("Statistics for last week", systemImage: "calendar")
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
}
