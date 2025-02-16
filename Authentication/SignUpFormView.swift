//
//  SignUpFormView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//

import SwiftUI

struct SignUpFormView: View {
    
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @EnvironmentObject var authviewModel: AuthManager
    
    var body: some View {
        
        ZStack {
            BackgroundView()
            
            VStack {
                
                //MARK: - form
                VStack(spacing: 24){
                    InputView(text: $email,
                              title: "Email Address",
                              placeholeder: "sample@email.com")
                    .keyboardType(.emailAddress)

                    
                    InputView(text: $fullname,
                              title: "Username",
                              placeholeder: "A-Z,a-z,0-9")
                    .onChange(of: fullname, perform: filter)
                    
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholeder: "min8,max20",
                              isSecureField: true)
                    
                    
                    ZStack(alignment: .trailing){
                        InputView(text: $confirmPassword,
                                  title: "Confirm",
                                  placeholeder: "min8,max20", isSecureField: true)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(sw_normal)
                            }
                            else{
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(sw_neg)
                            }
                        }
                    }
                    
                }
                
                .padding(.horizontal)
                
                
                //MARK: - SignUpButton
                
                Button {
                    Task {
                        try await authviewModel.createUser(email: email, password: password, fullname: fullname)
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
                            Text("Sign up")
                                .font(.custom(fontx, size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Image(systemName: "book")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(fontColor)
                                .frame(width: 30,height: 30)
                        }
                    }

                }
                .disabled(!formisValid)
                
            }
        }
    }
    func filter(value: String) {
        let validCodes = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let sets = CharacterSet(charactersIn: validCodes)
        fullname = String(value.unicodeScalars.filter(sets.contains).map(Character.init))
    }
}
//MARK: - AuthenticationFormProtocol
extension SignUpFormView: AuthenticationFormProtocol {
    
    var formisValid: Bool {
        
        return !email.isEmpty
        && email.contains("@")
        && email.count < 30
        && !password.isEmpty
        && password.count > 7
        && password.count < 21
        && !confirmPassword.isEmpty
        && confirmPassword.count > 7
        && confirmPassword.count < 21
        && password == confirmPassword
        && !fullname.isEmpty
        && fullname.count < 21
    }
}

#Preview {
    SignUpFormView()
}
