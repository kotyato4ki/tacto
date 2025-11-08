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
    var tasks: [TaskModel] = []
    @Published var lastChangedTask: TaskModel?
    @Published var taskToDelete: TaskModel?
    
    private var lastChangedTaskSubscription: AnyCancellable?
    private var taskToDeleteSubscription: AnyCancellable?
    
    private let container: ModelContainer
    
    
    init() {
        do {
            self.container = try ModelContainer(for: TaskDTO.self)
        } catch {
            fatalError("Can't create SwiftData container: \(error)")
        }
        
        self.tasks = fetchTasks()
        
        
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
        
        
        taskToDeleteSubscription = $taskToDelete
            .sink { [weak self] task in
                if let self = self, let task = task {
                    self.tasks.removeAll(where: { $0.id == task.id })
                    self.deleteTask(withId: task.id)
                }
            }
    }
    
    private func fetchTasks() -> [TaskModel] {
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<TaskDTO>(
                sortBy: [SortDescriptor(\.deadline, order: .forward)]
            )
            let tasksDTO: [TaskDTO] = (try? context.fetch(descriptor)) ?? []
            return tasksDTO.map { TaskModel(from: $0) }
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
    
    private func deleteTask(withId id: UUID) {
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<TaskDTO>(
                predicate: #Predicate { $0.id == id }
            )
            if let taskToDelete = try context.fetch(descriptor).first {
                context.delete(taskToDelete)
            }
            
            try context.save()
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}
