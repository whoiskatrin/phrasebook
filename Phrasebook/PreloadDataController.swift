//
//  PreloadDataController.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//

import Foundation
import SwiftUI
import CoreData

struct PhrasebookData: Codable {
    let categories: [CategoryData]
}

struct CategoryData: Codable {
    let name: String
    let symbol: String
    let phrases: [PhraseData]
}

struct PhraseData: Codable {
    let english: String
    let translation: String
    let transliteration: String?
    let subcategory: String?  // Optional subcategory
}

struct VoiceData {
    let code: String
    let name: String
    let gender: String
    let dialect: String
}

struct PreloadDataController {
    @EnvironmentObject var languageManager: LanguageManager

    static func preloadData(context: NSManagedObjectContext) {
        let languages = [
            (
                name: "Chinese (Mandarin)",
                code: "zh-CN",
                codeTranslation: "zh-Hans",
                jsonFileName: "ChineseMandarin",
                hasJson: true,
                hasTransliteration: true,
                emoji: "🇨🇳",
                voices: [
                    VoiceData(code: "XiaoxiaoNeural", name: "Xiaoxiao", gender: "female", dialect: "Mandarin"),
                    VoiceData(code: "YunxiNeural", name: "Yunxi", gender: "male", dialect: "Mandarin"),
                    VoiceData(code: "henan-YundengNeural", name: "Yundeng", gender: "male", dialect: "Zhongyuan Mandarin Henan")
                ]
            ),
            (
                name: "Chinese (Cantonese)",
                code: "zh-HK",
                codeTranslation: "yue",
                jsonFileName: "ChineseCantonese",
                hasJson: true,
                hasTransliteration: false,
                emoji: "🇭🇰",
                voices: [
                    VoiceData(code: "HiuMaanNeural", name: "HiuMaan", gender: "female", dialect: ""),
                    VoiceData(code: "WanLungNeural", name: "WanLung", gender: "male", dialect: "")
                ]
            ),
            // Add more languages here in the future, e.g.:
        ]
        for language in languages {
            preloadLanguage(name: language.name, code: language.code, codeTranslation: language.codeTranslation, jsonFileName: language.jsonFileName, hasTransliteration: language.hasTransliteration, emoji: language.emoji, voices: language.voices,  hasJson: language.hasJson, context: context)
        }
        
    }
    
    private static func preloadLanguage(name: String, code: String, codeTranslation: String, jsonFileName: String, hasTransliteration: Bool, emoji: String, voices: [VoiceData], hasJson: Bool, context: NSManagedObjectContext) {
        // Check if language is already loaded
        let languageFetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        languageFetchRequest.predicate = NSPredicate(format: "code == %@", code)
        
        do {
            let count = try context.count(for: languageFetchRequest)
            if count > 0 {
                print("Language \(name) already loaded, skipping...")
                return
            }
        } catch {
            print("Error checking for existing language: \(error)")
        }
        
        // Create new language
        let language = Language(context: context)
        language.id = UUID()
        language.name = name
        language.code = code
        language.codeTranslation = codeTranslation
        language.jsonFileName = jsonFileName
        language.hasTransliteration = hasTransliteration
        language.hasJson = hasJson
        language.emoji = emoji

        // Add voices
        for voiceData in voices {
            let voice = Voice(context: context)
            voice.code = voiceData.code
            voice.name = voiceData.name
            voice.gender = voiceData.gender
            voice.dialect = voiceData.dialect
            voice.language = language
        }

        if(hasJson == true){
            // Load JSON file
            guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
                print("Failed to find JSON file for \(name) in bundle: \(jsonFileName)")
                return
            }
            
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Failed to load JSON file for \(name): \(error.localizedDescription)")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let phrasebook = try decoder.decode(PhrasebookData.self, from: data)
                
                for (categoryIndex, categoryData) in phrasebook.categories.enumerated() {
                    let category = Category(context: context)
                    category.id = UUID()
                    category.name = categoryData.name
                    category.symbol = categoryData.symbol
                    category.order = Int16(categoryIndex)
                    category.language = language
                    
                    for (phraseIndex, phraseData) in categoryData.phrases.enumerated() {
                        let phrase = Phrase(context: context)
                        phrase.id = UUID()
                        phrase.english = phraseData.english
                        phrase.translation = phraseData.translation
                        phrase.romanization = phraseData.transliteration
                        phrase.order = Int16(phraseIndex)
                        phrase.category = category
                        phrase.language = language
                    }
                }
                
                // Save the context
                try context.save()
                print("Successfully loaded data for \(name)")
                
            } catch {
                print("Failed to decode JSON or save context for \(name): \(error)")
            }
        } else {
            do {
                try context.save()
                print("Successfully loaded data for \(name)")
            } catch {
                print("Coudln't save json-less category \(name): \(error)")
            }
        }
        

    }
}
