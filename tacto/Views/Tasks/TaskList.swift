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
        List {
            ForEach(tasks) { task in
                TaskPreview(task: task)
                    .frame(maxWidth: .infinity)
                    .background(Color(NSColor.windowBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, 8)
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    TaskList(tasks: TaskModel.getMockTasks())
}
