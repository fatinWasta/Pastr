//
//  FooterView.swift
//  Pastr
//
//  Created by Fatin on 17/03/26.
//


import SwiftUI

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
