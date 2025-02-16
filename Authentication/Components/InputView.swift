//
//  InputView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    let title: String
    let placeholeder: String
    var isSecureField = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12){
            
            Text(title)
                .font(.custom(fontx, size: 18))
                .fontWeight(.semibold)
                .foregroundColor(fontx_color)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholeder,text: $text)
                    .font(.system(size: 18))
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }
            
            else {
                TextField(placeholeder,text: $text)
                    .font(.system(size: 18))
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }
            
            Divider()
            
        }
        .opacity(0.9)
        
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholeder: "name@gamil.com")
}
