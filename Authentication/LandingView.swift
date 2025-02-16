//
//  LandingView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//

import SwiftUI
import AuthenticationServices

struct LandingView: View {
    
    @EnvironmentObject var authviewModel: AuthManager
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @State private var isShowSignIn: Bool = false
    @State private var isShowSignUp: Bool = false
    @State private var isShowReset: Bool = false
    @State var isActive: Bool = false
    
    @State var letterColors: [Color] = Array(repeating: .white, count: "Tenna2".count)
    var color : Color = .white
    let text = "Tenna2"
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("real2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                    .opacity(0.8)
                    .ignoresSafeArea()
                
                VStack{
                    HStack(spacing: 0){
                        ForEach(0..<text.count,id: \.self){ index in
                            Text(String(text[text.index(text.startIndex, offsetBy: index)]))
                                .foregroundColor(letterColors[index])
                                .shadow(color: letterColors[index] == color ? color : .clear ,radius: 2)
                                .shadow(color: letterColors[index] == color ? color : .clear ,radius: 50)
                            
                            
                        }
                        
                            .font(.custom(fontx, size: 100))
                            .fontWeight(.heavy)
                            .shadow(radius: 5)
                            .padding(.top,UIScreen.main.bounds.height / 5.5)
                        
                            .onAppear{
                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                                    changeColors()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                        timer.invalidate()
                                        letterColors = Array(repeating: color, count: text.count)
                                    }
                                }
                            }
                        
                    }
                    //MARK: - Apple

                    Button{
                        Task {
                            try await viewModel.signInApple()
                        }
                    } label: {

                        SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    }

                    .frame(width: UIScreen.main.bounds.width - 80, height: 60)
                    .padding(.top,UIScreen.main.bounds.height / 30)
                    //MARK: - Sign in with Email
                    
                    Button{
                        isShowSignIn = true
                        
                    } label: {
                        
                        HStack{
                            Image(systemName: "scribble.variable")
                                
                            Text("Sign in with Email")

                        }
                        
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 160, height: 40)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.top , 24)

                    
                    //MARK: - Reset PassWord
                    
                    Button{
                        isShowReset = true
                        
                    } label: {
                        
                        HStack{
                            Image(systemName: "signpost.right.and.left")
                            Text("Forgot Password")

                        }
                        
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 160, height: 40)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.top , 24)
                    
                    
                    //MARK: - Sign up
                    Button{
                        isShowSignUp = true
                        
                    } label: {
                        
                        HStack{
                            Image(systemName: "book")
                            Text("Sign up")

                        }
                        
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 160, height: 40)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.top , 24)
                }
            }
        }
        
        
        .sheet(isPresented: $isShowSignIn){
            SignInFormView()
            
                .presentationDetents([
                    .height(280),
                ])
        }
        .sheet(isPresented: $isShowSignUp){
            SignUpFormView()
                .presentationDetents([
                    .height(500),
                ])
        }
        .sheet(isPresented: $isShowReset){
            ResetFormView()
                .presentationDetents([
                    .height(200),
                ])
        }
        
    }
    func changeColors(){
        for index in letterColors.indices {
            letterColors[index] = Bool.random() ? .gray.opacity(0.3) : color
        }
    }
}

#Preview {
    LandingView()
}
