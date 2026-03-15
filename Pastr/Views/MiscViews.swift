//
//  MiscViews.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI

/// The header view displaying the app title and session item count.
struct HeaderView: View {
    let itemCount: Int
    
    var body: some View {
        HStack {
            Image("hdAppIcon")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pastr")
                    .font(.headline)
                Text("\(itemCount) Items (Session)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(Date(), style: .time)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

/// The footer view with buttons for clearing history and quitting the app.
struct FooterView: View {
    @EnvironmentObject private var manager: ClipboardManager
    let onClear: () -> Void
    
    private static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: onClear) {
                Label("Clear Session", systemImage: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color("RowColor"), in: RoundedRectangle(cornerRadius: 8))

            Spacer()
            
            sessionTimerView

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.bar)
    }
    
    private var sessionTimerView: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let timeRemaining = manager.sessionEndDate?.timeIntervalSince(context.date) ?? 0.0
            let timeString = Self.timeFormatter.string(from: max(0, timeRemaining)) ?? "00:00"
            let isEndingSoon = timeRemaining > 0 && timeRemaining <= 30

            Label(timeString, systemImage: "timer")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(isEndingSoon ? .red : .secondary)
                .symbolVariant(isEndingSoon ? .fill : .none)
                .animation(.easeInOut, value: isEndingSoon)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("RowColor"), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

/// The view displayed when the clipboard history is empty.
struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .fontWeight(.light)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
            Text("Clipboard is Empty")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Press ⌘⇧V to show your history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// A styled header for sections in the list (e.g., "Pinned Items").
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
