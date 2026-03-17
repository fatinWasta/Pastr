import SwiftUI
import AppKit
import Combine
// MARK: - Data Models

/// Defines the type of content stored in the clipboard.
enum ContentType: String, Hashable, CaseIterable {
    case text = "Text"
    case url = "URLs"
    case codeSnippet = "Code"
    case token = "Tokens"
}

/// Represents a single item in our clipboard history.
struct ClipboardItem: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let type: ContentType
    let subtitle: String
    let createdAt: Date = .init()
    var isPinned: Bool = false
}

// MARK: - Clipboard Manager (Observable Model)

/// The single source of truth for the application's clipboard data and presentation state.
///
/// This class monitors the system pasteboard, stores `ClipboardItem`s, and also holds
/// the state required by the UI, such as search text and filtering options.
@MainActor
class ClipboardManager: ObservableObject {
    
    // The complete, unfiltered list of all clipboard items. This is the source of truth.
    @Published private(set) var clipboardItems: [ClipboardItem] = []
    
    // Tracks the ID of the item that was most recently copied to the pasteboard.
    @Published private(set) var recentlyCopiedItemID: UUID?
    
    // State for the UI, bound to the search and filter controls.
    @Published var searchText = ""
    @Published var selectedFilter: ContentType? = nil

    // MARK: - Session Timer Properties
    let sessionDuration: TimeInterval = 5 * 60 // 5 minutes
    @Published private(set) var sessionEndDate: Date?
    let sessionDidEnd = PassthroughSubject<Void, Never>()
    private var sessionManagementTask: Task<Void, Never>?

    // MARK: - Computed Properties for the View
    
    /// Returns the filtered list of pinned items based on current search and filter state.
    var pinnedItems: [ClipboardItem] {
        filteredItems.filter { $0.isPinned }
    }
    
    /// Returns the filtered list of session history items based on current search and filter state.
    var historyItems: [ClipboardItem] {
        filteredItems.filter { !$0.isPinned }
    }
    
    /// A private computed property that performs the actual filtering logic.
    private var filteredItems: [ClipboardItem] {
        clipboardItems.filter { item in
            let matchesFilter = (selectedFilter == nil || item.type == selectedFilter)
            let matchesSearch = searchText.isEmpty || item.content.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }
    
    // MARK: - Private Properties
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int

    private let itemLifetime: TimeInterval = 30 * 60 // 30 minutes
    private let cleanupInterval: TimeInterval = 60   // 1 minute

    private var monitoringTask: Task<Void, Never>?
    private var cleanupTask: Task<Void, Never>?

    // MARK: - Initialization & Monitoring
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }
    
    deinit {
        monitoringTask?.cancel()
        cleanupTask?.cancel()
        sessionManagementTask?.cancel()
    }
    
    private func startMonitoring() {
        monitoringTask = Task { [weak self] in
            while let self = self, !Task.isCancelled {
                self.checkForChanges()
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    // Task was cancelled
                    return
                }
            }
        }
        
        cleanupTask = Task { [weak self] in
            while let self = self, !Task.isCancelled {
                self.clearOldItems()
                do {
                    try await Task.sleep(for: .seconds(self.cleanupInterval))
                } catch {
                    // Task was cancelled
                    return
                }
            }
        }
    }

    private func checkForChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        guard let originalString = pasteboard.string(forType: .string) else { return }

        let copiedString = originalString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !copiedString.isEmpty else { return }
        
        // If this item already exists, mark it as copied and move it to the top of the history.
        if let existingIndex = clipboardItems.firstIndex(where: { $0.content == copiedString }) {
            let existingItem = clipboardItems[existingIndex]
            self.recentlyCopiedItemID = existingItem.id
            
            if !existingItem.isPinned {
                let itemToMove = clipboardItems.remove(at: existingIndex)
                let firstUnpinnedIndex = clipboardItems.firstIndex(where: { !$0.isPinned }) ?? clipboardItems.endIndex
                clipboardItems.insert(itemToMove, at: firstUnpinnedIndex)
            }
            return
        }

        let historyWasEmpty = self.historyItems.isEmpty

        // Create and insert the new item.
        let (type, subtitle) = ContentAnalyzer.analyze(string: copiedString)
        let newItem = ClipboardItem(content: copiedString, type: type, subtitle: subtitle)
        self.recentlyCopiedItemID = newItem.id // Mark the new item as recently copied.
        
        let firstUnpinnedIndex = clipboardItems.firstIndex(where: { !$0.isPinned }) ?? clipboardItems.endIndex
        clipboardItems.insert(newItem, at: firstUnpinnedIndex)
        
        if historyWasEmpty {
            startSessionTimer()
        }
    }
    
    // MARK: - Session Management
    
    /// Starts a single session countdown. This is called when the first item is added.
    private func startSessionTimer() {
        sessionManagementTask?.cancel()
        
        sessionManagementTask = Task {
            sessionEndDate = Date().addingTimeInterval(sessionDuration)
            
            do {
                try await Task.sleep(for: .seconds(sessionDuration))
            } catch {
                // Task was cancelled, so we exit gracefully.
                return
            }
            
            // When the timer finishes, send notification and clear the session.
            sessionDidEnd.send()
            clearSession()
        }
    }

    /// Stops the session timer and resets the end date. This is called when the history becomes empty.
    private func endSessionTimer() {
        sessionManagementTask?.cancel()
        sessionManagementTask = nil
        sessionEndDate = nil
    }

    // MARK: - Public API (User Intent)
    
    func togglePin(for item: ClipboardItem) {
        guard let index = clipboardItems.firstIndex(where: { $0.id == item.id }) else { return }
        var itemToMove = clipboardItems.remove(at: index)
        itemToMove.isPinned.toggle()
        
        if itemToMove.isPinned {
            clipboardItems.insert(itemToMove, at: 0)
        } else {
            let firstUnpinnedIndex = clipboardItems.firstIndex(where: { !$0.isPinned }) ?? clipboardItems.endIndex
            clipboardItems.insert(itemToMove, at: firstUnpinnedIndex)
        }
    }

    func copyToClipboard(item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        recentlyCopiedItemID = item.id // Mark this item as copied.
    }
    
    func clearSession() {
        clipboardItems.removeAll { !$0.isPinned }
        recentlyCopiedItemID = nil // Clear the copied status.
        
        // If clearing the session results in an empty history, stop the timer.
        if historyItems.isEmpty {
            endSessionTimer()
        }
    }
    
    private func clearOldItems() {
        let now = Date()
        clipboardItems.removeAll { !$0.isPinned && now.timeIntervalSince($0.createdAt) > itemLifetime }
    }
}
