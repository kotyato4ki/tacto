//
//  PomodoroTimerView.swift
//  tacto
//
//  Created by лизо4ка курунок on 07.11.2025.
//

import Foundation
import SwiftUICore
import SwiftUI

struct PomodoroTimerView: View {
    @ObservedObject var vm: PomodoroTimerViewModel

    var body: some View {
        VStack {
            if vm.isActive {
                Text("🍅 \(vm.remainingSeconds / 60):\(String(format: "%02d", vm.remainingSeconds % 60))")
                    .font(.title)
                    .monospacedDigit()
                    .padding()
                    .multilineTextAlignment(.center)
                Button("Stop") {
                    vm.stop()
                }
            } else {
                Text("Нет активного таймера")
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 150, height: 70)
        .padding()
    }
}
