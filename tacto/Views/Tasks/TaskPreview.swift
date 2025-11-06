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
        
        VStack(alignment: .leading, spacing: 12) {
            Text(task.name)
                .font(.title)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Label(task.status.rawValue, systemImage: "circle.fill")
                        .font(.subheadline)
                        .foregroundColor(TaskModel.color(for: task.status))
                    
                    Label(task.priority.rawValue, systemImage: "flag.fill")
                        .font(.subheadline)
                        .foregroundColor(TaskModel.color(for: task.priority))
                }
                .frame(width: 100, alignment: .leading)
                
                if (task.startDate != nil || task.deadline != nil) {
                    Divider()
                        .padding(.horizontal, 5)
                        .frame(height: 40)
                } else {
                    Divider()
                        .opacity(0)
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
                .frame(width: 200, alignment: .leading)
            }
            
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
        }
        .frame(width: 350)
        .padding(12)
    }
}

#Preview {
    TaskPreview(task: TaskModel.getMockTasks()[4])
}
