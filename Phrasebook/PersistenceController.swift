//
//  PersistenceController.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Phrasebook")
        
        let storeURL = container.persistentStoreDescriptions.first?.url
        let fileManager = FileManager.default

        if let storeURL = storeURL {
            if fileManager.fileExists(atPath: storeURL.path) {
 //               print("Core Data store exists at: \(storeURL.path)")
            } else {
 //               print("Core Data store does not exist, a new one will be created.")
            }
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
