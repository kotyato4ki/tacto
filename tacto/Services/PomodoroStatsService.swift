//
//  PomodoroStatsService.swift
//  tacto
//

import Foundation

final class PomodoroStatsService {
    static let shared = PomodoroStatsService()
    private let key = "PomodoroSessions"

    private var sessions: [PomodoroSession] = []

    private init() {
        load()
        cleanupOldSessions()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data)
        else { return }
        sessions = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func cleanupOldSessions() {
        let weekAgo = Date().addingTimeInterval(-7*24*3600)
        sessions = sessions.filter { $0.startDate >= weekAgo }
        save()
    }
    
    func clearStatistics() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: key)
    }

    func addSession(start: Date, end: Date, result: PomodoroResult) {
        let duration = end.timeIntervalSince(start)
        let session = PomodoroSession(
            startDate: start,
            endDate: end,
            duration: duration,
            result: result
        )
        sessions.append(session)
        cleanupOldSessions()
        save()
    }

    var last24HoursSessions: [PomodoroSession] {
        let since = Date().addingTimeInterval(-24*3600)
        return sessions.filter { $0.startDate >= since }
    }

    var lastWeekSessions: [PomodoroSession] {
        let since = Date().addingTimeInterval(-7*24*3600)
        return sessions.filter { $0.startDate >= since }
    }

    var totalTimeLast24Hours: TimeInterval {
        last24HoursSessions.reduce(0) { $0 + $1.duration }
    }

    var totalTimeLastWeek: TimeInterval {
        lastWeekSessions.reduce(0) { $0 + $1.duration }
    }

    var completedSessionsLastWeek: [PomodoroSession] {
        lastWeekSessions.filter { $0.result == .completed }
    }

    var completedSessionsLast24Hours: [PomodoroSession] {
        last24HoursSessions.filter { $0.result == .completed }
    }
}
