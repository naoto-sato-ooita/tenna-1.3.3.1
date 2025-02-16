//
//  GroupChatView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/12/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import PhotosUI


struct GroupChatView: View {
    
    @Environment (\.dismiss) var dismiss
    @StateObject private var viewModel: GroupChatViewModel
    @State private var visibleMessageId: String?
    @State private var messageText = ""
    
    @State private var isDetail3 = false
    @State private var selectUid3: String? = nil
    
    @State private var isEditingGroupName = false
    @State private var editedGroupName = ""

    
    let groupId: String
    let groupName: String

    
    
    init(groupId: String,groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
        _viewModel = StateObject(wrappedValue: GroupChatViewModel(groupId: groupId))
    }
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundView()
                
                VStack(spacing:0){
                    // トップメッセージ表示セクション
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.topMessages) { message in
                                
                                
                                VStack {
                                    
                                    
                                    Button{
                                        visibleMessageId = message.id
                                    } label: {
                                        if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                //.clipShape(Circle())
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(message.message)
                                                .font(.headline)
                                                .lineLimit(2)
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                    HStack {
                                        Button {
                                            selectUid3 = message.senderId
                                            isDetail3 = true
                                        } label : {
                                            AsyncImage(url: viewModel.userImageCache[message.senderId]) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                        Text("\(message.likeCount)")
                                    }
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .tint(.primary)
                                
                            }
                        }
                        .padding()
                    }
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message, viewModel: viewModel)
                                        .id(message.id)
                                        .onChange(of: visibleMessageId) { newId in
                                            if let messageId = newId {
                                                withAnimation {
                                                    scrollViewProxy.scrollTo(messageId, anchor: .center)
                                                }
                                                // スクロール後にvisibleMessageIdをリセット
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    visibleMessageId = nil
                                                }
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages) { messages in
                            if let lastMessage = messages.last {
                                // 少し遅延を入れることで、レイアウトが完全に更新された後にスクロールする
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            if let lastMessage = viewModel.messages.last {
                                // 画面表示時も同様に少し遅延を入れる
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        
                        
                        TextField("message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                            .padding()
                        
                        PhotosPicker(selection: $viewModel.selectedImage,
                                     matching: .images) {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width:30)
                                .foregroundColor(.black)
                        }
                        
                        Button {
                            if !messageText.isEmpty {
                                viewModel.sendMessage(messageText)
                                messageText = ""
                            }
                            
                        } label: {
                            Image(systemName: "paperplane")
                                .resizable()
                                .scaledToFit()
                                .frame(width:30)
                                .foregroundColor(.black)
                            
                            
                        }
                        .padding()
                    }
                    
                }
            }
            .sheet(isPresented: $isDetail3,content:{
                if isDetail3, let selectUid = selectUid3 {
                    DetailView(
                        selectUid: .constant(selectUid),
                        showDetail: .constant(true))
                }
            })
            .toolbarTitleDisplayMode(.inline)  // Add this line
            .navigationBarBackButtonHidden(true)
            .onAppear {
                //GroupViewModel.shared.joinGroup(groupId: groupId,memberCount:viewModel.groupMembers.count)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        //GroupViewModel.shared.leaveGroup(groupId: groupId,memberCount:viewModel.groupMembers.count)
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(backArrow)
                            .frame(width: 40,height: 40)
                    }
                    
                }
                ToolbarItem(placement: .principal) {
//                    HStack {
                        if viewModel.isCreator && isEditingGroupName {
                            TextField("Group name", text: $editedGroupName)
                                .font(.headline)
                                .foregroundStyle(fontColor)
                                .onSubmit {
                                    viewModel.updateGroupName(editedGroupName)
                                    isEditingGroupName = false
                                    print("send")
                                }
                        } else {
                            Text(groupName)
                                .font(.headline)
                                .foregroundStyle(fontColor)
                                .onTapGesture {
                                    if viewModel.isCreator {
                                        editedGroupName = groupName
                                        isEditingGroupName = true
                                    }
                                }
                        }
                        
//                        Text("(\(viewModel.groupMembers.count))")
//                            .foregroundStyle(fontColor)
//                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {

                        
                        Button {
                            Task{
                                await viewModel.toggleBookmark(groupId: groupId)
                            }
                        } label: {
                            Image(systemName: viewModel.isBookmarked ? "star.fill" : "star")
                                .foregroundStyle(viewModel.isBookmarked ? .yellow : .gray)
                                .imageScale(.large)
                        }
                    
                }
                
            }

            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
        }
    }
}


struct MessageBubble: View {
    let message: GroupMessage
    @StateObject var viewModel: GroupChatViewModel
    @State private var showLikedUsers = false
    @State private var isLikeAnimating = false
    
    @State private var isDetail2 = false
    @State private var selectUid2: String? = nil
    
    @State private var selectedImage: URL? = nil
    @State private var showImageViewer = false
    
    var isLiked: Bool {
        if let localState = viewModel.localLikeStates[message.id] {
            return localState
        }
        return message.isLikedByCurrentUser
    }
    
    var likeCount: Int {
        viewModel.localLikeCounts[message.id] ?? message.likeCount
    }
    
    var body: some View {
        NavigationStack{
            
            
            
            HStack(alignment: .top) {
                
                if message.isCurrentUser {
                    Spacer()
                }
                
                if !message.isCurrentUser {
                    
                    Button {
                        selectUid2 = message.senderId
                        isDetail2 = true
                    } label: {
                        AsyncImage(url: viewModel.userImageCache[message.senderId]) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                VStack(alignment: message.isCurrentUser ? .trailing : .leading) {
                    //画像送信
                    if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200)
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedImage = url
                                    showImageViewer = true
                                }
                        } placeholder: {
                            ProgressView()
                        }
                        
                        //文送信
                    } else {
                        
                        Text(message.message)
                            .padding(10)
                            .background(message.isCurrentUser ? chatBox : chatBox2)
                            .foregroundColor(.black)
                            .clipShape(ChatBubble(isFromCurrentUser: message.isCurrentUser ? true : false))
                        
                    }
                    
                    if !message.isCurrentUser {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                isLikeAnimating = true
                                viewModel.toggleLike(for: message.id)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isLikeAnimating = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .scaleEffect(isLikeAnimating ? 1.5 : 1.0)
                                Text("\(likeCount)")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                }

                if !message.isCurrentUser {
                    Spacer()
                }
            }
            
            // Add sheet presentation
            .sheet(isPresented: $showImageViewer) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    if let url = selectedImage {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            // Add zoom gesture handling
                                        }
                                )
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                showImageViewer = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .contextMenu {
                if message.isCurrentUser {
                    Button(role: .destructive) {
                        viewModel.deleteMessage(message.id)
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                }
                
            }
            .sheet(isPresented: $isDetail2,content:{
                if isDetail2, let selectUid = selectUid2 {
                    DetailView(
                        selectUid: .constant(selectUid),
                        showDetail: .constant(true))
                }
            })
            .onAppear {
                viewModel.loadUserImage(for: message.senderId)
            }
            

        }
    }
}
