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
