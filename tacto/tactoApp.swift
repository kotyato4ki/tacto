//
//  tactoApp.swift
//  tacto
//
//  Created by Nick on 29.10.2025.
//

import SwiftUI

@main
struct tactoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}
