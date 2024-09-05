import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isNewCategorySheetPresented = false
    @State private var isLanguageSheetPresented = false
    @State private var isEditCategorySheetPresented = false
     @State private var showAlert = false
    @State private var categoryToEdit: Category?
    
    @EnvironmentObject var languageManager: LanguageManager
    @State private var categoryPredicate: NSPredicate? = nil  // State variable for the fetch predicate
    
    // Use @FetchRequest to automatically track categories
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        predicate: nil
    ) var categories: FetchedResults<Category>

    let colors = [Color.blue, Color.orange, Color.red, Color.orange, Color.green]
    
    var body: some View {
        NavigationView {
            Group {
                if categories.isEmpty {
                    EmptyStateView {
                        isNewCategorySheetPresented = true
                    }
                } else {
                    ScrollView {
                        ZStack {
                            CategoryGridView(
                                categories: Array(categories),
                                colors: colors,
                                editCategory: editCategory,
                                deleteCategory: deleteCategory,
                                presentNewCategorySheet: { isNewCategorySheetPresented = true }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Phrasebook")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isLanguageSheetPresented = true }) {
                        Text(languageManager.currentLanguage?.emoji ?? "🏳️")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
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
            .alert("Please delete and reinstall the app", isPresented: $showAlert) {
                 Button("OK") { }
            } message: {
                Text("I broke things when I added new features sorry :)")
            }
            .onAppear {
                updateFetchPredicate()
            }
            .onChange(of: languageManager.currentLanguage) { oldLanguage, newLanguage in
                print("Language changed from \(oldLanguage?.name ?? "None") to \(newLanguage?.name ?? "None")")
                updateFetchPredicate()
            }
        }
    }

    // Dynamically update the fetch request predicate when the language changes
     private func updateFetchPredicate() {
         guard let currentLanguage = languageManager.currentLanguage else {
             categories.nsPredicate = nil
              showAlert = true
             return
         }
         
         DispatchQueue.main.async {
             categories.nsPredicate = NSPredicate(format: "language == %@", currentLanguage)
              print("Refreshed categories")
         }
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

