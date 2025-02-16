//
//  SettingRowView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//

import SwiftUI

struct IconStyleView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.custom(fontx, size: 16))
                .foregroundColor(.black)
        }
    }
}
