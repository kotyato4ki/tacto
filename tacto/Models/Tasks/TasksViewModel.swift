//
//  TasksViewModel.swift
//  tacto
//
//  Created by Nick on 07.11.2025.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var lastChangedTask: TaskModel?
    
    private var tasksSubscription: AnyCancellable?
    private var lastChangedTaskSubscription: AnyCancellable?
    
    private let container: ModelContainer
    
    
    init(tasks: [TaskModel]) {
        self.tasks = tasks
        do {
            self.container = try ModelContainer(for: TaskDTO.self)
        } catch {
            fatalError("Can't create SwiftData container: \(error)")
        }
        
        let fetchDescriptor = FetchDescriptor<TaskDTO>(
            sortBy: [SortDescriptor(\.deadline, order: .forward)]
        )
        let tasksDTO: [TaskDTO] = (try? self.container.mainContext.fetch(fetchDescriptor)) ?? []
        self.tasks = tasksDTO.map { TaskModel(from: $0) }
        
        tasksSubscription = $tasks
            .sink { tasks in
                tasks.forEach { print($0.name) }
            }
        
        lastChangedTaskSubscription = $lastChangedTask
            .sink { [weak self] task in
                if let task = task {
                    if let index = self?.tasks.firstIndex(where: { $0.id == task.id }) {
                        self?.tasks[index] = task
                    } else {
                        self?.tasks.append(task)
                    }
                    self?.upsertTask(from: task)
                }
            }
    }
    
    private func upsertTask(from model: TaskModel) {
        let context = container.mainContext
        
        do {
            let id = model.id
            let descriptor = FetchDescriptor<TaskDTO>(
                predicate: #Predicate { $0.id == id }
            )
            if let existingTask = try context.fetch(descriptor).first {
                context.delete(existingTask)
                context.insert(model.toDTO())
            } else {
                context.insert(model.toDTO())
            }
            
            try context.save()
        } catch {
            print("Failed to upsert task: \(error)")
        }
    }
}
