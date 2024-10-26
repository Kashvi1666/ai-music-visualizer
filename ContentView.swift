import SwiftUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showSongOptions = false
    @State private var isProcessing = false
    @State private var selectedAudioURL: URL?
    @State private var selectedSongTitle: String?
    
    let spaceSongURL = Bundle.main.url(forResource: "spacesong", withExtension: "mp3")
    let starshipsURL = Bundle.main.url(forResource: "kerosene", withExtension: "mp3")
    
    var body: some View {
        VStack {
 
                Text("MUSE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xLarge/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 50)
                
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 800, height: 600)
                        .cornerRadius(20)
                    
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 400)
                                .padding()
                        } else {
                            Spacer()
                        }
                        if showSongOptions {
                            HStack(spacing: 40) {
                                Button(action: {
                                    selectedAudioURL = spaceSongURL
                                    selectedSongTitle = "Space Song"
                                    showSongOptions = false
                                    print("space song selected")
                                }) {
                                    Text("space song")
                                        .frame(width: 160)
                                }
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                .frame(width: 160)
                                
                                Button(action: {
                                    selectedAudioURL = starshipsURL
                                    selectedSongTitle = "kerosene"
                                    showSongOptions = false
                                    print("kerosene selected")
                                }) {
                                    Text("kerosene")
                                        .frame(width: 160)
                                }
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                .frame(width: 160)
                            }
                            .padding()
                        } else {
                            if selectedAudioURL != nil && !isProcessing {
                                Button(action: processSong) {
                                    Text("create")
                                }
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                
                                Button(action: {
                                    showSongOptions = true
                                    
                                }) {
                                    Text("songs")
                                }
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                Spacer()
                                Spacer()
                            } else if isProcessing {
                                Text("generating....")
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(8)
                            } else {
                                Button(action: {
                                    showSongOptions = true
                                    image = nil
                                }) {
                                    Text("songs")
                                }
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                Spacer()
                                Spacer()
                            }
                        }
                    }
                    .frame(width: 300, height: 200) // Ensure the VStack frame matches the rectangle
                }
                Spacer()
            }
            Spacer() // Add space to center the ZStack vertically when there is no image
        
    }
    
    func processSong() {
        guard let audioURL = selectedAudioURL else { return }
        isProcessing = true
        
        print("Processing song: \(audioURL.absoluteString)")
        
        let analyzer = AudioAnalyzer()
        if let features = analyzer.extractFeatures(from: audioURL) {
            let description = generateDescription(from: features, songTitle: selectedSongTitle ?? "the song")
            print("Description generated: \(description)")
            DalleAPI.generateImage(from: description) { imageURL in
                guard let imageURL = imageURL else {
                    print("Failed to get image URL")
                    self.isProcessing = false
                    return
                }
                
                print("Image URL: \(imageURL)")
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        print("Image fetched successfully")
                        self.image = image
                        self.isProcessing = false
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Failed to load image data")
                        self.isProcessing = false
                    }
                }
            }
        } else {
            print("Failed to extract audio features")
            isProcessing = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
