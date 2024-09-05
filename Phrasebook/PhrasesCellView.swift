//
//  PhrasesCellView.swift
//  Phrasebook
//
//  Created by Christine Røde on 31/08/2024.
//
import SwiftUI
import AVFoundation

struct PhraseCellView: View {
    let phrase: Phrase
    @State private var isSheetPresented = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isLoadingAudio = false
    @State private var iconState: String = "play.circle.fill"
    
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(phrase.english ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(phrase.translation ?? "")
                    .font(.title)
                    .fontWeight(.semibold)
                if(phrase.romanization != ""){
                    Text(phrase.romanization ?? "")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .onTapGesture {
                isSheetPresented = true
            }
            
            
            HStack {
//            Button(action: { isSheetPresented = true }) {
//                Image(systemName: "plus.magnifyingglass")
//                        .frame(width: 30, height: 30)
//                        .font(.title)
//                        .foregroundColor(.secondary)
//                        .contentTransition(
//                            .symbolEffect(.replace.downUp.byLayer)
//                        )
//            }
                        
            Button(action: fetchAndPlayAudio) {
                Image(systemName: iconState)
                       // .resizable()
                        .frame(width: 30, height: 30)
                        .font(.title)
                        .foregroundColor(.blue)
                        .contentTransition(
                            .symbolEffect(.replace.downUp.byLayer)
                        )
               // }
            }
            .contentShape(Circle())
            }
            .onAppear {
                audioPlayerManager.onPlaybackFinished = {
                    DispatchQueue.main.async {
                        self.iconState = "play.circle.fill"
                    }
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            SheetView(phrase: phrase)
                .presentationDetents([.medium, .large])
        }
    }

    private func fetchAndPlayAudio() {
        isLoadingAudio = true
        iconState = "ellipsis"
        
        if audioPlayerManager.isPlaying {
            audioPlayerManager.stopAudio()
            iconState = "play.circle.fill"
            return
        }
        
        if let cachedAudioData = phrase.cachedAudio {
            audioPlayerManager.playAudio(data: cachedAudioData)
            iconState = "stop.circle"
            return
        }

        let subscriptionKey = "565ce84aa58d4a6788e714020e8fcb53"
        let region = "uksouth" // e.g., "eastus"
        let endpoint = "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1"

        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            isLoadingAudio = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
        request.setValue("audio-16khz-32kbitrate-mono-mp3", forHTTPHeaderField: "X-Microsoft-OutputFormat")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = createSSML(for: phrase.translation ?? "")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingAudio = false
                
                if let error = error {
                    print("Failed to fetch audio: \(error)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                }

                if let data = data {
                    self.saveAudioToCache(data: data)
                    self.audioPlayerManager.playAudio(data: data)
                    iconState = "pause.circle"
                } else {
                    print("No data received.")
                }
            }
        }
        task.resume()
    }
    

    private func createSSML(for text: String) -> Data? {
        guard let currentLanguage = languageManager.currentLanguage,
              let languageCode = currentLanguage.code,
              let firstVoice = currentLanguage.voices?.allObjects.first as? Voice,
              let voiceName = firstVoice.code else {
            print("Error: Missing language information or no voices available")
            return nil
        }
        
        print("Playing audio for \(languageCode)-\(voiceName)")
        
        let ssml = """
        <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/10/synthesis https://www.w3.org/TR/speech-synthesis11/synthesis.xsd" xml:lang="\(languageCode)">
            <voice name="\(languageCode)-\(voiceName)">
                \(text)
            </voice>
        </speak>
        """
        return ssml.data(using: .utf8)
    }
    private func saveAudioToCache(data: Data) {
        viewContext.perform {
            self.phrase.cachedAudio = data
            do {
                try viewContext.save()
            } catch {
                print("Failed to save audio data: \(error)")
            }
        }
    }

}

struct SheetView: View {
    let phrase: Phrase
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                
                Text(phrase.translation ?? "")
                    .font(.system(size: 80, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                
            }
        .navigationTitle(phrase.english ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }

            }
        }
        }
    }
}

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    var onPlaybackFinished: (() -> Void)?

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true

            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.onPlaybackFinished?()
        }
    }

}


struct CloseButton: View {
    
var body: some View {
        Image(systemName: "xmark")
            .fontWeight(.bold)
            .frame(width: 16, height: 16)
            .foregroundColor(.blue)
            .padding(.horizontal, 2)

}
}
