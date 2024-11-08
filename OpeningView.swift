import SwiftUI

struct OpeningView: View {
    @Binding var isActive: Bool
    @State private var showTxtKv = false
    @State private var rotationAngle: Double = 0
    @State private var txtKvProgress: CGFloat = 0
    @State private var fadeOutOpacity: Double = 1
    @State private var colorOpacity: [Double] = [1, 1, 1, 1, 1]
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    Color(red: 0.2, green: 0.53, blue: 0.73)
                        .opacity(colorOpacity[index])
                }
            }

            VStack(spacing: 25) {
                Image("icon_mark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .rotationEffect(.degrees(rotationAngle))
                
                if showTxtKv {
                    Image("txt_kv")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * txtKvProgress)
                            }
                        )
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTxtKv)
            .opacity(fadeOutOpacity)
        }
        .ignoresSafeArea()
        .onAppear {
            animationSequence()
        }
    }
    
    func animationSequence() {
        // Step 1: 轉動圖標
        withAnimation(.easeInOut(duration: 1)) {
            rotationAngle = -90
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 1)) {
                rotationAngle = 180
            }
        }
        
        // Step 2: 顯示文字
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showTxtKv = true
            withAnimation(.linear(duration: 1)) {
                txtKvProgress = 1
            }
        }
        
        // Step 3: 離場動畫
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 1)) {
                for i in 0..<colorOpacity.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                        withAnimation {
                            colorOpacity[i] = 0
                        }
                    }
                }
                fadeOutOpacity = 0
            }
        }

        // Step 4: 動畫完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            isActive = false
        }
    }
}
