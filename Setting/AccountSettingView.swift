//
//  AccountSettingView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/14.
//

import SwiftUI

struct AccountSettingView: View {
    @Environment (\.dismiss) var dismiss
    
    @StateObject private var viewModel = SettingViewModel()
    @State private var isSignout: Bool = false
    @State private var isDelete2: Bool = false

    
    var body: some View {
        
        ZStack(alignment: .bottomLeading){
            
            BackgroundView()
            
            VStack {
                

                Divider().background(.white)
                
                List{
                    //MARK: -

                   
                    
                    Button{
                        isSignout = true
                    } label: {
                        HStack{
                            IconStyleView(imageName: "arrow.left.circle.fill",
                                          title: "",
                                          tintColor: Color(.systemOrange))
                            Text("Sign out")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .tint(.primary)
                        }
                    }
                    
                    .alert("Continue?", isPresented: $isSignout) {
                        Button(role: .destructive) {
                            Task {
                                try AuthManager.shared.signOut()
                            }
                        } label: {
                            Text("See you")
                        }
                    }
                    
                    //MARK: -
                    Button{
                        isDelete2 = true
                        
                    } label: {
                        HStack{
                            IconStyleView(imageName: "xmark.circle.fill",
                                          title: "",
                                          tintColor: Color(.systemRed))
                            Text("Delete Account")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .tint(.primary)
                        }
                    }
                    .alert("Continue?", isPresented: $isDelete2) {
                        Button(role: .destructive) {
                            Task { try await AuthManager.shared.deleteAccount() }
                        } label: {
                            Text("See you")
                        }
                    }
                    
                }
            }
            .scrollContentBackground(.hidden)
        }
        .toolbarTitleDisplayMode(.inline)  // Add this line
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
                )
            }
            ToolbarItem(placement: .principal) {
                Text("Exit")
                    .font(.custom(fontx, size: 22))
                    .foregroundStyle(fontColor)
                    .fontWeight(.thin)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(White2,for: .navigationBar)
    }
}

#Preview {
    AccountSettingView()
}
