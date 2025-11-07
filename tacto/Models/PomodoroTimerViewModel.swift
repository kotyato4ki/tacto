//
//  PomodoroTimerViewModel.swift
//  tacto
//
//  Created by лизо4ка курунок on 07.11.2025.
//

import Foundation
import Combine

@MainActor
final class PomodoroTimerViewModel: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isActive: Bool = false
    private var totalSeconds: Int = 0
    private var startDate: Date?

    private var timer: Timer?

    func start(minutes: Int) {
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        isActive = true
        startDate = Date() 
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.stop(completed: true)
                }
            }
        }
    }

    func stop(completed: Bool = false) {
        timer?.invalidate()
        guard let start = startDate else { return }

        let end = Date()
        let duration = end.timeIntervalSince(start)

        if isActive, duration > 1 {
            let result: PomodoroResult = completed ? .completed : .stoppedEarly
            PomodoroStatsService.shared.addSession(start: start, end: end, result: result)
        }

        remainingSeconds = 0
        isActive = false
        startDate = nil
    }
}
