//
//  TipLandingView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/10.
//

import SwiftUI

struct TipLandingView: View {
    
    @State var selection = 1
    @Binding var showTip : Bool
    @Binding var isSearch : Bool
    let onAgree: () -> Void
    
    var body: some View {
        
        ZStack{
            BackgroundView()
            
            TabView(selection: $selection) {
                
                FirstTipView(showTip: $showTip, selection: $selection, onAgree: onAgree)
                    .tag(1)
                
                SecondTipView(selection: $selection)
                    .tag(2)
                
                ThirdTipView(selection: $selection)
                    .tag(3)
                
                ForthTipView(showTip: $showTip, onAgree: onAgree,selection: $selection)
                    .tag(4)
                
            }
            .tabViewStyle(.page)
        }
    }
}
