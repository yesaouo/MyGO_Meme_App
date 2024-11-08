import SwiftUI

struct BackgroundContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Image(colorScheme == .dark ? "bg_blue" : "bg_common")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()

            content
        }
    }
}