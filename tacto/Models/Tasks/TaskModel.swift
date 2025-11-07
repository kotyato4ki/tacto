//
//  TaskModel.swift
//  tacto
//
//  Created by Nick on 05.11.2025.
//

import Foundation
import SwiftUI

struct TaskModel: Identifiable {
    var id: UUID
    var name: String
    var description: String?
    var status: TaskStatus
    var priority: TaskPriority
    var tags: [String]
    var startDate: Date?
    var deadline: Date?
    
    
    enum TaskStatus: String, Identifiable, CaseIterable, Codable {
        case new = "New"
        case inProgress = "In progress"
        case done = "Done"
        case cancelled = "Cancelled"
        
        var id: String { rawValue }
    }
    
    enum TaskPriority: String, Identifiable, CaseIterable, Codable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var id: String { rawValue }
    }
    
    static func color(for status: TaskStatus) -> Color {
        switch status {
        case .new: return .blue
        case .inProgress: return .orange
        case .done: return .green
        case .cancelled: return .red
        }
    }

    static func color(for priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .yellow
        case .low: return .green
        }
    }
    
    static func getMockTasks() -> [TaskModel] {
        return [
            TaskModel(
                id: UUID(),
                name: "First task",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas facilisis ex sit amet pulvinar. Phasellus eget sapien metus. Cras eleifend aliquet sollicitudin. Nulla lacinia maximus turpis, eget tincidunt diam ornare a. Cras cursus sed risus et convallis. Praesent facilisis sit amet urna eu posuere. Proin porttitor mattis elementum. Sed ut justo nisl. Nullam leo quam, malesuada at nibh at, mollis aliquet ligula. Aenean tincidunt est in condimentum luctus. Cras interdum porttitor erat et rhoncus. Vestibulum lobortis nisl quis magna venenatis posuere.",
                status: .new,
                priority: .high,
                tags: ["swift", "ios", "work"]
            ),
            TaskModel(
                id: UUID(),
                name: "Second task",
                status: .inProgress,
                priority: .high,
                tags: ["js", "react", "work"],
                deadline: Calendar.current.date(byAdding: .day, value: 10, to: Date())
            ),
            TaskModel(
                id: UUID(),
                name: "Third task",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas facilisis ex sit amet pulvinar. Phasellus eget sapien metus. Cras eleifend aliquet sollicitudin. Nulla lacinia maximus turpis, eget tincidunt diam ornare a. Cras cursus sed risus et convallis. Praesent facilisis sit amet urna eu posuere. Proin porttitor mattis elementum. Sed ut justo nisl. Nullam leo quam, malesuada at nibh at, mollis aliquet ligula. Aenean tincidunt est in condimentum luctus. Cras interdum porttitor erat et rhoncus. Vestibulum lobortis nisl quis magna venenatis posuere.",
                status: .new,
                priority: .medium,
                tags: ["swift", "ios", "study"],
                startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())
            ),
            TaskModel(
                id: UUID(),
                name: "Fourth task",
                status: .done,
                priority: .medium,
                tags: ["go", "backend", "study"],
                startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
                deadline: Calendar.current.date(byAdding: .day, value: -1, to: Date())
            ),
            TaskModel(
                id: UUID(),
                name: "Fifth task",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas facilisis ex sit amet pulvinar. Phasellus eget sapien metus. Cras eleifend aliquet sollicitudin. Nulla lacinia maximus turpis, eget tincidunt diam ornare a. Cras cursus sed risus et convallis. Praesent facilisis sit amet urna eu posuere. Proin porttitor mattis elementum. Sed ut justo nisl. Nullam leo quam, malesuada at nibh at, mollis aliquet ligula. Aenean tincidunt est in condimentum luctus. Cras interdum porttitor erat et rhoncus. Vestibulum lobortis nisl quis magna venenatis posuere.",
                status: .cancelled,
                priority: .low,
                tags: ["touch grass", "walking"],
                startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
                deadline: Calendar.current.date(byAdding: .day, value: 10, to: Date())
            )
        ]
    }
}
