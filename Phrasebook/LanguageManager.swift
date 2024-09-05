import SwiftUI
import CoreData

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language?  // Store the currently selected language
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadCurrentLanguage()
    }
    
    // Load the last selected language or the default language on first app launch
    func loadCurrentLanguage() {
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        
        do {
            // Try to fetch the saved language
            let languages = try context.fetch(fetchRequest)
            if let savedLanguage = languages.first(where: { $0.isCurrent == true }) {
                currentLanguage = savedLanguage
            } else {
                // Load default language if none selected
                setDefaultLanguage()
            }
        } catch {
            print("Failed to fetch languages: \(error.localizedDescription)")
        }
    }
    
    // Switch to a new language and persist the change in Core Data
    func switchLanguage(to newLanguage: Language) {
        // Unset the old current language
        if let current = currentLanguage {
            current.isCurrent = false
        }
        
        // Set the new language as current
        newLanguage.isCurrent = true
        currentLanguage = newLanguage
        
        // Save the context
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    private func setDefaultLanguage() {
        // Assuming there is a default language defined in Core Data
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Chinese (Mandarin)")  // Example default language
        
        do {
            if let defaultLanguage = try context.fetch(fetchRequest).first {
                switchLanguage(to: defaultLanguage)
            }
        } catch {
            print("Failed to fetch the default language: \(error.localizedDescription)")
        }
    }
}
