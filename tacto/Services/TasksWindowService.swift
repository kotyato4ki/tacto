//
//  TasksWindowService.swift
//  tacto
//
//  Created by Nick on 06.11.2025.
//


import SwiftUI
import AppKit

@MainActor
final class TasksWindowService: ObservableObject {
    private var window: NSWindow?
    private var tasks: [TaskModel] = []
    
    private var tasksWindowService: TasksWindowService?
    
    init() {
        // Загружаем тестовые данные или реальные данные
        self.tasks = TaskModel.getMockTasks()
        setupWindow()
    }
    
    private func setupWindow() {
        let taskListView = TaskList(tasks: tasks)
            .frame(minWidth: 400, idealWidth: 500, minHeight: 400, idealHeight: 600)
        
        let hostingController = NSHostingController(rootView: taskListView)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window?.title = "Tasks"
        window?.center()
        window?.contentViewController = hostingController
        window?.isReleasedWhenClosed = false // предотвращаем освобождение памяти при закрытии
        window?.delegate = WindowDelegate(service: self)
    }
    
    func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            setupWindow()
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func hide() {
        window?.orderOut(nil)
    }
    
    func close() {
        window?.close()
        window = nil
    }
}

// Делегат для обработки закрытия окна
private class WindowDelegate: NSObject, NSWindowDelegate {
    private weak var service: TasksWindowService?
    
    init(service: TasksWindowService) {
        self.service = service
    }
    
    func windowWillClose(_ notification: Notification) {
        service?.close()
    }
}
