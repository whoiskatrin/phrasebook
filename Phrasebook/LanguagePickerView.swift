//
//  LanguagePickerView.swift
//  Phrasebook
//
//  Created by Christine Røde on 04/09/2024.
//

import Foundation
import CoreData
import SwiftUI


struct LanguagePickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.name, ascending: true)],
        animation: .default)
    private var languages: FetchedResults<Language>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Phrase.id, ascending: true)],
        animation: .default)
    private var phrases: FetchedResults<Phrase>
    
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationView {
            List {
                if let selectedLanguage = languageManager.currentLanguage {
                    HStack(alignment: .top) {
                        Text(selectedLanguage.emoji ?? "🏳️")
                            .padding(.horizontal, 2)
                        VStack(alignment: .leading) {
                            Text(selectedLanguage.name ?? "Unknown")
                                .font(.headline)
                            Text("\(phrases.filter { $0.language == selectedLanguage }.count) phrases")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cornerRadius(10)
                        .overlay(
                            Button(action: {
                                // Add settings action here
                            }) {
                                Image(systemName: "gearshape.fill")
                            }
                            ,
                            alignment: .trailing
                        )
                    }
                    .padding(.vertical, 10)
                }
                
                Section() {
                    ForEach(languages, id: \.self) { language in
                        if language.id != languageManager.currentLanguage?.id {
                            Button(action: {
                                languageManager.switchLanguage(to: language)
                                print("Debug: Language changed to \(language.name ?? "Unknown")")
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(language.emoji ?? "🏳️")
                                    Text(language.name ?? "Unknown")
                                }
                            }
                        }
                    }
                } header: {
                    Text("Select a language")
                } footer: {
                    Text("More languages coming soon")
                }
                .headerProminence(.increased)
                .padding(0)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Languages")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
