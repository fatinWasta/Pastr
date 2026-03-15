//
//  ClipboardItemRow.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI

/// A view that displays a single row in the clipboard history list.
struct ClipboardItemRow: View {
    let item: ClipboardItem
    
    // Actions are passed in from the parent view, promoting reusability.
    let onCopy: () -> Void
    let onPin: () -> Void
    let onOpen: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ItemIconView(type: item.type)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.content)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.body)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(item.createdAt.timeAgoDisplay())
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button(action: onPin) {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .foregroundStyle(item.isPinned ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color("RowColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(perform: onCopy)
        .contextMenu {
            Button("Copy", action: onCopy)
            Button(item.isPinned ? "Unpin" : "Pin", action: onPin)
            
            if item.type == .url {
                Divider()
                Button("Open in Browser", action: onOpen)
            }
        }
    }
}

/// A helper view that displays the icon for a specific content type.
private struct ItemIconView: View {
    let type: ContentType
    
    var body: some View {
        Image(systemName: iconName)
            .font(.callout)
            .fontWeight(.medium)
            .frame(width: 28, height: 28)
            .background(iconBackgroundColor.opacity(0.15))
            .foregroundStyle(iconBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var iconName: String {
        switch type {
        case .text: "character.cursor.ibeam"
        case .url: "link"
        case .codeSnippet: "chevron.left.forwardslash.chevron.right"
        case .token: "key.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch type {
        case .text: .brown
        case .url: .blue
        case .codeSnippet: .purple
        case .token: .orange
        }
    }
}

/// An extension to format a date as a relative time string (e.g., "5 minutes ago").
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
