//
//  TempTaskModel.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import Foundation

struct EditableTaskModel {
    var name: String
    var status: TaskModel.TaskStatus
    var priority: TaskModel.TaskPriority
    var includeStartDate: Bool
    var includeDeadline: Bool
    var startDate: Date
    var deadline: Date
    var tags: [String]
    var description: String
    
    init(from task: TaskModel) {
        self.name = task.name
        self.status = task.status
        self.priority = task.priority
        self.startDate = task.startDate ?? Date()
        self.deadline = task.deadline ?? Date()
        self.includeStartDate = task.startDate != nil
        self.includeDeadline = task.deadline != nil
        self.tags = task.tags
        self.description = task.description ?? ""
    }
    
    func toTaskModel(id: UUID) -> TaskModel {
        TaskModel(
            id: id,
            name: name,
            description: description,
            status: status,
            priority: priority,
            tags: tags,
            startDate: includeStartDate ? startDate : nil,
            deadline: includeDeadline ? deadline : nil
        )
    }
    
    static let `default` = EditableTaskModel(from: TaskModel(
        id: UUID(),
        name: "",
        description: "",
        status: .new,
        priority: .medium,
        tags: [],
        startDate: Date(),
        deadline: Date()
    ))
}
