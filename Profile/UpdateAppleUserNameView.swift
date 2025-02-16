//
//  UpdateUserNameView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/07/17.
//

import SwiftUI

struct UpdateUserNameView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel : AuthenticationViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var newName: String = ""
    @State private var errorMessage: String?
    @State private var isAppleSignIn: Bool = false
    @State private var isNavigationActive: Bool = false
    @State private var isChanged: Bool = false
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                BackgroundView()
                
                VStack{

                    Divider().background(.white)
                    Spacer()
                    
                    if authManager.isAppleSignInUser() {
                        
                        TextField("New Userame", text: $newName)
                            .textFieldStyle(.roundedBorder)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                            )

                        
                    } else {
                        
                        TextField("Email address", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .background(.white)
                            .keyboardType(.emailAddress)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                            )
                        
                        TextField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                            )
                        
                        
                        TextField("New Userame", text: $newName)
                            .textFieldStyle(.roundedBorder)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                            )
                        
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                if authManager.isAppleSignInUser() {
                                    try await viewModel.updateAppleUserName(newName: newName)
                                    isChanged = true
                                } else {
                                    try await viewModel.updateEmailUserName(email: email, password: password, newName: newName)
                                    isChanged = true
                                }
                                errorMessage = nil
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                            try await SettingViewModel.shared.loadCurrentUser()
                            dismiss()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 200, height: 40)
                            Text("Update")
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .disabled(!formisValid)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width - 32)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(backArrow)
                                .frame(width: 40,height: 40)
                        }
                    ).tint(.black)
                }
                ToolbarItem(placement: .principal) {
                    Text("Username")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                    
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
            
            .alert("Changed", isPresented: $isChanged) {
                Button { } label: { Text("Confirm") }
            }
            
        }

    }
    
    
}

extension UpdateUserNameView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !newName.isEmpty
        && newName.count < 21

    }
}
