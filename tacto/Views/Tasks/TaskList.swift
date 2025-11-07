//
//  TaskList.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct TaskList: View {
    @ObservedObject var tasksVM: TasksViewModel
    @State private var showAddTaskView = false
    @State private var newTask = EditableTaskModel.default
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                NavigationLink(destination: CreateTaskView(tasksVM: tasksVM)) {
                    Text("Add Task")
                        .font(.title2)
                }
                .padding(.top, 10)
                
                List {
                    ForEach(tasksVM.tasks) { task in
                        NavigationLink(destination: TaskView(task: task, tasksVM: tasksVM)) {
                            TaskPreview(task: task)
                                .frame(maxWidth: .infinity)
                                .background(Color(NSColor.windowBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(.horizontal, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }
}

#Preview {
    TaskList(tasksVM: TasksViewModel(tasks: TaskModel.getMockTasks()))
}
