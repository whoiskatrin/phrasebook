//
//  ContentView.swift
//  Phrasebook
//
//  Created by Christine Røde on 30/08/2024.
//

import SwiftUI
import Foundation
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isNewCategorySheetPresented = false
    @State private var isLanguageSheetPresented = false
    @State private var isEditCategorySheetPresented = false
    @State private var selectedLanguage: Language?
    @State private var categoryToEdit: Category?
     @State private var refreshID = UUID()

    
    @EnvironmentObject private var languageManager: LanguageManager

    @FetchRequest(
        entity: Language.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.name, ascending: true)]
    ) var languages: FetchedResults<Language>
    
     @FetchRequest private var categories: FetchedResults<Category>

     init() {
         let request = Category.fetchRequest()
         request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.order, ascending: true)]
         if let languageID = LanguageManager.shared.selectedLanguageID?.uuidString {
             request.predicate = NSPredicate(format: "language.id == %@", languageID)
         }
         _categories = FetchRequest(fetchRequest: request)
     }
    let columns = [
     GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
     
     // Example icons for the grid
     let colors = [Color.blue, Color.orange, Color.red, Color.orange, Color.green]
     var index = 0

    
     var body: some View {
         NavigationView {
             Group {
                 if !categories.isEmpty {
                     ScrollView {
                         ZStack {
                             CategoryGridView(
                                 categories: categories,
                                 colors: colors,
                                 editCategory: editCategory,
                                 deleteCategory: deleteCategory,
                                 presentNewCategorySheet: presentNewCategorySheet
                             )
                         }
                         .id(refreshID) // Add this line
                         .compositingGroup()
                         .shadow(color: .black.opacity(0.08), radius: 1.5, x: 0, y: 1)
                         .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
                         .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                         .padding(.horizontal)
                     }
                 } else {
                     EmptyStateView(presentNewCategorySheet: presentNewCategorySheet)
                 }
             }
             .navigationTitle("\(selectedLanguage?.nameShort ?? "") Phrasebook")
             .toolbar {
                 if let selectedLanguageID = languageManager.selectedLanguageID,
                    let selectedLanguage = languages.first(where: { $0.id == selectedLanguageID }) {
                     let flagIcon = selectedLanguage.emoji ?? "🏳️"
                     
                     ToolbarItem(placement: .navigationBarLeading) {
                         Button(flagIcon, action: presentLanguageSheet)
                     }
                 }
             }
             .sheet(isPresented: $isNewCategorySheetPresented) {
                 CategoryFormView()
                     .presentationDetents([.large])
             }
             .sheet(isPresented: $isLanguageSheetPresented) {
                 LanguagePickerView()
             }
             .sheet(item: $categoryToEdit) { category in
                 CategoryFormView(category: category)
                     .presentationDetents([.large])
             }
          .onReceive(NotificationCenter.default.publisher(for: .categoryAdded)) { notification in
               if let newCategory = notification.object as? Category {
                    print("New category added: \(newCategory.name ?? "")")
               }
               updateCategoriesFetchRequest()
          }
         }
     }
          
     private func updateCategoriesFetchRequest() {
         // Print debug information
         print("Updating categories fetch request")
         print("Selected language ID: \(languageManager.selectedLanguageID?.uuidString ?? "nil")")
         print("Number of categories before update: \(categories.count)")
         
         // Update the fetch request's predicate
         if let languageID = languageManager.selectedLanguageID?.uuidString {
             categories.nsPredicate = NSPredicate(format: "language.id == %@", languageID)
         } else {
             categories.nsPredicate = nil
         }
         
         // Force view refresh
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 0.1 second delay
             self.refreshID = UUID()
             print("View refreshed")
             print("Number of categories after update: \(self.categories.count)")
         }
     }
     
    func presentNewCategorySheet() {
        isNewCategorySheetPresented = true
    }
     
     func presentLanguageSheet() {
         isLanguageSheetPresented = true
     }
     
     private func editCategory(_ category: Category) {
         categoryToEdit = category
     }
          
     private func deleteCategory(_ category: Category) {
         viewContext.delete(category)
         do {
             try viewContext.save()
         } catch {
             print("Error deleting category: \(error)")
         }
     }


}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

