import SwiftUI

@main
struct MyApp: App {
    // Set up Core Data stack
    let persistenceController = PersistenceController.shared
    
    // Delay initialization of LanguageManager until it's actually needed
    @StateObject private var languageManager = LanguageManager(context: PersistenceController.shared.container.viewContext)
    
    init() {
        // Preload data in the init method
        PreloadDataController.preloadData(context: persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)  // Provide the language manager globally
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
