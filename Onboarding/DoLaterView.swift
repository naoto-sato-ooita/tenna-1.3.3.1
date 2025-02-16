//
//  DoLaterView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/10.
//

import SwiftUI

struct DoLaterView: View {
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            
            TipBackView()
            
            VStack(spacing: 10){
                
                //Image(Settingicon)
                
                Text("You can check it anytime here")
                    .font(.custom(fontx, size: 26))
                    .padding(.bottom,40)
                
                Button{
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.custom(fontx, size: 16))
                        .frame(width: UIScreen.main.bounds.width / 4 ,height: 24)
                        .foregroundColor(.white)
                        .padding(.top,200)
                }
                
            }
            .foregroundStyle(.white)
            .padding()
            
        }
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
        }
    }
}
