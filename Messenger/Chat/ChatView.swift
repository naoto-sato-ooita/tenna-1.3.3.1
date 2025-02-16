//
//  ChatView.swift
//  air
//
//  Created by Naoto Sato on 2024/03/24.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @EnvironmentObject var talkingListViewModel: TalkingListViewModel
    @StateObject var viewModel: ChatViewModel
    @State private var showDeleteAlert = false
    @State private var selectedMessageId: String?
    @Environment (\.dismiss) var dismiss
    //@State private var isDialog2 : Bool = false
    //@State private var starfill : Bool = false
    
    let user: User
    
    init(user: User){
        self.user = user
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                
                ProfileImageView(user: user, size: .xlarge)
                
                Text(user.fullname ?? "")
                    .font(.custom(fontx, size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(fontColor)
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages) { message in
                                ChatMessageCell(message: message, user: user)
                                    .onLongPressGesture {
                                        if message.isFromCurrentUser {
                                            selectedMessageId = message.messageId
                                            showDeleteAlert.toggle()
                                        }
                                    }
                                    .id(message.messageId) // Ensure each message has a unique ID
                            }
                        }
                    }
                    .onChange(of: viewModel.messages.count) { count in
                        if let lastMessageId = viewModel.messages.last?.messageId {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        TextField("message...", text: $viewModel.messageText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        PhotosPicker(selection: $viewModel.selectedImage,
                                     matching: .images) {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundColor(.black)
                        }
                        
                        Button {
                            viewModel.sendMessage()
                            
                            let title : String = UserService.shared.currentUser?.fullname ?? ""
                            let body : String = viewModel.messageText
                            let recipient : String = user.fcmToken ?? ""
                            NotificationManager().sendPushNotification(fcmToken: recipient, Title: title, Body: body)
                            
                            viewModel.messageText = ""
                            
                            if let lastMessageId = viewModel.messages.last?.messageId {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                            
                            
                        } label: {
                            Image(systemName: "paperplane")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                                .frame(width:30)
                        }
                        .padding()
                        .disabled(viewModel.messageText.isEmpty)
                    }
                    //.padding(.vertical)
                    .onAppear {
                        if let lastMessageId = viewModel.messages.last?.messageId {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Message"),
                    message: Text("Are you sure?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let messageId = selectedMessageId {
                            viewModel.deleteMessage(messageId: messageId)
                            selectedMessageId = nil
                        }
                    },
                    secondaryButton: .cancel()
                )
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
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     Button {
                //         isDialog2 = true
                
                //     } label: {
                
                //         Image(systemName: starfill ? "star.fill" :"star")
                //             .frame(width: 40,height: 40)
                //             .foregroundStyle(starfill ? new_yellow : .black)
                //             .padding()
                
                //     }
                // }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
            // .confirmationDialog("", isPresented: $isDialog2) {
            
            //     Button("Friend Request") {
            //         RequestManager.shared.sendFriendRequest(selectedUserId: user.uid ?? "")
            //         starfill = true
            //     }
            
            // }
        }
    }
}
