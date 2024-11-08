import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let images = ["img_kv-0", "img_kv-1", "body_tomori", "body_anon", "body_rana", "body_soyo", "body_taki"]
    
    @State private var currentTab = 0 // 當前 Tab 頁索引
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 設定每 5 秒輪播

    var body: some View {
        GeometryReader { geometry in
            BackgroundContainer {
                if colorScheme == .dark {
                    Image("icon_window")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geometry.size.width)
                        .ignoresSafeArea()
                }
                
                if horizontalSizeClass != .regular {
                    // 直立式佈局 - VStack
                    VStack {
                        Spacer()

                        TabView(selection: $currentTab) {
                            ForEach(images.indices, id: \.self) { index in
                                let imageName = images[index]
                                if imageName.contains("img_kv") {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .padding(.vertical, 50)
                                        .tag(index)
                                } else {
                                    VStack {
                                        Spacer()
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geometry.size.height * 0.75)
                                            .tag(index)
                                    }
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .onReceive(timer) { _ in
                            // 每次計時器觸發時更新頁碼
                            withAnimation {
                                currentTab = (currentTab + 1) % images.count
                            }
                        }
                    }
                    .overlay(alignment: .top) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.25)
                            .padding(.top)
                    }
                } else {
                    // 橫式佈局 - HStack
                    HStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .padding(50)
                        
                        TabView(selection: $currentTab) {
                            ForEach(images.indices, id: \.self) { index in
                                let imageName = images[index]
                                if imageName.contains("img_kv") {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .tag(index)
                                } else {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: geometry.size.height * 0.9)
                                        .tag(index)
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(width: (geometry.size.width / 3) * 2)
                        .padding(.trailing, 50)
                        .onReceive(timer) { _ in
                            // 每次計時器觸發時更新頁碼
                            withAnimation {
                                currentTab = (currentTab + 1) % images.count
                            }
                        }
                    }
                }
            }
        }
    }
}
