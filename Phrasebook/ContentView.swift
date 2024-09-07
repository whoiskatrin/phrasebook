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
     
     @EnvironmentObject private var languageManager: LanguageManager

     @FetchRequest(
         entity: Category.entity(),
         sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
     ) var categories: FetchedResults<Category>

     @FetchRequest(
         entity: Language.entity(),
         sortDescriptors: [NSSortDescriptor(keyPath: \Language.name, ascending: true)]
     ) var languages: FetchedResults<Language>
     
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
                              ZStack() {
                                   LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(categories, id: \.self) { category in
                                             PressableCategoryTile(
                                                  destination: PhrasesView(category: category, currentLanguage: languageManager.currentLanguage),
                                                  label: (category.name ?? "Unknown Category"),
                                                  symbol: Image(systemName: category.symbol ?? "folder")
                                             )
                                             .contextMenu {
                                                  Button() {
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
                              .compositingGroup()
                              .shadow(color: .black.opacity(0.08), radius: 1.5, x: 0, y: 1)
                              .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
                              .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                              .padding(.horizontal)
                         }
                    } else {
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
               .navigationTitle("\(selectedLanguage?.nameShort ?? "") Phrasebook")
               .toolbar {
                    if let selectedLanguageID = languageManager.selectedLanguageID,
                       let selectedLanguage = languages.first(where: { $0.id == selectedLanguageID }) {
                         let flagIcon = selectedLanguage.emoji ?? "🏳️"
                         
                         ToolbarItem(placement: .navigationBarLeading) {
                            //  Button(flagIcon, systemImage: "arrowtriangle.down.fill",  action: presentLanguageSheet)
                              Button(flagIcon,  action: presentLanguageSheet)
                            //    .buttonStyle(.bordered)
                            //  .controlSize(.small)
                         }
                    }}
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
               
          }
     }
     
     private func updateCategoriesFetchRequest() {
         if let languageID = languageManager.selectedLanguageID?.uuidString {
             let predicate = NSPredicate(format: "language.id == %@", languageID)
             categories.nsPredicate = predicate
         } else {
             categories.nsPredicate = nil
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

