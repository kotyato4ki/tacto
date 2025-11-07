//
//  CreateTaskView.swift
//  tacto
//
//  Created by Nick on 07.11.2025.
//

import SwiftUI

struct CreateTaskView: View {
    @State private var editableTask: EditableTaskModel
    private let originalTask: TaskModel
    @ObservedObject var TasksVM: TasksViewModel
    
    init(tasksVM: TasksViewModel) {
        let editableTask: EditableTaskModel = .default
        self.editableTask = editableTask
        self.originalTask = editableTask.toTaskModel(id: UUID())
        self.TasksVM = tasksVM
    }
    
    var body: some View {
        VStack {
            
            ModifyTask(
                editableTask: $editableTask,
                originalTask: originalTask
            )
            
            Button {
                TasksVM.lastChangedTask = editableTask.toTaskModel(id: UUID())
            } label: {
                Text("Create")
            }
            .padding(.bottom, 5)
            .font(.title2)
        }
    }
}

#Preview {
    CreateTaskView(tasksVM: TasksViewModel())
}
