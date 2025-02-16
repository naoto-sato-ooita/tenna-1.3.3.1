//
//  SecondTipView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/03.
//


import SwiftUI

struct SecondTipView: View {

    @Binding var selection: Int
    @State private var artistName = ""
    @StateObject var viewModel = SettingViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(alignment: .center) {
                
                Text("Artist")
                    .font(.custom(fontx, size: 34))
                    .padding(.top,100)
                
                Spacer()
                
                VStack(spacing: 20) {
                    TextField("Favorite Artist", text: $artistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                    
                    Button {
                        if !artistName.isEmpty {
                            UserService.shared.savePreference(
                                uid: viewModel.user?.uid ?? "",
                                category: "Music",
                                preference: artistName
                            )
                        }
                        selection = 3
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 200, height: 40)
                            Text("Add")
                                .foregroundColor(.black)
                        }
                    }
                    Text("Editable later")
                        .font(.caption)
                }
                
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        selection = 1
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Back")
                                .font(.custom(fontx, size: 20))
                        }
                    }
                    
                    Button {
                        selection = 3
                    } label: {
                        HStack {
                            Text("Next")
                                .font(.custom(fontx, size: 20))
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .padding(.bottom,50)
            }
            .foregroundStyle(fontx_color)
        }
    }
}
