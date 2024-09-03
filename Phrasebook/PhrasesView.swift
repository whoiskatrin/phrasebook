//
//  PhrasesView.swift
//  Phrasebook
//
//  Created by Christine Røde on 31/08/2024.
//

import Foundation
import SwiftUI
import CoreData

struct PhrasesView: View {
    var category: Category

    @State private var searchText: String = ""
    @State private var isNewPhraseSheetPresented = false
    @State private var editMode: EditMode = .inactive
    @State private var animate = 0

    @FetchRequest var allPhrases: FetchedResults<Phrase>

    init(category: Category) {
        self.category = category

        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.order, ascending: true)]

        _allPhrases = FetchRequest(fetchRequest: request)
    }

    var filteredPhrases: [Phrase] {
        if searchText.isEmpty {
            return Array(allPhrases)
        } else {
            return allPhrases.filter {
                ($0.english?.localizedCaseInsensitiveContains(searchText) == true ||
                 $0.translation?.localizedCaseInsensitiveContains(searchText) == true ||
                 $0.romanization?.localizedCaseInsensitiveContains(searchText) == true)
            }
        }
    }

    var body: some View {
        
        VStack {
            if filteredPhrases.isEmpty {
                Image(systemName: category.symbol ?? "character.bubble.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary)
                    .symbolEffect(.bounce, value: animate)
                    .padding(.vertical, 0)
                    .opacity(0.5)
                //Text("No Phrases")
                //    .font(.title2)
                //    .foregroundColor(.gray)
                //    .padding(.vertical, 16)
                Button("Add Phrase", systemImage: "plus", action: presentNewPhraseSheet)
                    .buttonStyle(SmallButtonStyle())
                    .padding(.vertical, 24)


            } else {
                List {
                    ForEach(filteredPhrases, id: \.self) { phrase in
                        PhraseCellView(phrase: phrase)
                            .swipeActions(edge: .trailing) {
                                Button("Delete") {
                                    deletePhrase(phrase)
                                }
                                .tint(.red)
                            }
                    }
                    .onMove(perform: movePhrase)
                }
            }
        }
        .navigationTitle(category.name ?? "Phrases")
        .searchable(text: $searchText, prompt: "Search phrases")
        .onAppear {
            print("Fetched \(allPhrases.count) phrases")
            animate = 1
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", systemImage: "plus", action: presentNewPhraseSheet)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $isNewPhraseSheetPresented) {
            NewPhraseView(currentCategory: category)
                .presentationDetents([.fraction(0.5)])
        }

    }

    
    func presentNewPhraseSheet() {
        isNewPhraseSheetPresented = true
    }
    
    private func deletePhrase(_ phrase: Phrase) {
        withAnimation {
            let viewContext = PersistenceController.shared.container.viewContext
            viewContext.delete(phrase)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting phrase: \(error)")
            }
        }
    }
    
    private func movePhrase(from source: IndexSet, to destination: Int) {
        let viewContext = PersistenceController.shared.container.viewContext
        
        // Convert filtered phrases to mutable array
        var phrases = filteredPhrases
        
        // Perform the move
        phrases.move(fromOffsets: source, toOffset: destination)
        
        // Update the order
        for (index, phrase) in phrases.enumerated() {
            phrase.order = Int16(index)
        }
        
        // Save the context
        do {
            try viewContext.save()
        } catch {
            print("Error saving context after reordering: \(error)")
        }
    }

}
