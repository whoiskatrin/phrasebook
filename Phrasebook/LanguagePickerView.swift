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
    
    @State private var selectedLanguage: Language?
    @State private var currentIndex: Int = 0
    @State private var randomRotations: [Double] = []

    @Namespace private var animation

    var body: some View {
        VStack {
            Spacer()
            
            GeometryReader { geometry in
                let itemWidth = geometry.size.width * 0.01 // 70% of the screen width
                let sideItemWidth = geometry.size.width * 0.6 // 15% on each side
                                
                ZStack {
                    ForEach(Array(languages.enumerated()), id: \.element) { index, language in
                        Image(language.code ?? "default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .scaleEffect(currentIndex == index ? 1.1 : 0.9)
                            .opacity(currentIndex == index ? 1 : 0.7)
                            .rotation3DEffect(
                                .degrees(currentIndex == index ? 0 : index.isMultiple(of: 2) ? 3 : -3),
                                axis: (x: 0, y: 0, z: 1)
                            )
                            .offset(x: CGFloat(index - currentIndex) * (itemWidth + sideItemWidth))
                            .zIndex(currentIndex == index ? 1 : 0)
                            .matchedGeometryEffect(id: language.id, in: animation)
                            .shadow(color: .black.opacity(0.1), radius: 19, x: 10, y: 14)
                            .shadow(color: .black.opacity(0.09), radius: 35, x: 41, y: 56)
                            .shadow(color: .black.opacity(0.05), radius: 47, x: 92, y: 126)
                            .shadow(color: .black.opacity(0.01), radius: 55.5, x: 164, y: 224)
                            .shadow(color: .black.opacity(0), radius: 61, x: 257, y: 351)

                    }
                    
                    Group {
                        Image("default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                    }
                    .frame(width: 300)
                    .scaleEffect(currentIndex == languages.count ? 1 : 0.9)
                    .opacity(currentIndex == languages.count ? 1 : 0.5)
                    .offset(x: CGFloat(languages.count - currentIndex) * (itemWidth + sideItemWidth))
                    .zIndex(currentIndex == languages.count ? 1 : 0)
                    .matchedGeometryEffect(id: "addLanguage", in: animation)

                }
                .frame(width: geometry.size.width, height: 350)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold = itemWidth * 0.2
                            if value.translation.width > threshold && currentIndex > 0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.2)) {
                                    currentIndex -= 1
                                }
                            } else if value.translation.width < -threshold && currentIndex < languages.count {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.2)) {
                                    currentIndex += 1
                                }
                            }
                        }
                )
            }
            .frame(height: 360) // Adjust this value as needed
                        
            VStack {
                Text(selectedLanguage?.name ?? "Add Language")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let selectedLanguage = selectedLanguage {
                    Text("\(phrases.filter { $0.language == selectedLanguage }.count) phrases")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Hehe")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0))
                }
            }
            .padding(.vertical)
                        
            Spacer()
            
            PageIndicator(numberOfPages: languages.count + 1, currentPage: currentIndex)
                .padding(.bottom)
            
            Button(action: {
                if let selectedLanguage = selectedLanguage {
                    languageManager.switchLanguage(to: selectedLanguage)
                    presentationMode.wrappedValue.dismiss()
                } else if (selectedLanguage == nil) {
                    print("Go to add language")
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text(buttonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Select Language")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
        .onChange(of: currentIndex) { newIndex in
            if newIndex < languages.count {
                selectedLanguage = languages[newIndex]
            } else {
                selectedLanguage = nil
            }
        }
        .onAppear {
            if let currentLanguage = languageManager.currentLanguage,
               let index = languages.firstIndex(of: currentLanguage) {
                currentIndex = index
                selectedLanguage = currentLanguage
            }
            randomRotations = (0..<languages.count).map { _ in Double.random(in: -2...2) }

        }

    }
    
    private var buttonText: String {
        if selectedLanguage == languageManager.currentLanguage {
            return "Done"
        } else if selectedLanguage == nil {
           return "Add Language"
        } else {
            return "Switch to \(selectedLanguage?.nameShort ?? "Unknown")"
        }
    }
}


struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.blue : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
