//
//  CreateGroupView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/20.
//

import SwiftUI
import Firebase

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GroupViewModel.shared
    
    @State private var groupName = ""
    @State private var selectedRegion = "USA"
    @Binding var makeGroup : Bool
    @State private var showAlert = false
    @State private var isSelectFes = false
    @State private var showPostTopic = false
    
    let regions = ["USA", "EU", "ASIA"]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // 本番は要る
    private let userDefaults = UserDefaults.standard
    private let hasActiveGroupKey = "hasActiveGroup"
    
    var body: some View {
        NavigationStack{
            
            ZStack(alignment: .top){
                
                BackgroundView()
                
                VStack {
                    Divider().background(.white)
                    
                    // Popular Groups Grid
                    HStack {
                        Text("Recent")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        Spacer()
                    }
                    
                    TabView {
                        ForEach(viewModel.popularGroups.prefix(4)) { group in
                            NavigationLink(destination: GroupChatView(groupId: group.id, groupName: group.name)) {
                                PopularGroupCard(group: group)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    Divider().background(.white)
                    
                    //MARK: - Delete

//                    HStack{
//                        Text("Create")
//                            .font(.subheadline)
//                            .foregroundStyle(fontColor.opacity(0.8))
//                            .padding(.leading)
//                        
//                        Spacer()
//                        
//                        Text("1 topic/user")
//                            .font(.caption)
//                            .foregroundStyle(fontColor.opacity(0.6))
//                            .padding(.trailing)
//                    }
//                    .padding(.bottom,20)
//                    
//                    HStack{
//                        TextField("Topic Name", text: $groupName)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.horizontal)
//                            .onChange(of: groupName) { newValue in
//                                if newValue.count >= 30 {
//                                    groupName = String(newValue.prefix(30))
//                                }
//                            }
//                        
//                        Picker("Region", selection: $selectedRegion) {
//                            ForEach(regions, id: \.self) { region in
//                                Text(region).tag(region)
//                            }
//                        }
//                        
//                    }
//                    .padding(.horizontal)
//                    
//                    
//                    HStack{
//                        
//                        Button {
//                            if !UserDefaults.standard.bool(forKey: "hasActiveGroup") {
//                                viewModel.createGroup(name: groupName, region: selectedRegion)
//                                showPostTopic = true
//                                groupName = ""
//                            }
//                        } label: {
//                            ZStack{
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(UserDefaults.standard.bool(forKey: "hasActiveGroup") ? .gray : .white, lineWidth: 2)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .foregroundStyle(UserDefaults.standard.bool(forKey: "hasActiveGroup") ? .gray : sw_pos)
//                                    )
//                                    .frame(width: 200, height: 40)
//                                
//                                HStack {
//                                    Text("Post")
//                                        .font(.title3)
//                                        .foregroundStyle(.white)
//                                    
//                                    Image(systemName: "bookmark")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .foregroundColor(.white)
//                                        .frame(width: 20,height: 20)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        .disabled(groupName.isEmpty)
//                        
//                        if UserDefaults.standard.bool(forKey: "hasActiveGroup") {
//                            
//                            Button() {
//                                viewModel.deleteCreatedGroup()
//                                dismiss()
//                            } label: {
//                                ZStack{
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.white, lineWidth: 2)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .foregroundStyle(.black)
//                                        )
//                                        .frame(width: 120, height: 40)
//                                    
//                                    HStack {
//                                        Text("Delete")
//                                            .font(.custom(fontx, size: 14))
//                                            .foregroundStyle(swfontColor)
//                                        
//                                        Image(systemName: "drop.fill")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .foregroundColor(sw_pos)
//                                            .frame(width: 20,height: 20)
//                                    }
//                                }
//                            }
//                        }
//                    }
                    //MARK: -
                    Divider().background(.white)
                    
                    HStack{
                        Text("Bookmark")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button{
                            isSelectFes = true
                        } label:{
                            HStack{
                                Image(systemName:"plus")
                                    .font(.title3)
                                    .foregroundStyle(fontColor.opacity(0.6))
                                    .padding(.trailing)
                            }
                        }
                    }
                    .sheet(isPresented: $isSelectFes){SelectFesView(isFromPlus: .constant(false))
                            .presentationDetents([.height(600)])
                            .presentationCornerRadius(40)
                    }
                    
                    
                    List(viewModel.bookmarkedGroups) { group in
                        NavigationLink {
                            GroupChatView(groupId: group.id, groupName: group.name)
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            
                            HStack {
                                Text(group.name)
                                    .font(.headline)
                                    .foregroundStyle(fontColor)
                                    .padding(.horizontal)
                                Spacer()
                                
                            }
                            .frame(width: 300, height: 40)
                        }
                        .padding(.horizontal)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    
                    
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
            .navigationDestination(isPresented: $showPostTopic){
                if let group = viewModel.lastCreatedGroup {
                    GroupChatView(groupId: group.id, groupName: group.name)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                
                Task {
                    await viewModel.fetchRecentGroups()
                }
                viewModel.fetchBookmarkedGroups()
            }
            .alert("There are already topic created", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text("To create a new topic, delete an existing one")
            }
            .toolbarTitleDisplayMode(.inline)  // Add this line
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    } ,label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(backArrow)
                            .frame(width: 40,height: 40)
                    }
                    )
                }
                ToolbarItem(placement: .principal) {
                    Text("Topic")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                }
                
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
            
//            .onAppear{
//                userDefaults.set(false, forKey: hasActiveGroupKey) //DEBUG only
//                
//            }
            
        }
    }
}


struct PopularGroupCard: View {
    let group: Topic
    @State private var randomImage: String?
    @State private var topMessage: String?
    
    var body: some View {
        VStack {
            
            if let imageUrl = randomImage {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 320, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    ProgressView()
                }
            } else if let message = topMessage {
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 320, height: 160)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            HStack {
                
                Text(group.name)
                    .font(.headline)
                    .foregroundStyle(fontColor)
                Image(systemName: "person.2.fill")
                    .foregroundColor(sw_normal)
                Text("\(group.members.count)")
                    .tint(.primary)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(group.numberOfFav)")
                    .tint(.primary)
            }
            .font(.caption)
        }
        .padding(.bottom,30)
        .onAppear {
            fetchGroupContent()
        }
    }
    private func fetchGroupContent() {
        Firestore.firestore().collection("groups")
            .document(group.id)
            .collection("messages")
            .whereField("imageUrl", isNotEqualTo: "")
            .getDocuments { snapshot, _ in
                if let images = snapshot?.documents.compactMap({ $0.data()["imageUrl"] as? String }),
                   !images.isEmpty {
                    randomImage = images.randomElement()
                } else {
                    fetchTopMessage()
                }
            }
    }
    
    private func fetchTopMessage() {
        Firestore.firestore().collection("groups")
            .document(group.id)
            .collection("messages")
            .order(by: "likeCount", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, _ in
                topMessage = snapshot?.documents.first?.data()["message"] as? String
            }
    }
    
}
