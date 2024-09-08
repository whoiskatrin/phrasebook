//
//  ContentView.swift
//  Phrasebook
//
//  Created by Christine Røde on 08/09/2024.
//

import SwiftUI
import Foundation
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var languageManager: LanguageManager
    
    @State private var isNewCategorySheetPresented = false
    @State private var isLanguageSheetPresented = false
    @State private var categoryToEdit: Category?
    
    @FetchRequest private var categories: FetchedResults<Category>
     
    let colors: [Color] = [.blue, .green, .orange, .red, .purple]
     
    init() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.order, ascending: true)]
        _categories = FetchRequest(fetchRequest: request)
    }
    
    var filteredCategories: [Category] {
        categories.filter { $0.language?.id == languageManager.selectedLanguageID }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if !filteredCategories.isEmpty {
                    ScrollView {
                        CategoryGridView(
                            categories: filteredCategories,
                            colors: colors,
                            editCategory: editCategory,
                            deleteCategory: deleteCategory,
                            presentNewCategorySheet: presentNewCategorySheet,
                            currentLanguage: languageManager.currentLanguage
                        )
                        .padding(.horizontal)
                    }
                } else {
                    EmptyStateView(presentNewCategorySheet: presentNewCategorySheet)
                }
            }
            .navigationTitle("\(languageManager.currentLanguage?.nameShort ?? "") Phrasebook")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.currentLanguage?.emoji ?? "🏳️", action: presentLanguageSheet)
                }
            }
            .sheet(isPresented: $isNewCategorySheetPresented) {
                CategoryFormView()
            }
            .sheet(isPresented: $isLanguageSheetPresented) {
                LanguagePickerView()
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryFormView(category: category)
            }
            .onChange(of: languageManager.selectedLanguageID) { _ in
                updateCategoriesFetchRequest()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            DispatchQueue.main.async {
                updateCategoriesFetchRequest()
            }
        }
    }
    
    private func updateCategoriesFetchRequest() {
        print("Updating categories fetch request")
        print("Selected language ID: \(languageManager.selectedLanguageID?.uuidString ?? "nil")")
        print("Number of categories before update: \(categories.count)")
        
        // The filtering is done in the view
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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

struct EmptyStateView: View {
    var presentNewCategorySheet: () -> Void
    
    var body: some View {
        VStack {
            Text("No Categories")
                .font(.title2)
                .foregroundStyle(.secondary)
            Button("Add New", action: presentNewCategorySheet)
                .padding()
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .bold()
                .cornerRadius(50)
        }
    }
}
