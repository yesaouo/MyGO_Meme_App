import SwiftUI
import WebKit

// Music Model
struct Music: Codable, Identifiable {
    var id: String { title }
    let title: String
    let enTitle: String
    let releaseDate: String
    let youtubeID: String
    let spotifyID: String
}

// 讀取歌曲資料
func loadMusic() -> [Music] {
    guard let url = Bundle.main.url(forResource: "music", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let music = try? JSONDecoder().decode([Music].self, from: data) else {
        return []
    }
    return music
}

struct SongView: View {
    let songs: [Music]
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(songs) { song in
                    NavigationLink(destination: SongDetailView(title: song.title)) {
                        VStack {
                            Image(song.enTitle.replacingOccurrences(of: " ", with: ""))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                            
                            Text(song.title)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        .padding()
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("所有歌曲")
    }
}

// Song Detail View
struct SongDetailView: View {
    let title: String
    @State private var song: Music?
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        BackgroundContainer {
            VStack {
                if let song = song {
                    Spacer()

                    // 顯示圖片
                    Image(song.enTitle.replacingOccurrences(of: " ", with: ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    // 顯示歌曲標題
                    Text(song.title)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    // 顯示英文標題
                    Text(song.enTitle)
                        .font(.title2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // 顯示發行時間
                    Text("發行時間: \(song.releaseDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    // 顯示 Spotify 播放器
                    SpotifyPlayerView(spotifyID: song.spotifyID)
                        .frame(height: 80)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    Text("正在載入歌曲資訊...")
                        .font(.headline)
                        .padding(.top, 50)
                }
            }
            .padding(.horizontal)
            .onAppear {
                loadSong()
            }
        }
    }
    
    // 根據 title 載入對應的歌曲
    private func loadSong() {
        let allSongs = loadMusic()
        self.song = allSongs.first { $0.title == title }
    }
}

// Spotify 播放器
struct SpotifyPlayerView: UIViewRepresentable {
    let spotifyID: String
    var type: String = "track"
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: "https://open.spotify.com/embed/\(type)/\(spotifyID)?utm_source=generator") {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
