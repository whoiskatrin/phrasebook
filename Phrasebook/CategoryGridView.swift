//
//  CategoryGridView.swift
//  Phrasebook
//
//  Created by Christine Røde on 05/09/2024.
//

import Foundation
import SwiftUI

struct CategoryGridView: View {
    let categories: FetchedResults<Category>
    let colors: [Color]
    let editCategory: (Category) -> Void
    let deleteCategory: (Category) -> Void
    let presentNewCategorySheet: () -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(categories, id: \.self) { category in
                PressableCategoryTile(
                    destination: PhrasesView(category: category, currentLanguage: LanguageManager.shared.currentLanguage),
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
