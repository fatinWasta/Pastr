//
//  ContentView.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject private var manager: ClipboardManager

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(itemCount: manager.historyItems.count)
            SearchAndFilterView(searchText: $manager.searchText, selectedFilter: $manager.selectedFilter)
            if manager.pinnedItems.isEmpty && manager.historyItems.isEmpty {
                EmptyStateView()
            } else {
                mainContentList
            }
            
            FooterView(onClear: manager.clearSession)
        }
        .frame(width: 450, height: 650)
        .background(Color("BackgroundColor"))
    }
    
    private var mainContentList: some View {
        List {
            if !manager.pinnedItems.isEmpty {
                Section(header: SectionHeaderView(title: "Pinned Items")) {
                    ForEach(manager.pinnedItems) { item in
                        row(for: item)
                    }
                }
            }
            
            if !manager.historyItems.isEmpty {
                Section(header: SectionHeaderView(title: "Session History")) {
                    ForEach(manager.historyItems) { item in
                        row(for: item)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    /// Creates a configured `ClipboardItemRow` for a given item.
    private func row(for item: ClipboardItem) -> some View {
        ClipboardItemRow(
            item: item,
            isMostRecentCopy: item.id == manager.recentlyCopiedItemID,
            onCopy: {
                manager.copyToClipboard(item: item)
            },
            onPin: {
                manager.togglePin(for: item)
            },
            onOpen: {
                if let url = URL(string: item.content) {
                    NSWorkspace.shared.open(url)
                }
            }
        )
    }
}

