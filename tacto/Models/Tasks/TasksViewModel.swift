//
//  TasksViewModel.swift
//  tacto
//
//  Created by Nick on 07.11.2025.
//

import Foundation
import Combine

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    private var tasksSubscription: AnyCancellable?
    
    init(tasks: [TaskModel]) {
        self.tasks = tasks
        
        tasksSubscription = $tasks
            .sink { tasks in
                tasks.forEach { print($0.name) }
            }
    }
}
