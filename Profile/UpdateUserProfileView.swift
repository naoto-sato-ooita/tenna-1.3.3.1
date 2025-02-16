//
//  UpdateUserProfileView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/11/27.
//

import SwiftUI
import Firebase

struct UpdateUserProfileView: View {
    @StateObject var viewModel = SettingViewModel.shared
    @State var profile: String = ""
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                BackgroundView()
                
                VStack(spacing:20){
                    
                    
                    Divider().background(.white)
                    
                    Spacer()
                        TextEditor(text: $profile)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .frame(width: UIScreen.main.bounds.width - 32,height: 100)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                            )
                        Button {
                            Task{
                                try await UserService.shared.updateUserProfile(uid:viewModel.user?.uid ?? "",profile: profile)
                                try await SettingViewModel.shared.loadCurrentUser()
                            }
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 200, height: 40)
                                Text("Update")
                                    .foregroundColor(.black)
                            }
                        }

                        .disabled(!editorValid3)
                    Spacer()

                }
                
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
                    Text("Feeling")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                    
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
        }
        
    }
    
}


extension UpdateUserProfileView {
    
    var editorValid3 : Bool {
        return !profile.isEmpty
        && profile.count < 60
        
    }
}
