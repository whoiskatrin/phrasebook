//
//  NewPhraseView.swift
//  Phrasebook
//
//  Created by Christine Røde on 02/09/2024.
//

import Foundation
import SwiftUI
import CoreData

struct NewPhraseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    let currentCategory: Category
    
    @State private var englishPhrase: String = ""
    @State private var translatedPhrase: String = ""
    @State private var romanizedPhrase: String = ""
    @State private var isEditing: Bool = false
    @State private var isLoading: Bool = false
    @State private var translationCompleted: Bool = false
    @State private var selectedCategoryName: String = ""
    @State private var subCategory: String = ""

    @State private var translationTimer: Timer?
    private let debounceDuration: TimeInterval = 0.5
    
    @EnvironmentObject var languageManager: LanguageManager

    @FocusState private var isFocused: Bool
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) var categories: FetchedResults<Category>
    
    @FetchRequest(
        entity: Subcategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Subcategory.name, ascending: true)]
    ) var subcategories: FetchedResults<Subcategory>

    @FocusState private var isPhraseFieldFocused: Bool
    
    public init(currentCategory: Category) {
        self.currentCategory = currentCategory
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    TextField("Enter phrase in English", text: $englishPhrase)
                        .onChange(of: englishPhrase) {
                            startTranslationTimer()
                        }
                        .font(.system(size: 22, weight: .semibold))
                        .focused($isFocused)
                        .padding()
                        .background(Color(UIColor.systemGroupedBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                
                    if isLoading {
                            HStack {
                                ProgressView()
                                Text("Translating...")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemGroupedBackground))
                            .cornerRadius(12)
                            .padding()

                    } else if translationCompleted {
                            if isEditing {
                                TextField("Chinese", text: $translatedPhrase)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 22, weight: .medium))
                                    .background(Color(UIColor.systemGroupedBackground))
                                    .cornerRadius(12)
                                    .padding()
                                TextField("Transliteration", text: $romanizedPhrase)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 22, weight: .medium))
                                    .background(Color(UIColor.systemGroupedBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal)

                            } else {
                                PhraseCellView(phrase: createPreviewPhrase())
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding()
                                Button("Customize", action: { isEditing.toggle() })
                            }
                    }
                
                Spacer()
            
            Button(action: addPhrase) {
                Text("Save Phrase")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(8)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(12)
            .tint(.accentColor)
            .padding()
            .disabled(!translationCompleted)
          //  .background(Color(UIColor.systemGroupedBackground))
            }

            .navigationTitle("Add a Phrase")
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
    
    // New function to create preview phrase
    private func createPreviewPhrase() -> Phrase {
        let previewPhrase = Phrase(context: viewContext)
        previewPhrase.english = englishPhrase
        previewPhrase.translation = translatedPhrase
        previewPhrase.romanization = romanizedPhrase
        return previewPhrase
    }
    
    private func startTranslationTimer() {
        translationTimer?.invalidate()
        translationTimer = Timer.scheduledTimer(withTimeInterval: debounceDuration, repeats: false) { _ in
            self.performTranslation()
        }
    }
    
    func performTranslation() {
        guard !englishPhrase.isEmpty else {
            translationCompleted = false
            isLoading = false
            return
        }
        
        isLoading = true
        // Access currentLanguage from an instance of LanguageManager, not as a static property
        if let selectedLanguage = languageManager.currentLanguage,  // Assuming languageManager is an instance
           let codeTranslation = selectedLanguage.codeTranslation,
           let languageName = selectedLanguage.name {

            print("Trying to translate to: \(languageName) \(codeTranslation)")

            // Call your translate function
            translate(englishPhrase: englishPhrase, to: codeTranslation) { translatedText, transliteratedText in
                DispatchQueue.main.async {
                    // Update the UI on the main thread
                    self.translatedPhrase = translatedText ?? ""
                    self.romanizedPhrase = transliteratedText ?? ""
                    self.translationCompleted = true
                    self.isLoading = false
                }
            }

        } else {
            // Handle the case where selectedLanguage or its properties are nil
            print("Error: No language selected or missing language attributes.")
            isLoading = false
        }    }

    private func addPhrase() {
        guard !englishPhrase.isEmpty, !translatedPhrase.isEmpty else {
            print("All fields must be filled")
            return
        }

        let context = PersistenceController.shared.container.viewContext
        
        let newPhrase = Phrase(context: context)
        newPhrase.english = englishPhrase
        newPhrase.translation = translatedPhrase
        newPhrase.romanization = romanizedPhrase
        newPhrase.language = languageManager.currentLanguage

        
        // Set the category to the current category
        newPhrase.category = currentCategory
        print("Category set: \(currentCategory.name ?? "")")
        
        // Set the subcategory
        if !subCategory.isEmpty {
            let fetchRequest: NSFetchRequest<Subcategory> = Subcategory.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", subCategory)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let existingSubcategory = results.first {
                    newPhrase.subcategory = existingSubcategory
                    print("Existing subcategory set: \(existingSubcategory.name ?? "")")
                } else {
                    let newSubcategory = Subcategory(context: context)
                    newSubcategory.name = subCategory
                    newPhrase.subcategory = newSubcategory
                    print("New subcategory created and set: \(subCategory)")
                }
            } catch {
                print("Failed to fetch or create subcategory: \(error.localizedDescription)")
            }
        }
        
        do {
            try context.save()
            print("Phrase saved successfully. English: \(englishPhrase), Translation: \(translatedPhrase)")
            
            // Verify the save by fetching the phrase
            let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "english == %@", englishPhrase)
            let results = try context.fetch(fetchRequest)
            if let savedPhrase = results.first {
                print("Verified saved phrase - English: \(savedPhrase.english ?? ""), Translation: \(savedPhrase.translation ?? "")")
            } else {
                print("Failed to verify saved phrase")
            }
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save phrase: \(error.localizedDescription)")
        }
    }
    
    
}

struct NewPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let mockCategory = Category(context: context)
        mockCategory.name = "Mock Category"
        return NewPhraseView(currentCategory: mockCategory)
            .environment(\.managedObjectContext, context)
    }
}
