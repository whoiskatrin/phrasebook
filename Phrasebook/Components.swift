//
//  Components.swift
//  Phrasebook
//
//  Created by Christine Røde on 03/09/2024.
//

import Foundation
import SwiftUI

struct PressableCategoryTile<Destination: View>: View {
    let destination: Destination
    let label: String
    let symbol: Image
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                symbol
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.primary)
                    .padding()
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isPressed ? Color(UIColor.systemGray4) : Color(UIColor.systemBackground))
            .cornerRadius(16)
        }
    }
}

struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .controlSize(.regular)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .bold()
            .cornerRadius(50)
    }
}

