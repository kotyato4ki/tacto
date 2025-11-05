//
//  TaskModel.swift
//  tacto
//
//  Created by Nick on 05.11.2025.
//

import Foundation

struct TaskModel: Codable {
    var id: UUID
    var name: String
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
}
