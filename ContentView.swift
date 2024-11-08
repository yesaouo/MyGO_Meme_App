import SwiftUI

struct ContentView: View {
    @State private var isOpeningViewActive = true
    
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                .tabItem {
                    Label("首頁", systemImage: "house")
                }

                MusicView()
                .tabItem {
                    Label("音樂", systemImage: "music.note")
                }

                ImageView()
                .tabItem {
                    Label("相簿", systemImage: "photo")
                }
            }
            if isOpeningViewActive {
                OpeningView(isActive: $isOpeningViewActive)
            }
        }
    }
}