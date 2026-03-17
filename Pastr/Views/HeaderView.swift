//
//  HeaderView.swift
//  Pastr
//
//  Created by Fatin on 17/03/26.
//
import SwiftUI

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
