//
//  PastrApp.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI

@main
struct PastrApp: App {
    @StateObject private var clipboardManager = ClipboardManager()

    // Connect to the AppDelegate, which will manage the app's lifecycle and global state.

    var body: some Scene {
        MenuBarExtra {
            // Provide the single ClipboardManager instance from the AppDelegate to the SwiftUI environment.
            ContentView()
                .environmentObject(clipboardManager)
                .onDisappear {
                    NSApp.hide(nil)
                }
        } label: {
            Image("StatusBarIcon")
        }
        .menuBarExtraStyle(.window)
    }
}
