import SwiftUI
import CoreData

struct PhrasesView: View {
    var category: Category

    @State private var searchText: String = ""
    @State private var isNewPhraseSheetPresented = false
    @State private var editMode: EditMode = .inactive
    @State private var animate = 0

    @Environment(\.managedObjectContext) private var viewContext  // Access the managedObjectContext
    @EnvironmentObject var languageManager: LanguageManager

    // Use @FetchRequest to fetch phrases automatically filtered by category and language
    @FetchRequest var allPhrases: FetchedResults<Phrase>

    init(category: Category, currentLanguage: Language?) {
        self.category = category

        // Ensure fetch request only fetches phrases for the selected category and language
        let categoryPredicate = NSPredicate(format: "category == %@", category)
        let languagePredicate = NSPredicate(format: "language == %@", currentLanguage ?? "")

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, languagePredicate])

        // Configure FetchRequest
        _allPhrases = FetchRequest<Phrase>(
            entity: Phrase.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Phrase.order, ascending: true)],
            predicate: compoundPredicate
        )
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
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary)
                    .symbolEffect(.bounce, value: animate)
                    .padding(.vertical, 0)
                    .opacity(0.5)
                
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
            NewPhraseView(currentCategory: category )
                .presentationDetents([.fraction(0.5)])
        }
    }

    func presentNewPhraseSheet() {
        isNewPhraseSheetPresented = true
    }

    private func deletePhrase(_ phrase: Phrase) {
        withAnimation {
            viewContext.delete(phrase)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting phrase: \(error)")
            }
        }
    }

    private func movePhrase(from source: IndexSet, to destination: Int) {
        var phrases = filteredPhrases
        phrases.move(fromOffsets: source, toOffset: destination)

        for (index, phrase) in phrases.enumerated() {
            phrase.order = Int16(index)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error saving context after reordering: \(error)")
        }
    }
}
