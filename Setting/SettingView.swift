//
//  Setting View.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import SafariServices
import UIKit
import SwiftUI


struct SettingView: View {
    @Environment (\.dismiss) var dismiss
    @StateObject private var viewModel = SettingViewModel.shared
    
    
    @State private var isBellSet : Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                
                BackgroundView()
                
                
                VStack {
                    
                    Divider().background(.white)
                    Spacer()
                    LazyVGrid(columns: columns, spacing: 10) {
                        
                        
                        // About Us Panel
                        NavigationLink {
                            ProfileView()
                        } label: {
                            SettingPanel(
                                icon: "person",
                                title: "Profile",
                                color: Color(.black)
                            )
                        }
                        
                        NavigationLink {
                            PurchaseView()
                        } label: {
                            SettingPanel(
                                icon: "cart",
                                title: "Store",
                                color: Color(.black)
                            )
                        }
                        
                        // Notification Panel
                        SettingPanel(
                            icon: "bell",
                            title: "Notification",
                            color: Color(.black)
                        ) {
                            isBellSet = true
                        }
                        
                        
                        // About Us Panel
                        NavigationLink {
                            DocumentListView()
                        } label: {
                            SettingPanel(
                                icon: "questionmark.app",
                                title: "About us",
                                color: Color(.black)
                            )
                        }
                        
                        // Inquiry Panel
                        NavigationLink {
                            InqueryFormView()
                        } label: {
                            SettingPanel(
                                icon: "envelope",
                                title: "Contact",
                                color: Color(.black)
                            )
                        }
                        
                        // Account Panel
                        NavigationLink {
                            AccountSettingView()
                        } label: {
                            SettingPanel(
                                icon: "door.right.hand.open",
                                title: "Exit",
                                color: Color(.black)
                            )
                        }
                        
                        .padding()
                        
                    }
                    Spacer()
                    Button{
                        dismiss()
                        
                    } label: {
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20,height: 20)
                            .foregroundStyle(.gray)
                            .imageScale(.large)
                    }
                }
            }
            .alert(isPresented: $isBellSet) {
                Alert(
                    title: Text("Move to iOS setting"),
                    message: Text(""),
                    primaryButton: .destructive(Text("Yes")) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        
                    }
                    ,secondaryButton: .cancel()
                )
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
                    ).tint(.black)
                }
                ToolbarItem(placement: .principal) {
                    Text("Setting")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        ShareLink(item: URL(string: "https://apps.apple.com/us/app/tenna2-share-music-fest-tips/id6553996668?ign-itscg=30200&ign-itsct=apps_box_link&mttnsubad=6553996668")!)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.black)
                            .frame(width: 40,height: 40)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
        }
        
        
    }
}


struct SettingPanel: View {
    let icon: String
    let title: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    panelContent
                }
            } else {
                panelContent
            }
        }
    }
    
    private var panelContent: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(color)
                .fontWeight(.ultraLight)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .tint(.primary)
    }
}
