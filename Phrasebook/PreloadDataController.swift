//
//  PreloadDataController.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//

import Foundation
import CoreData

struct PhrasebookData: Codable {
    let categories: [CategoryData]
}

struct CategoryData: Codable {
    let name: String
    let phrases: [PhraseData]
}

struct PhraseData: Codable {
    let english: String
    let chinese: String
    let pinyin: String
    let subcategory: String?  // Optional subcategory
}

struct PreloadDataController {
    static func preloadData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.fetchLimit = 1

        // Check if data is already loaded
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                // Data already loaded, no need to preload
                return
            }
        } catch {
            print("Error checking for existing data: \(error)")
        }

        // Load JSON file
        guard let url = Bundle.main.url(forResource: "ChineseMandarin", withExtension: "json", subdirectory: "Resources"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load JSON file")
            return
        }

        let decoder = JSONDecoder()
        do {
            let phrasebook = try decoder.decode(PhrasebookData.self, from: data)

            for categoryData in phrasebook.categories {
                let category = Category(context: context)
                category.name = categoryData.name
                //category.id = UUID()

                for phraseData in categoryData.phrases {
                    let phrase = Phrase(context: context)
                    phrase.english = phraseData.english
                    phrase.translation = phraseData.chinese
                    phrase.romanization = phraseData.pinyin
                   // phrase.id = UUID()
                    phrase.category = category
                }
            }

            // Save the context
            try context.save()

        } catch {
            print("Failed to decode JSON or save context: \(error)")
        }
    }
}
