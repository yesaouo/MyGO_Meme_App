import SwiftUI
import AVFoundation
import AVKit

struct ImageItem: Identifiable, Codable, Equatable {
    var id: String { 編號 }
    let 編號: String
    let 圖片名稱: String
    let 圖片連結: String
}

class ImageViewModel: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var favorites: [ImageItem] = []
    @Published var searchText: String = "" {
        didSet {
            handleSearchInput()
        }
    }

    private let mediaPlayer = MediaPlayerManager()
    private var lastSearchText: String = ""
    
    func handleSearchInput() {
        if searchText != lastSearchText {
            lastSearchText = searchText
            if searchText == "春" {
                if mediaPlayer.audioPlayer == nil || mediaPlayer.audioPlayer?.isPlaying == false {
                    mediaPlayer.playAudio(named: "Haruhikage")
                }
            } else if searchText == "春日影" {
                mediaPlayer.stopAudio()
                mediaPlayer.playVideo(named: "為什麼要演奏春日影！")
            }
        }
    }

    var filteredImages: [ImageItem] {
        if searchText.isEmpty {
            return images
        } else {
            return images.filter { $0.圖片名稱.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var filteredFavorites: [ImageItem] {
        if searchText.isEmpty {
            return favorites
        } else {
            return favorites.filter { $0.圖片名稱.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init() {
        loadImages()
        loadFavorites()
    }
    
    func loadImages() {
        guard let url = Bundle.main.url(forResource: "pic_database", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error loading JSON file")
            return
        }
        
        do {
            images = try JSONDecoder().decode([ImageItem].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favorites") {
            do {
                favorites = try JSONDecoder().decode([ImageItem].self, from: data)
            } catch {
                print("Error loading favorites: \(error)")
            }
        }
    }
    
    func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: "favorites")
        } catch {
            print("Error saving favorites: \(error)")
        }
    }

    func isFavoriteView(_ item: ImageItem) -> Bool {
        return favorites.contains(item)
    }

    func toggleFavorite(_ item: ImageItem) {
        if isFavoriteView(item) {
            favorites.removeAll { $0.id == item.id }
            saveFavorites()
        } else {
            favorites.append(item)
            saveFavorites()
        }
    }
}

struct ImageView: View {
    @StateObject private var viewModel = ImageViewModel()
    @State private var showFavorites = false
    
    var displayedImages: [ImageItem] {
        showFavorites ? viewModel.filteredFavorites : viewModel.filteredImages
    }
    
    var body: some View {
        NavigationStack {
            BackgroundContainer {
                VStack {
                    HStack {
                        SearchBar(text: $viewModel.searchText)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showFavorites.toggle()
                            }
                        }) {
                            Image(systemName: showFavorites ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(showFavorites ? .red : .gray)
                                .scaleEffect(showFavorites ? 1.1 : 1.0)
                                .animation(.spring(), value: showFavorites)
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 20) {
                            ForEach(displayedImages) { item in
                                ImageCard(viewModel: viewModel, item: item)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .animation(.spring(), value: displayedImages)
                    }
                }
                .navigationTitle(showFavorites ? "我的最愛" : "迷因圖庫")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("搜索圖片...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}

struct ImageCard: View {
    @ObservedObject var viewModel: ImageViewModel
    let item: ImageItem
    @State private var isShowingFullScreen = false
    @State private var isShowingActionSheet = false
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.圖片連結)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            isShowingFullScreen = true
                        }
                        .onLongPressGesture {
                            isShowingActionSheet = true
                        }
                case .failure:
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.gray)
                @unknown default:
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 150)
            .cornerRadius(10)
            
            Text(item.圖片名稱.dropFirst(6))
                .font(.caption)
                .lineLimit(1)
        }
        .fullScreenCover(isPresented: $isShowingFullScreen) {
            FullScreenImageView(imageURL: item.圖片連結)
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("圖片操作"), buttons: [
                .default(Text(viewModel.isFavoriteView(item) ? "移除最愛" : "加到最愛")) {
                    viewModel.toggleFavorite(item)
                },
                .default(Text("下載圖片")) {
                    downloadImage(from: item.圖片連結)
                },
                .cancel()
            ])
        }
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            }
        }.resume()
    }
}

struct FullScreenImageView: View {
    let imageURL: String
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / self.lastScale
                                    self.lastScale = value
                                    let newScale = self.scale * delta
                                    self.scale = min(max(newScale, 1), 4)
                                }
                                .onEnded { _ in
                                    self.lastScale = 1.0
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.offset = CGSize(
                                        width: self.lastOffset.width + value.translation.width,
                                        height: self.lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    self.lastOffset = self.offset
                                }
                        )
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    if self.scale > 1 {
                                        self.scale = 1
                                        self.offset = .zero
                                        self.lastOffset = .zero
                                    } else {
                                        self.scale = 2
                                    }
                                }
                        )
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    presentationMode.wrappedValue.dismiss()
                }
        )
    }
}

class MediaPlayerManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    private var videoPlayer: AVPlayer?
    private var playerViewController: AVPlayerViewController?

    func playAudio(named audioName: String) {
        if let audioURL = Bundle.main.url(forResource: audioName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
            } catch {
                print("無法播放音樂: \(error)")
            }
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func playVideo(named videoName: String) {
        if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            videoPlayer = AVPlayer(url: videoURL)
            playerViewController = AVPlayerViewController()
            playerViewController?.player = videoPlayer

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: videoPlayer?.currentItem
            )

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController,
               let playerViewController = playerViewController {
                rootViewController.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                } 
            }
        }
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: true) {
                    self.playerViewController = nil
                    self.videoPlayer = nil
                }
            }
        }

        if let playerItem = videoPlayer?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
}