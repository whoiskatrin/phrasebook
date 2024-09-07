//
//  CategoryGridView.swift
//  Phrasebook
//
//  Created by Christine Røde on 05/09/2024.
//

import Foundation
import SwiftUI

struct CategoryGridView: View {
    var categories: [Category]
    var colors: [Color]
    var editCategory: (Category) -> Void
    var deleteCategory: (Category) -> Void
    var presentNewCategorySheet: () -> Void  // Closure to present new category sheet
    
    @EnvironmentObject var languageManager: LanguageManager  // Access current language
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.self) { category in
                if let currentLanguage = languageManager.currentLanguage {  // Ensure currentLanguage is available
                    PressableCategoryTile(
                        destination: PhrasesView(category: category, currentLanguage: currentLanguage),  // Pass the currentLanguage
                        label: (category.name ?? "Unknown Category"),
                        symbol: Image(systemName: category.symbol ?? "folder")
                    )
                    .contextMenu {
                        Button {
                            editCategory(category)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            // Add Category Button
            Button(action: presentNewCategorySheet) {
                VStack {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(colors[0])
                        .padding()
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(colors[0])
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors[0].opacity(0.1))
                .cornerRadius(16)
            }
            .zIndex(100)
        }
        .shadow(color: Color.primary.opacity(0.08), radius: 1.5, x: 0, y: 1)
        .shadow(color: Color.primary.opacity(0.06), radius: 16, x: 0, y: 6)
        .shadow(color: Color.primary.opacity(0.06), radius: 20, x: 0, y: 10)

    }
}


struct EmptyStateView: View {
    var presentNewCategorySheet: () -> Void  // Closure to present the new category sheet
    
    var body: some View {
        VStack {
            Text("No Categories")
                .font(.title2)
                .foregroundStyle(.secondary)
            Button("Add New", systemImage: "plus", action: presentNewCategorySheet)
                .padding()
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .bold()
                .cornerRadius(50)
        }
    }
}
