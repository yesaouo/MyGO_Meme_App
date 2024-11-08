import SwiftUI

struct MusicView: View {
    @State private var selectedView = "專輯"
    
    let albums = loadAlbums()
    let songs = loadMusic()
    
    var body: some View {
        NavigationStack {
            BackgroundContainer {
                VStack {
                    Picker("選擇檢視", selection: $selectedView) {
                        Text("專輯").tag("專輯")
                        Text("單曲").tag("單曲")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if selectedView == "專輯" {
                        AlbumView(albums: albums)
                    } else {
                        SongView(songs: songs)
                    }
                }
            }
        }
    }
}
