//
//  TaskDTO.swift
//  tacto
//
//  Created by Nick on 07.11.2025.
//

import Foundation
import SwiftData

@Model
final class TaskDTO {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var taskDescription: String?
    var status: TaskModel.TaskStatus
    var priority: TaskModel.TaskPriority
    var tags: [String]
    var startDate: Date?
    var deadline: Date?
    
    init(id: UUID, name: String, taskDescription: String? = nil, status: TaskModel.TaskStatus, priority: TaskModel.TaskPriority, tags: [String], startDate: Date? = nil, deadline: Date? = nil) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.status = status
        self.priority = priority
        self.tags = tags
        self.startDate = startDate
        self.deadline = deadline
    }
}
