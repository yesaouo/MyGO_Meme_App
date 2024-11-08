import SwiftUI

// Album Model
struct Album: Codable, Identifiable {
    let id: Int
    let name: String
    let cover: String
    let releaseDate: String
    let tracks: [String]
    let youtubeID: String
    let spotifyID: String
}

// 讀取專輯資料
func loadAlbums() -> [Album] {
    guard let url = Bundle.main.url(forResource: "album", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let albums = try? JSONDecoder().decode([Album].self, from: data) else {
        return []
    }
    return albums
}

struct AlbumView: View {
    let albums: [Album]
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(albums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        VStack {
                            Image(album.cover)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .cornerRadius(10)
                            
                            Text(album.name)
                                .font(.headline)
                                .lineLimit(1)
                            Text(album.releaseDate)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("專輯")
    }
}

struct AlbumDetailView: View {
    let album: Album
    
    var body: some View {
        BackgroundContainer {
            List {
                Section {
                    SpotifyPlayerView(spotifyID: album.spotifyID, type: "album")
                        .frame(height: 152)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .listRowInsets(EdgeInsets()) // 移除內建的 section 內邊距
                        .listRowBackground(Color.clear) // 確保背景透明
                }
                
                Section(header: Text("曲目列表")) {
                    ForEach(album.tracks, id: \.self) { track in
                        NavigationLink(track, destination: SongDetailView(title: track))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .navigationTitle(album.name)
        }
    }
}
