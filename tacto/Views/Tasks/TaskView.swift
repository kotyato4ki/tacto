//
//  TaskView.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct TaskView: View {
    @State var task: TaskModel
    @State var tempTask: EditableTaskModel = EditableTaskModel.default
    @ObservedObject var tasksVM: TasksViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text(task.name)
                    .font(.title)
                
                HStack(alignment: .top, spacing: 50) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Label(task.status.rawValue, systemImage: "circle.fill")
                                .font(.subheadline)
                                .foregroundColor(TaskModel.color(for: task.status))
                            
                            Label(task.priority.rawValue, systemImage: "flag.fill")
                                .font(.subheadline)
                                .foregroundColor(TaskModel.color(for: task.priority))
                        }

                        if (task.startDate != nil || task.deadline != nil) {
                            Divider().padding(.vertical, 4)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let startDate = task.startDate {
                                HStack {
                                    Text("🟢 Start date:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(startDate, style: .date)
                                        .font(.body)
                                }
                            }
                            
                            if let deadline = task.deadline {
                                HStack {
                                    Text("🔴 Deadline:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(deadline, style: .date)
                                        .font(.body)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.windowBackgroundColor))
                            .shadow(radius: 2)
                    )
                    
                    // MARK: Tags
                    VStack(alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(task.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: ModifyTask(editableTask: $tempTask, originalTask: task)
                                .onAppear {
                                    tempTask = EditableTaskModel(from: task)
                                }
                                .onDisappear {
                                    let updatedTask = tempTask.toTaskModel(id: task.id)
                                    if let pos = tasksVM.tasks.firstIndex(where: { $0.id == task.id }) {
                                        tasksVM.tasks[pos] = updatedTask
                                    }
                                    task = updatedTask
                                }
                        ) {
                            Text("Edit")
                                .frame(width: 150)
                                .font(.headline)
                        }
                    }
                }
                
                if (task.description != nil) {
                    Text(task.description ?? "")
                        .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    let tasks = TaskModel.getMockTasks()
    let tasksVM = TasksViewModel(tasks: tasks)
    TaskView(task: tasks[4], tasksVM: tasksVM)
}
