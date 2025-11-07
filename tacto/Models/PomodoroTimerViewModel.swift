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
    
    private var timer: Timer?
    
    func start(minutes: Int) {
        remainingSeconds = minutes * 60
        isActive = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.stop()
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        isActive = false
    }
}
