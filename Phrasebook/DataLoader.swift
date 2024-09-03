//
//  DataLoader.swift
//  Phrasebook
//
//  Created by Christine Røde on 30/08/2024.
//

import SwiftUI
import Foundation

class DataLoader: ObservableObject {
//    @Published var phrasebook: Phrasebook?  // This is the single declaration of `phrasebook`.

//    init() {
//        loadJSON()
//    }
//
//    func loadJSON() {
//        // Print to ensure the function is called
//        print("Attempting to load JSON...")
//
//        // Adjust this path to match where your JSON file is located in the bundle
//        guard let url = Bundle.main.url(forResource: "ChineseMandarin", withExtension: "json") else {
//            print("Failed to locate ChineseMandarin.json in bundle.")
//            return
//        }
//
//        // Print to confirm the URL was found
//        print("Found JSON file at: \(url)")
//
//        do {
//            let data = try Data(contentsOf: url)
//            let phrasebook = try JSONDecoder().decode(Phrasebook.self, from: data)
//            self.phrasebook = phrasebook  // This assigns the decoded data to the `phrasebook` property.
//
//            // Print to confirm successful decoding
//            print("Successfully decoded JSON. Found \(phrasebook.categories.count) categories.")
//
//        } catch {
//            print("Failed to load or decode ChineseMandarin.json: \(error)")
//        }
//    }
}
