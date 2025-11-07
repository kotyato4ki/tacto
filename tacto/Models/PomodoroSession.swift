//
//  PomodoroSession.swift
//  tacto
//
//  Created by лизо4ка курунок on 07.11.2025.
//

import Foundation

enum PomodoroResult: String, Codable {
    case completed
    case stoppedEarly
}

struct PomodoroSession: Codable, Identifiable {
    var id = UUID()
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let result: PomodoroResult
}
