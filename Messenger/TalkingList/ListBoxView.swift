//
//  InBoxRowView.swift
//  air
//
//  Created by Naoto Sato on 2024/03/24.
//

import SwiftUI

struct ListBoxView: View {
    
    @StateObject var viewModel = TalkingListViewModel()
    @State private var showDeleteAlert = false
    let message: Message
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 8){
            
            ProfileImageView(user: message.user, size: .medium)
            
            VStack(alignment: .leading, spacing: 4){
                Text(message.user?.fullname ?? "")
                    .font(.custom(fontx, size: 18))
                    .fontWeight(.semibold)
                
                
                Text(message.messageText)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
                
            }
            
            HStack{
                Text(message.timestampString)
                Image(systemName: "chevron.right")
                
            }
            
            .font(.footnote)

        }
        .foregroundStyle(fontColor)
        .padding()
        .frame(height: 72)
    }
    
}
