
# Pastr - A Smart Clipboard Manager for macOS

Pastr is a lightweight, local session-based clipboard manager built for macOS. It lives in your menu bar, providing quick access to your recent clipboard history with intelligent content detection and a clean, modern interface. 


---

## ✨ Features

-   **Pastr respects your Privacy by not tracking any of the copied data at all. No tracking, no analytics, just pure local Clipboard.**
-   **Automatic Clipboard Monitoring**: Passively listens for text copied to the pasteboard in the background.
-   **Intelligent Content Detection**: Automatically categorizes clipboard items as Text, URLs, Code Snippets, or Tokens.
    -   **Code Analysis**: Recognizes snippets from multiple languages (Swift, Python, Java, JavaScript, SQL) and formats (JSON, Shell).
    -   **Token Recognition**: Identifies various token types, including JWTs, UUIDs, and common API keys (e.g., GitHub, Stripe).
-   **Session-Based History**: Non-pinned items are automatically cleared after a configurable session (default: 5 minutes), keeping your history relevant and clean.
-   **Persistent Timer**: The session timer runs continuously from app launch, resetting automatically when a new item is added to an empty clipboard.
-   **Pinning**: Pin important items to keep them indefinitely. Pinned items are always shown at the top and are excluded from automatic session clearing.
-   **Search & Filtering**: Quickly find items with a full-text search and one-click filters for Code, URLs, and Tokens.
-   **Modern UI**: Built entirely with SwiftUI for a responsive and native macOS experience.
-   **Safe & Efficient**: Uses modern Swift Concurrency (`async/await`, `Task`) for safe and efficient background processing, avoiding race conditions and ensuring the UI remains smooth.

## 🏛️ High-Level Design & Architecture

Pastr is built around a central data model and a declarative UI, following modern Swift development practices.

### Core Model: `ClipboardManager`

-   The entire application state is managed by a single `@MainActor`-isolated `ObservableObject` called `ClipboardManager`. This class is the single source of truth.
-   It's responsible for:
    -   Monitoring the `NSPasteboard` for changes.
    -   Storing the list of `ClipboardItem`s.
    -   Handling business logic like pinning, clearing the session, and copying items back to the pasteboard.
    -   Managing the continuous session timer loop.

### UI: SwiftUI

-   The user interface is built declaratively with SwiftUI.
-   The main `ContentView` observes the `ClipboardManager` via `@EnvironmentObject` and assembles the various sub-views (`HeaderView`, `FooterView`, `SearchAndFilterView`, etc.).
-   Data flows unidirectionally from the `ClipboardManager` to the views. User actions in the views call methods on the manager to mutate the state.

### Asynchronous Operations: Swift Concurrency

-   Instead of traditional `Timer` objects, the app uses `Task` and `await Task.sleep(for:)` for all periodic operations (pasteboard checking, session management, and auto-cleanup of old items).
-   This approach is safer, avoids potential threading issues with `@MainActor`, and is more integrated with the Swift language.

### Content Analysis: `ContentAnalyzer` & Strategy Pattern

-   The "smart" part of Pastr lives in the `ContentAnalyzer` struct.
-   It uses a chain-of-responsibility approach to identify content, starting with the most specific types (URLs, Tokens) and falling back to more general ones.
-   For **code analysis**, it employs the **Strategy Pattern**. Each language/format has its own `CodeAnalysisStrategy` object. This makes the system incredibly easy to extend—to add support for a new language, you simply create a new strategy struct without modifying the existing analyzer.

## 🚀 How to Build

1.  Clone the repository.
2.  Open `Pastr.xcodeproj` in Xcode.
3.  Select a team for code signing in the "Signing & Capabilities" tab.
4.  Press `Cmd+R` to build and run the application.


## What's Next?
-   Hotkey implementation for quick access on anywhere in the system when app is in background.


---
Made with ❤️ and Swift.
Fatin.
