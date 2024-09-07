import SwiftUI
import CoreData

@main
struct PhrasebookApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var languageManager = LanguageManager.shared

    init() {
        PreloadDataController.preloadData(context: persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(languageManager)
                .onAppear {
                    setInitialLanguage()
                }
        }
    }

    private func setInitialLanguage() {
        if languageManager.selectedLanguageID == nil {
            let context = persistenceController.container.viewContext
            let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
            fetchRequest.fetchLimit = 1
            
            do {
                if let firstLanguage = try context.fetch(fetchRequest).first {
                    languageManager.selectedLanguageID = firstLanguage.id
                }
            } catch {
                print("Error fetching initial language: \(error)")
            }
        }
        
        // Notify observers that the language has been set or changed
        languageManager.objectWillChange.send()
    }
}
