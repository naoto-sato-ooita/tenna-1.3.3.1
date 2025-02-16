import Foundation
import SwiftUI

struct SplashScreenView: View {
    
    @Binding var showSplashScreen: Bool
    
    @State var scale1: CGFloat = 0
    @State var scale2: CGFloat = 0
    @State var scale3: CGFloat = 0
    @State var color: Color = new_yellow
    @State var backgroundOpacity: Double = 1.0
    
    var foreverAnimation = Animation.linear.speed(0.2).repeatForever(autoreverses: false)
    
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(backgroundOpacity)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    
                    Text("Let's go find it.")
                        .font(.custom(fontx, size: 18))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                }
                .padding(.bottom,80)
                .padding(.trailing,100)
                
                ZStack{
                    Image(systemName: "circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(color)
                        .opacity(1 - scale1)
                        .scaleEffect(1 + (scale1 * 2))
                        .onAppear {
                            withAnimation(foreverAnimation) {
                                scale1 = 1
                            }
                        }
                    Image(systemName: "circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(color)
                        .opacity(1 - scale2)
                        .scaleEffect(1 + (scale2 * 2))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(foreverAnimation) {
                                    scale2 = 1
                                }
                            }
                        }
                    Image(systemName: "circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(color)
                        .opacity(1 - scale3)
                        .scaleEffect(1 + (scale3 * 2))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(foreverAnimation) {
                                    scale3 = 1
                                }
                            }
                        }
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80, alignment: .center)
                        .cornerRadius(40)
                }
                Spacer()
            }
            
        }
        .onAppear {
            
            withAnimation(.easeInOut(duration: 2.0)) { // 3秒間かけてフェードアウト
                backgroundOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 2秒表示
                withAnimation {
                    showSplashScreen = false
                }
            }
        }
    }
}
