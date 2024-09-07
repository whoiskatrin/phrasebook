import Foundation
import SwiftUI
import CoreData

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let viewContext: NSManagedObjectContext
        
    @Published var selectedLanguageID: UUID? {
        didSet {
            if let id = selectedLanguageID {
                UserDefaults.standard.set(id.uuidString, forKey: "selectedLanguageID")
                updateCurrentLanguage()
            }
        }
    }
    
  @Published var currentLanguage: Language?

    private init() {
        let persistenceController = PersistenceController.shared
        self.viewContext = persistenceController.container.viewContext
        
        if let savedIDString = UserDefaults.standard.string(forKey: "selectedLanguageID"),
           let savedID = UUID(uuidString: savedIDString) {
            self.selectedLanguageID = savedID
        } else {
            initializeDefaultLanguage()
        }
        
        updateCurrentLanguage()
    }
    
    private func initializeDefaultLanguage() {
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Mandarin")
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let mandarinLanguage = results.first {
                self.selectedLanguageID = mandarinLanguage.id
            } else {
                print("Error: Mandarin language not found in the database")
            }
        } catch {
            print("Error fetching Mandarin language: \(error)")
        }
    }
    
    private func updateCurrentLanguage() {
        guard let id = selectedLanguageID else {
            currentLanguage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            currentLanguage = results.first
        } catch {
            print("Error fetching current language: \(error)")
            currentLanguage = nil
        }
    }
    
    func switchLanguage(to language: Language) {
        self.selectedLanguageID = language.id
        self.currentLanguage = language
    }

}

