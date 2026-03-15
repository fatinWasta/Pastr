//
//  SearchAndFilterView.swift
//  Pastr
//
//  Created by Fatin on 2026-03-15.
//  Copyright © Pastr. All rights reserved.
//

import SwiftUI

/// A view containing the search bar and filter buttons.
struct SearchAndFilterView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: ContentType?

    private let filters: [ContentType] = [.codeSnippet, .url, .token]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchBar
            filterButtons
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search clipboard...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(8)
        .background(Color("RowColor"), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var filterButtons: some View {
        HStack() {
            FilterButton(title: "All", isSelected: selectedFilter == nil) {
                selectedFilter = nil
            }
            
            ForEach(filters, id: \.self) { filter in
                FilterButton(title: filter.rawValue, isSelected: selectedFilter == filter) {
                    selectedFilter = filter
                }
            }
        }
    }
}

/// A reusable button styled for the filter bar.
private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .accentColor : Color("RowColor"))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
