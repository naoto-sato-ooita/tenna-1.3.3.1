//
//  ThirdTipView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/09.
//

import SwiftUI
import Firebase

struct ThirdTipView: View {

    @Binding var selection: Int
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                Text("Music Festivals")
                    .font(.custom(fontx, size: 34))
                    .padding(.top,50)
                
                SelectFesView(isFromPlus: .constant(false))
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        selection = 2
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
                        selection = 4
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
