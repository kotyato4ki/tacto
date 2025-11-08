//
//  StatisticView.swift
//  tacto
//
//  Created by лизо4ка курунок on 07.11.2025.
//

import SwiftUI

struct StatisticView: View {
    @State private var showToday = true

    private let statsService = PomodoroStatsService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timer Statistics")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
 
            HStack(spacing: 16) {
                Button("Today") { showToday = true }
                    .buttonStyle(.plain)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(showToday ? Color.blue : Color.clear)
                    .foregroundColor(showToday ? .white : .primary)
                    .cornerRadius(6)
                
                Button("Last week") { showToday = false }
                    .buttonStyle(.plain)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(!showToday ? Color.blue : Color.clear)
                    .foregroundColor(!showToday ? .white : .primary)
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                let sessions = currentSessions()
                let totalTime = sessions.reduce(0) { $0 + $1.duration }
                let completedCount = sessions.filter { $0.result == .completed }.count
                let stoppedCount = sessions.filter { $0.result == .stoppedEarly }.count
                
                HStack {
                    Text("Total time:")
                        .bold()
                    Spacer()
                    Text(formatTime(totalTime))
                }
                
                HStack {
                    Text("Number of sessions:")
                        .bold()
                    Spacer()
                    Text("\(sessions.count)")
                }
                
                HStack {
                    Text("Completed:")
                        .bold()
                    Spacer()
                    Text("\(completedCount)")
                }
                
                HStack {
                    Text("Stopped early:")
                        .bold()
                    Spacer()
                    Text("\(stoppedCount)")
                }
            }
            
            Divider()
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                List(currentSessions().reversed()) { session in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.startDate, style: .date)
                            Text(session.startDate, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(formatTime(session.duration))
                            Text(session.result == .completed ? "✅ Completed" : "⚠️ Stopped")
                                .font(.caption)
                                .foregroundColor(session.result == .completed ? .green : .red)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scrollContentBackground(.hidden)
            }
            .frame(height: 195)
            .padding(.horizontal, 4)
            
            HStack {
                Spacer()
                Button("Clear statistics") {
                    PomodoroStatsService.shared.clearStatistics()
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
            }
        }
        .padding()
        .frame(width: 400, height: 450)
    }
    
    private func currentSessions() -> [PomodoroSession] {
        showToday ? statsService.last24HoursSessions
                  : statsService.lastWeekSessions
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let hrs = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        if hrs > 0 {
            return String(format: "%dh %02dm %02ds", hrs, mins, secs)
        } else {
            return String(format: "%02dm %02ds", mins, secs)
        }
    }
}
