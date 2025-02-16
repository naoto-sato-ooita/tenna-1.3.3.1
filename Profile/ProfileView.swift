//
//  ProfileView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/05/25.
//

import SwiftUI
import Firebase
import PhotosUI

struct ProfileView: View {
    
    @Environment (\.dismiss) var dismiss
    
    @StateObject private var viewModel = SettingViewModel.shared
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectImageData: Data? = nil
    @State private var showSheetUpdateName : Bool = false
    
    @State private var isNameChange : Bool = false
    @State private var isProfChange : Bool = false
    @State private var isFavChange : Bool = false
    
    
    @State private var showChar : Bool = false
    @State private var preferences: [[String: String]] = []
    
    
    var body: some View {
        if viewModel.user != nil {
            NavigationStack {
                ZStack {
                    BackgroundView()
                    
                    Button(action: {
                        // This action will show the PhotosPicker when the image is tapped
                    }) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            if let imageData = selectImageData, let uiImage = UIImage(data: imageData) {
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .ignoresSafeArea(.all)
                                
                            } else if let urlString = viewModel.user?.pathUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width)
                                        .ignoresSafeArea(.all)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 80, height: 80)
                                }
                            } else {
                                Image("photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:340,height:340)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .opacity(0.4)
                            }
                        }
                    }
                    VStack{
                        
                        Spacer()
                        
                        ZStack{
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width , height: 150)
                                .foregroundColor(.black)
                                .opacity(0.6)
                            
                            VStack(alignment:.leading){
                                
                                Button {
                                    isNameChange = true
                                } label: {
                                    Text(viewModel.user?.fullname ?? "")
                                        .font(.custom(fontx, size: 36))
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                        .frame(height:40)
                                }
                                
                                Button{
                                    isProfChange = true
                                } label:{
                                    HStack{
                                        Text(viewModel.user?.profile ?? "feeling...")
                                            .fontWeight(.semibold)
                                            .foregroundColor(swfontColor)
                                        
                                        Image(systemName: "pencil.and.scribble")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30,height: 30)
                                            .foregroundColor(swfontColor)
                                        
                                    }
                                }
                                
                                Button{
                                    isFavChange = true
                                } label:{
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 10) {
                                            ForEach(preferences, id: \.self) { preference in
                                                if let category = preference["category"], let item = preference["preference"] {
                                                    HStack(spacing: 2) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(swfontColor)
                                                                .opacity(0.2)
                                                                .frame(width: 28, height: 28)
                                                            
                                                            Image(systemName: iconName(for: category))
                                                                .foregroundColor(swfontColor)
                                                                .fontWeight(.heavy)
                                                        }
                                                        
                                                        Text(item)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(swfontColor)
                                                            .lineLimit(1)
                                                            .fixedSize(horizontal: true, vertical: false)
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        Capsule()
                                                            .fill(swfontColor)
                                                            .opacity(0.2)
                                                    )
                                                }
                                                else {
                                                    HStack{
                                                        Text("Add your fav Artists.")
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(swfontColor)
                                                        Image(systemName: "tag")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 20,height: 20)
                                                            .foregroundColor(swfontColor)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .frame(height:40)
                            }
                            .padding(.horizontal)
                            .padding(.leading,10)
                        }

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
                    .padding(.bottom,20)
                }
                .sheet(isPresented: $isNameChange) {
                    UpdateUserNameView(viewModel: AuthenticationViewModel())
                        .presentationDetents([.height(880)])
                        .navigationBarBackButtonHidden(true)
                }
                .sheet(isPresented: $isProfChange) {
                    UpdateUserProfileView()
                        .presentationDetents([.height(880)])
                        .navigationBarBackButtonHidden(true)
                }
                .sheet(isPresented: $isFavChange) {
                    UpdateFavView()
                        .presentationDetents([.height(880)])
                        .navigationBarBackButtonHidden(true)
                }
                .onAppear{
                    Task{
                        try await SettingViewModel.shared.loadCurrentUser()
                        preferences = await UserService.shared.fetchPreferences(uid: viewModel.user?.uid ?? "") ?? [["":""]]
                    }
                }
                .onChange(of: selectedItem, perform: { newValue in
                    if let newValue {
                        
                        viewModel.saveProfileImage(item: newValue)
                        Task{
                            selectImageData = try? await newValue.loadTransferable(type: Data.self)
                        }
                    }
                })
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                dismiss()

                            }, label: {
                                ZStack{
                                    Circle()
                                        .fill(swfontColor)
                                        .opacity(0.4)
                                        .frame(width:40,height:40)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(backArrow)
                                        .frame(width: 40,height: 40)
                                }
                            }
                        )
                    }
                }
            }
            
            
            
            
        }
    }
}


private func calculateWidth(for text: String) -> CGFloat {
    let font = UIFont.systemFont(ofSize: 14, weight: .bold)
    let attributes = [NSAttributedString.Key.font: font]
    let size = (text as NSString).size(withAttributes: attributes)
    return size.width + 60 // アイコンとパディングの余白
}

