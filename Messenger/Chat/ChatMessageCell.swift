//
//  ChatMessageCell.swift
//  air
//
//  Created by Naoto Sato on 2024/03/24.
//

import SwiftUI

struct ChatMessageCell: View {
    let message: Message
    let user: User

    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {  // alignment を .bottom に変更、spacing を追加
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading) {
                if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                            .cornerRadius(10)

                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text(message.messageText)
                        .padding(.horizontal, 12)  // 横パディングを調整
                        .padding(.vertical, 8)     // 縦パディングを調整
                        .background(chatBox)
                        .foregroundColor(.black)
                        .clipShape(ChatBubble(isFromCurrentUser: message.isFromCurrentUser))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: message.isFromCurrentUser ? .trailing : .leading)
                }
            }
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        // Add sheet presentation
        
    }
}

