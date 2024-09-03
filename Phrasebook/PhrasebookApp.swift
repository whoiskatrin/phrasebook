//
//  PhrasebookApp.swift
//  Phrasebook
//
//  Created by Christine Røde on 30/08/2024.
//

import SwiftUI

@main
struct PhrasebookApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
  //      PreloadDataController.preloadData(context: persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
