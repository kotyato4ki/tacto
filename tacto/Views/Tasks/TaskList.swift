//
//  TaskList.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct TaskList: View {
    var tasks: [TaskModel]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    NavigationLink(destination: TaskView(task: task)) {
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

#Preview {
    TaskList(tasks: TaskModel.getMockTasks())
}
