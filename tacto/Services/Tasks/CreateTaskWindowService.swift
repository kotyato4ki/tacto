//
//  CreateTaskWindowService.swift
//  tacto
//
//  Created by Nick on 07.11.2025.
//

import SwiftUI
import AppKit

@MainActor
final class CreateTaskWindowService: ObservableObject {
    private var window: NSWindow?
    private var tasksVM: TasksViewModel
    
    init(with tasksVM: TasksViewModel) {
        self.tasksVM = tasksVM
        setupWindow()
    }
    
    private func setupWindow() {
        let createTaskView = CreateTaskView(tasksVM: tasksVM)
            .frame(minWidth: 400, idealWidth: 500, minHeight: 400, idealHeight: 600)
        
        let hostingController = NSHostingController(rootView: createTaskView)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window?.title = "Create Task"
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


private class WindowDelegate: NSObject, NSWindowDelegate {
    private weak var service: CreateTaskWindowService?
    
    init(service: CreateTaskWindowService) {
        self.service = service
    }
    
    func windowWillClose(_ notification: Notification) {
        service?.close()
    }
}
