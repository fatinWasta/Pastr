//
//  MiscViews.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI

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
