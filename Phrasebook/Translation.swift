//
//  Translation.swift
//  Phrasebook
//
//  Created by Christine Røde on 02/09/2024.
//

import Foundation

struct TranslationResponse: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let text: String
    let transliteration: Transliteration?
    let to: String
}

struct Transliteration: Codable {
    let text: String
    let script: String
}

func translateToChinese(englishPhrase: String, completion: @escaping (String?, String?) -> Void) {
    let apiKey = "efb201ece3c34951aa7047588f9f9348"
    let endpoint = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=zh-Hans&toScript=latn"

    guard let url = URL(string: endpoint) else {
        print("Invalid URL")
        completion(nil, nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("uksouth", forHTTPHeaderField: "Ocp-Apim-Subscription-Region")

    let body: [[String: String]] = [["Text": englishPhrase]]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Network error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil, nil)
            return
        }

        // Log the raw JSON response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }

        do {
            let translationResult = try JSONDecoder().decode([TranslationResponse].self, from: data)
            if let translation = translationResult.first?.translations.first {
                let translatedText = translation.text
                let transliteratedText = translation.transliteration?.text
                completion(translatedText, transliteratedText)
            } else {
                completion(nil, nil)
            }
        } catch {
            print("Failed to decode response: \(error.localizedDescription)")
            completion(nil, nil)
        }
    }
    task.resume()
}
