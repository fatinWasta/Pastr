//
//  SectionHeaderView.swift
//  Pastr
//
//  Created by Fatin on 17/03/26.
//

import SwiftUI

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
