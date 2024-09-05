//
//  NewCategoryView.swift
//  Phrasebook
//
//  Created by Christine Røde on 02/09/2024.
//

import Foundation
import CoreData
import SwiftUI


struct CategoryFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @FocusState private var isFocused: Bool
    
    let existingCategory: Category?
    
    
    @EnvironmentObject var languageManager: LanguageManager

    
    // Example icons for the grid
    let icons = ["folder.fill", "star.circle.fill", "fork.knife", "wineglass.fill", "bubble.left.and.text.bubble.right.fill", "bus", "airplane", "hand.raised.fill", "hand.wave.fill", "cross.case.fill", "bandage.fill", "cross.fill", "pills.fill", "map.fill", "heart.fill", "house.fill", "building.2.fill", "carrot.fill", "cup.and.saucer.fill", "fireworks", "party.popper.fill", "figure.dance", "figure.socialdance", "car.fill", "arrow.triangle.turn.up.right.diamond.fill", "building.columns.fill", "person.text.rectangle.fill", "sos.circle.fill", "bag.fill", "suitcase.cart.fill", "suitcase.rolling.fill", "bell.fill", "person.fill.questionmark", "shield.fill", "cloud.rain.fill", "mountain.2.fill"]

    init(category: Category? = nil) {
        self.existingCategory = category
        _categoryName = State(initialValue: category?.name ?? "")
        _selectedIcon = State(initialValue: category?.symbol ?? icons[0])
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section() {
                        // TextField for Category Name
                        TextField("Category Name", text: $categoryName)
                            .font(.system(size: 22, weight: .semibold))
                            .padding(.vertical, 5)
                            .focused($isFocused)
                    }
                    
                    Section(header: Text("Icon")) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                            ForEach(icons, id: \.self) { icon in
                                IconSelectionView(icon: icon, isSelected: icon == selectedIcon)
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                    }
                }
                
                Button(action: saveCategory) {
                    Text(existingCategory == nil ? "Add Category" : "Save Changes")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(8)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(12)
                .tint(.accentColor)
                .padding()
                .disabled(categoryName.isEmpty)
                
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            .navigationTitle(existingCategory == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })

        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }

    private func saveCategory() {
        guard !categoryName.isEmpty else {
            print("Category name is missing.")
            return
        }

        let context = PersistenceController.shared.container.viewContext
        let category = existingCategory ?? Category(context: context)
        category.name = categoryName
        category.symbol = selectedIcon
        
        // Validate and associate the category with the current language
        guard let currentLanguage = languageManager.currentLanguage else {
            print("Error: No current language set in LanguageManager")
            return
        }
        
        category.language = currentLanguage
        
        print("Saving category '\(categoryName)' with symbol '\(selectedIcon)' to language: \(currentLanguage.name ?? "Unknown")")

        do {
            try context.save()
            print("Category saved successfully to language: \(currentLanguage.name ?? "Unknown")")
        } catch {
            print("Failed to save category: \(error.localizedDescription)")
        }

        presentationMode.wrappedValue.dismiss()
    }
}

struct IconSelectionView: View {
    let icon: String
    let isSelected: Bool

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .foregroundColor(isSelected ? Color.blue : Color.primary.opacity(0.8))
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .padding(14)
            .fontWeight(.semibold)
            .background(isSelected ? Color.blue.opacity(0.12) : Color.gray.opacity(0))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
}

struct CategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFormView()
        CategoryFormView(category: Category()) // Add this for editing preview
    }
}

