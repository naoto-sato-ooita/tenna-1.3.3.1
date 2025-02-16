//
//  FirstTipView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/10.
//

import SwiftUI

struct FirstTipView: View {
    
    @Binding var showTip: Bool
    @Binding var selection : Int
    @State private var isLater : Bool = false
    let onAgree: () -> Void
    
    var body: some View {
        ZStack{
            
            BackgroundView()
            
            VStack(spacing: 10){
                Spacer()
                Text("Add your fav!")
                    .font(.custom(fontx, size: 40))
                Text("in")
                    .font(.custom(fontx, size: 30))
                Text("20 seconds")
                    .font(.custom(fontx, size: 40))
                    .padding(.bottom,40)
                
                
                
                Spacer()
                Button{
                    selection = 2
                } label: {
                    HStack{
                        Text("Go")
                            .font(.custom(fontx, size: 50))
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50,height: 50)
                    }
                }
                .padding(.bottom,50)
                
//                Button{
//                    showTip = false
//                    
//                } label: {
//                    HStack{
//                        Text("Skip")
//                            .font(.custom(fontx, size: 20))
//                        
//                        Image(systemName: "chevron.compact.down")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20,height: 20)
//                    }
//                }

            }
            .foregroundStyle(fontx_color)

            
        }
    }
}
