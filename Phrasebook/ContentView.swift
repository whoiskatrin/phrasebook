//
//  ContentView.swift
//  Phrasebook
//
//  Created by Christine Røde on 30/08/2024.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isNewCategorySheetPresented = false
     @State private var isEditCategorySheetPresented = false
     @State private var selectedLanguage: Language?
     @State private var categoryToEdit: Category?

    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) var categories: FetchedResults<Category>
     
     @FetchRequest(
         entity: Language.entity(),
         sortDescriptors: [NSSortDescriptor(keyPath: \Language.name, ascending: true)]
     ) var languages: FetchedResults<Language>

    
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
                                             destination: PhrasesView(category: category),
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
             .navigationTitle("Phrasebook")
             .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                     Button("Add", systemImage: "plus", action: presentNewCategorySheet)
//                         .buttonStyle(.borderedProminent)
//                         .controlSize(.small)
//                 }
//               ToolbarItem(placement: .navigationBarTrailing) {
//                      Picker("Language", selection: $selectedLanguage) {
//                          ForEach(languages, id: \.self) { language in
//                              Text(language.name ?? "Unknown").tag(language as Language?)
//                          }
//                    }
//               }
             }
             .sheet(isPresented: $isNewCategorySheetPresented) {
                  CategoryFormView()
                       .presentationDetents([.large])
             }
             .sheet(item: $categoryToEdit) { category in
                 CategoryFormView(category: category)
                     .presentationDetents([.large])
             }

        }
     .onAppear {
        prepopulateLanguagesIfNeeded()
    }
}
              
    func presentNewCategorySheet() {
        isNewCategorySheetPresented = true
    }
     
     private func editCategory(_ category: Category) {
         categoryToEdit = category
     }
     
     private func prepopulateLanguagesIfNeeded() {
         if languages.isEmpty {
             let mandarin = Language(context: viewContext)
             mandarin.name = "Mandarin"
             mandarin.code = "zh-CN"

             let cantonese = Language(context: viewContext)
             cantonese.name = "Cantonese"
             cantonese.code = "zh-HK"

             do {
                 try viewContext.save()
                 // Set Mandarin as default
                 selectedLanguage = mandarin
             } catch {
                 print("Error saving prepopulated languages: \(error)")
             }
         } else if selectedLanguage == nil {
             // Set the first language as default if none is selected
             selectedLanguage = languages.first
         }
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

