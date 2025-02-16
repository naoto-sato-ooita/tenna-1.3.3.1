//
//  ResetFormView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/15.
//

import SwiftUI

struct ResetFormView: View {
    
    @EnvironmentObject var authviewModel: AuthManager
    @State private var email: String = ""
    
    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundView()
                
                //MARK: - form
                VStack(spacing: 24) {
                    InputView(text: $email ,
                              title: "Email Address" ,
                              placeholeder: "sample@email.com")
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    //MARK: - SendPass Buttun
                    Button{
                        Task {
                            try await authviewModel.sendPasswordReset(email: email)
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
                                Text("Send Email")
                                    .font(.custom(fontx, size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                
                                Image(systemName: "envelope")
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
    }
}


//MARK: - AuthenticationFormProtocol
extension ResetFormView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.count < 30
    }
}

#Preview {
    ResetFormView()
}
