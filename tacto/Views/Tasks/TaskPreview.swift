//
//  TaskPreview.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct TaskPreview: View {
    var task: TaskModel
    
    var body: some View {
        
        VStack(spacing: 12) {
            Text(task.name)
                .font(.title)
            
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Label(task.status.rawValue, systemImage: "circle.fill")
                        .font(.subheadline)
                        .foregroundColor(TaskModel.color(for: task.status))
                    
                    Label(task.priority.rawValue, systemImage: "flag.fill")
                        .font(.subheadline)
                        .foregroundColor(TaskModel.color(for: task.priority))
                }
                
                if (task.startDate != nil || task.deadline != nil) {
                    Divider()
                        .padding(.horizontal, 5)
                        .frame(height: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let startDate = task.startDate {
                        HStack {
                            Text("Start date:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(startDate, style: .date)
                                .font(.body)
                        }
                    }
                    
                    if let deadline = task.deadline {
                        HStack {
                            Text("Deadline:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(deadline, style: .date)
                                .font(.body)
                        }
                    }
                }
            }
        }
        .padding(12)
    }
}

#Preview {
    TaskPreview(task: TaskModel.getMockTasks()[4])
}
