//
//  ModifyTask.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//

import SwiftUI

struct ModifyTask: View {
    @Binding var editableTask: EditableTaskModel
    @State private var newTag: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // MARK: Name, Priority, Status
                TextField("Name", text: $editableTask.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Status", selection: $editableTask.status) {
                    ForEach(TaskModel.TaskStatus.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Priority", selection: $editableTask.priority) {
                    ForEach(TaskModel.TaskPriority.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                .pickerStyle(.segmented)
                
                // MARK: Dates
                Toggle("Include start date", isOn: $editableTask.includeStartDate)
                    .toggleStyle(.switch)
                
                if editableTask.includeStartDate {
                    DatePicker("Start date", selection: $editableTask.startDate, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                }
                
                Toggle("Include deadline", isOn: $editableTask.includeDeadline)
                    .toggleStyle(.switch)
                
                if editableTask.includeDeadline {
                    DatePicker("Deadline", selection: $editableTask.deadline, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                }
                
                // MARK: Tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags:")
                        .font(.headline)
                    
                    ForEach(Array(editableTask.tags.enumerated()), id: \.offset) { index, tag in
                        HStack {
                            TextField("Tag", text: $editableTask.tags[index])
                                .padding(8)
                            
                            Button(action: {
                                editableTask.tags.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Добавление нового тега
                    HStack {
                        TextField("New tag", text: $newTag)
                            .padding(8)
                        
                        Button(action: {
                            let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            editableTask.tags.append(trimmed)
                            newTag = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // MARK: Description
                
                
                VStack(alignment: .leading) {
                    Text("Description")
                    
                    TextEditor(text: $editableTask.description)
                        .frame(minHeight: 30)
                        .padding(8)
                        .font(.system(size: 16))
                }
                
            }
            .padding()
            .frame(maxWidth: 400)
        }
    }
}

#Preview {
    @Previewable @State var editableTask = EditableTaskModel(from: TaskModel.getMockTasks()[0])
    ModifyTask(editableTask: $editableTask)
}
