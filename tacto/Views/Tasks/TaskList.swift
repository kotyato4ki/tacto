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
    
    @State private var filter: Filter = .init()
    private var currentTasks: [TaskModel] {
        filterTasks(from: tasksVM.tasks)
    }
    
    @State private var tag: String? = nil
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                HStack(spacing: 16) {
                    Menu {
                        Toggle(isOn: $filter.showActual) {
                            Label("Show actual only", systemImage: "clock.badge.checkmark")
                        }
                        
                        Divider()
                        
                        Picker("Status", selection: $filter.showWithStatus) {
                            Text("All").tag(Optional<TaskModel.TaskStatus>.none)
                            ForEach(TaskModel.TaskStatus.allCases) { status in
                                Text(status.rawValue).tag(Optional(status))
                            }
                        }
                        
                        Picker("Priority", selection: $filter.showWithPriority) {
                            Text("All").tag(Optional<TaskModel.TaskPriority>.none)
                            ForEach(TaskModel.TaskPriority.allCases) { priority in
                                Text(priority.rawValue).tag(Optional(priority))
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "slider.horizontal.3")
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                    
                    if let tag = tag {
                        HStack(alignment: .center, spacing: 4) {
                            Text("#\(tag)")
                                .font(.callout)
                                .padding(.leading, 6)
                            
                            Button {
                                self.tag = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.2))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.accentColor.opacity(0.4))
                        )
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        CreateTaskView(tasksVM: tasksVM)
                    } label: {
                        Label("Add Task", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .padding(.top, 8)
                
                List {
                    ForEach(currentTasks) { task in
                        NavigationLink(destination: TaskView(task: task, tasksVM: tasksVM)) {
                            TaskPreview(
                                task: task,
                                tasksVM: tasksVM,
                                selectedTag: $tag
                            )
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
    
    private func filterTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var filteredTasks = tasks
        
        if (filter.showActual) {
            filteredTasks = filteredTasks.filter {
                if ($0.status == .cancelled || $0.status == .done) {
                    return false
                }
                if let deadline = $0.deadline {
                    return Date() < deadline
                } else {
                    return true
                }
            }
        } else {
            if let priority = filter.showWithPriority {
                filteredTasks = filteredTasks.filter { $0.priority == priority }
            }
            
            if let status = filter.showWithStatus {
                filteredTasks = filteredTasks.filter { $0.status == status }
            }
        }
        
        if let tag = tag {
            filteredTasks = filteredTasks.filter { $0.tags.contains(tag)
            }
        }
        
        return filteredTasks
    }
}

private struct Filter {
    var showWithPriority: TaskModel.TaskPriority? = nil
    var showWithStatus: TaskModel.TaskStatus? = nil
    var showActual: Bool = false
}

#Preview {
    TaskList(tasksVM: TasksViewModel())
}
