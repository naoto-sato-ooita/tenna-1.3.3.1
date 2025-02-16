//
//  SignInFormView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/27.
//

import SwiftUI

struct SignInFormView: View {
    
    @EnvironmentObject var authviewModel: AuthManager
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundView()
                
                VStack{
                    
                    VStack(spacing: 12){
                        InputView(text: $email,
                                  title: "Email Address",
                                  placeholeder: "sample@email.com")
                        .keyboardType(.emailAddress)
                        
                        InputView(text: $password,
                                  title: "Password",
                                  placeholeder: "between 8 and 20 characters", isSecureField: true)
                        
                        
                    }
                    
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    
                    //MARK: - Sign in Button
                    
                    Button{
                        Task{
                            try await authviewModel.signIn(email: email, password: password)
                        }
                        
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.white)
                                        .opacity(1)
                                )
                                .frame(width: 200, height: 50)
                            
                            HStack{
                                Text("Sign in")
                                    .font(.custom(fontx, size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "pencil.and.scribble")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(fontColor)
                                    .frame(width: 30,height: 30)
                            }
                        }
                        
                    }
                    .disabled(!formisValid)
                    .padding(.top , 24)
                    
                }
            }
        }
    }
}
//MARK: - AuthenticationFormProtocol
extension SignInFormView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.count < 30
        && !password.isEmpty
        && password.count > 7
        && password.count < 21
    }
}



#Preview {
    SignInFormView()
}
