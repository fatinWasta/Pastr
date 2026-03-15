//
//  ClipboardViewModel.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI
import Combine

/// Manages the state and presentation logic for the clipboard content.
///
/// This class acts as the bridge between the `ClipboardManager` (Model) and the `ContentView` (View),
/// handling filtering, search, and user actions.
@MainActor
class ClipboardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The final list of pinned items to be displayed, after filtering.
    @Published private(set) var pinnedItems: [ClipboardItem] = []
    
    /// The final list of session history items to be displayed, after filtering.
    @Published private(set) var historyItems: [ClipboardItem] = []
    
    /// The text currently entered in the search field.
    @Published var searchText = ""
    
    /// The content type currently selected for filtering, or `nil` if "All" is selected.
    @Published var selectedFilter: ContentType? = nil
    
    // MARK: - Private Properties
    
    private let clipboardManager: ClipboardManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    
    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
        
        // Subscribe to changes from the model and the UI state to re-apply filters.
        subscribeToChanges()
    }
    
    // MARK: - Public Methods (User Intent)
    
    /// Copies the content of a given `ClipboardItem` back to the system pasteboard.
    func copyToClipboard(item: ClipboardItem) {
        clipboardManager.copyToClipboard(item: item)
    }
    
    /// Toggles the pinned state of a given `ClipboardItem`.
    func togglePin(for item: ClipboardItem) {
        clipboardManager.togglePin(for: item)
    }
    
    /// Clears all unpinned items from the clipboard history.
    func clearSession() {
        clipboardManager.clearSession()
    }
    
    // MARK: - Private Methods
    
    /// Sets up Combine pipelines to listen for changes that require the view to be updated.
    private func subscribeToChanges() {
        // Combine the publishers for all data sources that affect the final displayed list.
        Publishers.CombineLatest3(
            clipboardManager.$clipboardItems, // 1. The source of truth from the model
            $searchText,                     // 2. The user's search query
            $selectedFilter                  // 3. The user's filter selection
        )
        .map { allItems, searchText, selectedFilter in
            // Perform filtering logic based on the latest data.
            self.filter(items: allItems, with: searchText, by: selectedFilter)
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (pinned, history) in
            // Update the published properties that the View is observing.
            self?.pinnedItems = pinned
            self?.historyItems = history
        }
        .store(in: &cancellables)
    }
    
    /// Filters a list of clipboard items based on search text and a selected content type.
    /// - Returns: A tuple containing arrays of pinned and unpinned (history) items.
    private func filter(items: [ClipboardItem], with searchText: String, by selectedFilter: ContentType?) -> (pinned: [ClipboardItem], history: [ClipboardItem]) {
        let filteredItems = items.filter { item in
            let matchesFilter = (selectedFilter == nil || item.type == selectedFilter)
            
            let matchesSearch = searchText.isEmpty || item.content.localizedCaseInsensitiveContains(searchText)
            
            return matchesFilter && matchesSearch
        }
        
        // Partition the filtered results into pinned and history arrays.
        let pinned = filteredItems.filter { $0.isPinned }
        let history = filteredItems.filter { !$0.isPinned }
        
        return (pinned, history)
    }
}
