//
//  TaskView.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct TaskView: View {
    var task: TaskModel
    
    func color(for status: TaskModel.TaskStatus) -> Color {
        switch status {
        case .new: return .blue
        case .inProgress: return .orange
        case .done: return .green
        case .cancelled: return .red
        }
    }

    func color(for priority: TaskModel.TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .yellow
        case .low: return .green
        }
    }
    
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
                                .foregroundColor(color(for: task.status))
                            
                            Label(task.priority.rawValue, systemImage: "flag.fill")
                                .font(.subheadline)
                                .foregroundColor(color(for: task.priority))
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
                        .padding(.horizontal)
                    }
                    
                    if (task.startDate != nil || task.deadline != nil) {
                        VStack {
                            
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
    TaskView(task: TaskModel.getMockTasks()[4])
}
