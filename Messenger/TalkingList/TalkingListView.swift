//
//  InBoxView.swift
//  air
//
//  Created by Naoto Sato on 2024/03/24.
//

import Firebase
import SwiftUI

struct TalkingListView: View {
    
    @Environment (\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TalkingListViewModel
    @ObservedObject var impression_manager = ImpressionManager.shared
    @ObservedObject var block_manager = BlockManager.shared
    
    @State private var selectedUser: User? = nil
    @State private var selectedChatPartnerId: String?
    @State private var showChat = false
    
    @State private var showDeleteAlert = false
    @State private var messageToDelete: Message? = nil
    
    @State private var selectedDetail: User? = nil
    @State private var selectUid: String? = nil
    
    @State private var isDetail: Bool = false
    @State private var isDelete: Bool = false
    

    

    let columns : [GridItem] = Array(repeating:.init(.fixed(60)), count: 5)
    
    private var user: User?{
        return viewModel.currentUser
    }
    
    
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                BackgroundView()
                
                VStack{
                    
                    Divider().background(.white)
                    
                    
                    HStack{
                        Text("Popcorn")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        Spacer()
                    }
                    
                    //MARK: - Imp&Req List
                    if Array(ImpressionManager.shared.impressionUsers.filter { !BlockManager.shared.isBlocked(targetUserId: $0.id) }).isEmpty {
                        ZStack{
                            Image("popcorn")
                                .resizable()
                                .scaledToFill()
                                .frame(width:340,height:180)
                                .clipShape(RoundedRectangle(cornerRadius: 100))

                            
                            HStack{
                                Image(systemName : "popcorn.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30,height: 30)
                                Text("If you find someone who likes the same artist, give them Popcorn!")
                                    .font(.body)

                            }
                            .background{
                                Capsule()
                                    .foregroundStyle(.black)
                                    .opacity(0.4)
                            }
                            .foregroundStyle(White)
                            .fontWeight(.heavy)
                            .frame(width:280)
                        }


                        
                    } else {
                        
                        List{
                            
                            if !Array(ImpressionManager.shared.impressionUsers.filter { !BlockManager.shared.isBlocked(targetUserId: $0.id) }).isEmpty {
                                
                                
                                ForEach(Array(ImpressionManager.shared.impressionUsers.filter { !BlockManager.shared.isBlocked(targetUserId: $0.id) })) { popUser in
                                    
                                    Button {
                                        selectUid = popUser.uid
                                        isDetail = true
                                    } label: {
                                        HStack(spacing:20) {
                                            
                                            if let urlString = popUser.pathUrl, let url = URL(string: urlString) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80 , height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                }  placeholder: {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 80, height: 80)
                                                        .foregroundStyle(profileBack)
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                }
                                            }
                                            
                                            
                                            ZStack(alignment: .leading){
                                                Rectangle()
                                                    .fill(White)
                                                    .frame(width: 240 , height: 80)
                                                
                                                HStack(alignment: .center,spacing:10){
                                                    VStack {
//                                                        Text("Popcorn")
//                                                            .font(.caption2)
                                                        Text(popUser.fullname ?? "")
                                                            .font(.custom(fontx, size: 18))
                                                            
                                                    }
                                                    Spacer()
                                                    VStack(alignment: .trailing) {

                                                        if let timestamp = popUser.timestamp?.dateValue() {
                                                            Text("\(timestamp.timestampString())")
                                                                .font(.footnote)
                                                            
                                                        }
                                                        
                                                        if let address = popUser.address {
                                                            HStack{
                                                                Image(systemName: "mappin.and.ellipse")
                                                                Text("\(address)")
                                                                    
                                                            }
                                                            .font(.footnote)
                                                        }
                                                    }
                                                }
                                                .foregroundStyle(.black)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                .onDelete { offsets in
                                    ImpressionManager.shared.removeImpression(selectedUserId: selectUid ?? "")
                                }
                                .listRowBackground(White.opacity(0.4))
                            }

                        }
                        
                        .navigationBarTitleDisplayMode(.inline)
                        .listStyle(PlainListStyle())
                        .frame(height:UIScreen.main.bounds.height / 2.2)
                        
                    }
                    
                    
                    
                    Divider().background(.white)
                    
                    
                    //MARK: - Talking List
                    
                    HStack{
                        Text("Talk")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        Spacer()
                    }
                    
                    
                    if viewModel.recentMessages.filter({ !block_manager.isBlocked(targetUserId: $0.chatPartnerId) }).isEmpty {

                        ZStack{
                            Image("cheer")
                                .resizable()
                                .scaledToFill()
                                .frame(width:340,height:180)
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            
                            HStack{
                                Image(systemName : "message.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30,height: 30)
                                
                                Text("Thank the tips provider in a message!")
                                    .font(.body)

                            }
                            .background{
                                Capsule()
                                    .foregroundStyle(.black)
                                    .opacity(0.4)
                            }
                            .foregroundStyle(White)
                            .fontWeight(.heavy)
                            .frame(width:280)
                        }
                        
                    } else {
                        
                        List{
                            
                            ForEach(viewModel.recentMessages.filter { !block_manager.isBlocked(targetUserId: $0.chatPartnerId) }) { message in
                                
                                NavigationLink {
                                    if let user = message.user {
                                        ChatView(user: user)
                                    }
                                } label: {
                                    ZStack{
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.clear)
                                            .opacity(0.1)
                                            .blur(radius: 3)
                                            .frame(width: UIScreen.main.bounds.width - 20, height: 100)
                                            .shadow(color:.black.opacity(0.4), radius: 20, x: 50, y:30)
                                        
                                        
                                        RoundedRectangle(cornerRadius: 10,style: .continuous)
                                            .stroke(lineWidth: 0.1)
                                            .blur(radius: 1)
                                            .frame(width: UIScreen.main.bounds.width - 32, height: 100)
                                            .shadow(radius: 50)
                                        
                                        NavigationLink(value: message){
                                            EmptyView()
                                        }
                                        .opacity(0.0)
                                        
                                        
                                        ListBoxView(message: message)
                                           
                                        
                                    }
                                    
                                }
                                
                                .listRowBackground(White.opacity(0.4))
                            }
                            
                        }
                        
                        
                        .navigationDestination(isPresented: $showChat) {
                            if let user = selectedUser { //追加の遷移手段
                                ChatView(user: user)
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .listStyle(PlainListStyle())
                    }
                    
                    Spacer()

                    Button{
                        dismiss()
                    } label: {
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20,height: 20)
                            .foregroundStyle(.gray)
                            .imageScale(.large)
                    }
                }
                
            }
            .sheet(isPresented: $isDetail){
                if isDetail, let selectUid = selectUid {
                    DetailView(
                        selectUid: .constant(selectUid),
                        showDetail: .constant(true))
                    .navigationBarBackButtonHidden(true)
                }
            }



            
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Chat"),
                    message: Text("Are you sure you want to delete this chat?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let chatPartnerId = selectedChatPartnerId {
                            viewModel.deleteOldMessages(for: chatPartnerId)
                        }
                    }
                    ,secondaryButton: .cancel()
                )
            }
            
            
            .onChange(of: selectedUser) { newValue in
                showChat = newValue != nil
            }
            .onAppear {
                BlockManager.shared.loadBlockList()
                DispatchQueue.main.async {
                    if let userID = Auth.auth().currentUser?.uid {
                        ImpressionManager.shared.loadImpressions(uid: userID)
                        print(ImpressionManager.shared.impressionUsers)
                    } else {
                        print("Error: User ID is nil or empty. Skipping Firestore request.")
                    }
                }
            }
            
            .toolbarTitleDisplayMode(.inline)  // Add this line
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
                    )
                }
                ToolbarItem(placement: .principal) {
                    Text("Message")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                    
                }
                
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
        }
    }
}
