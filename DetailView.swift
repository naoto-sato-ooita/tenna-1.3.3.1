//
//  DetailView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/05/25.
//

import SwiftUI
import MapKit
import Firebase


struct DetailView: View {
    
    @Environment (\.dismiss) var dismiss
    @EnvironmentObject var purchaseManager : PurchaseManager
    @ObservedObject var count_manager = CountManager.shared
    
    @Binding var selectUid : String
    @Binding var showDetail: Bool
    
    @State private var isDialog : Bool = false
    @State private var isReportSend: Bool = false
    @State private var isBlock :Bool = false
    @State private var isUnblock :Bool = false
    
    @State private var isAnimation1: Bool = false
    @State private var isAnimation2: Bool = false
    @State private var showPopcorn: Bool = false
    @State private var showHeart: Bool = false
    
    @State private var detailUser : User?
    
    @State private var showChar : Bool = false
    @State private var preferences: [[String: String]] = []
    
    var body: some View {
        NavigationStack {
            if let detailUser = detailUser {
                ZStack {
                    
                    if let urlString = detailUser.pathUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width)
                                .ignoresSafeArea(.all)
                        } placeholder: {
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .foregroundStyle(profileBack)
                        }
                    }
                    
                    VStack{
                        Spacer()
                        HStack{
                            HStack(spacing: 4){
                                
                                NavigationLink(destination: ChatView(user: detailUser)){
                                    
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(.white)
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "message")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(fontColor)
                                            .frame(width: 30,height: 30)
                                    }
                                    
                                }
                                
                                
                                Button{
                                    if !showPopcorn {
                                        
                                        if count_manager.useFeature(){
                                            ImpressionManager.shared.addImpression(selectedUserId: detailUser.uid ?? "")
                                        }
                                        
                                        withAnimation(.spring(duration: 1)) {
                                            showPopcorn.toggle()
                                        }
                                        withAnimation(showPopcorn ? .spring(duration:1) : .none){
                                            isAnimation1.toggle()
                                        }
                                        
                                        let title : String = "Popcorn has arrived!"
                                        let body : String = "Maybe we can be friends."
                                        let recipient : String = detailUser.fcmToken ?? ""
                                        
                                        NotificationManager().sendPushNotification(fcmToken: recipient, Title: title, Body: body)
                                    }
                                } label: {
                                    ZStack{
                                        ForEach(0..<6) { i in
                                            Circle().frame(width: 50,height: 50)
                                                .scaleEffect(isAnimation1 ? 0 : 1)
                                                .offset(y:isAnimation1 ? -200 : 0)
                                                .rotationEffect(.degrees(Double(i) * 60))
                                                .foregroundStyle(.white)
                                        }
                                        ZStack{
                                            
                                            if !isAnimation1 {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.black, lineWidth: 2)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundStyle(.white)
                                                    )
                                                    .frame(width: 50, height: 50)
                                            }
                                            
                                            Image(systemName: isAnimation1 ? "popcorn.fill" : "popcorn")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(fontColor)
                                                .frame(width: 30,height: 30)
                                        }
                                        
                                    }
                                }
                                .overlay(
                                    Text("\(count_manager.remainingCount)")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 0, y: 5),
                                    alignment: .bottomTrailing
                                )
                                
                            }
                            
                            Spacer()
                            
                        }//H-END
                        .padding()
                        
                        ZStack(){
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width , height: 155)
                                .foregroundStyle(.black)
                                .opacity(0.6)
                            
                            VStack(alignment:.leading){
                                Text(detailUser.fullname ?? "")
                                    .font(.custom(fontx, size: 36))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                    .overlay(alignment: .trailing){
                                        Rectangle().foregroundStyle(.black).opacity(0.4)
                                            .frame(maxWidth: showChar ? 0 : .infinity)
                                    }
                                    .animation(.spring, value:showChar)
                                    .onAppear(){ showChar = true }
                                
                                Text(detailUser.profile ?? "")
                                //.font(.custom(fontx, size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .overlay(alignment: .trailing){
                                        Rectangle().foregroundStyle(.black).opacity(0.4)
                                            .frame(maxWidth: showChar ? 0 : .infinity)
                                    }
                                
                                    .animation(.spring.delay(1), value:showChar)
                                    .onAppear(){ showChar = true }
                                
                                
                                HStack {
                                    if preferences.isEmpty {
                                        Text("No preferences added yet.")
                                            .foregroundColor(.gray)
                                    } else {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 10) {
                                                ForEach(preferences, id: \.self) { preference in
                                                    if let category = preference["category"], let item = preference["preference"] {
                                                        HStack(spacing: 2) {
                                                            ZStack {
                                                                Circle()
                                                                    .fill(swfontColor)
                                                                    .opacity(0.2)
                                                                    .frame(width: 28, height: 28)
                                                                
                                                                Image(systemName: iconName(for: category))
                                                                    .foregroundColor(swfontColor)
                                                                    .fontWeight(.heavy)
                                                            }
                                                            
                                                            Text(item)
                                                                .fontWeight(.bold)
                                                                .foregroundColor(swfontColor)
                                                                .lineLimit(1)
                                                                .fixedSize(horizontal: true, vertical: false)
                                                        }
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .fill(swfontColor)
                                                                .opacity(0.2)
                                                        )
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .frame(height:40)
                                    }
                                    
                                }
                            }
                            .padding(.horizontal)
                            
                        }
                        
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
                    .padding(.bottom,40)

                    
                }
                
                
                .confirmationDialog("", isPresented: $isDialog) {
                    Button("Report") {
                        isReportSend = true
                    }
                    Button("Block") {
                        isBlock = true
                    }
                    Button("Unblock") {
                        isUnblock = true
                    }
                }
                .sheet(isPresented: $isReportSend) {
                    if let uid = detailUser.uid {
                        ReportSendView(selectedUid: uid)
                            .presentationDetents([.height(600)])
                    }
                }
                
                .alert("Block?",isPresented: $isBlock) {
                    Button(role: .destructive) {
                        if let uid = detailUser.uid {
                            BlockManager.shared.blockUser(targetUserId: uid)
                        }
                    } label: { Text("Yes") }
                }
                
                .alert("Unblock?",isPresented: $isUnblock) {
                    
                    Button(role: .destructive) {
                        if let uid = detailUser.uid {
                            BlockManager.shared.unblockUser(targetUserId: uid)
                        }
                    } label: { Text("Yes") }
                }
                
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                dismiss()
                            }, label: {
                                ZStack{
                                    Circle()
                                        .fill(swfontColor)
                                        .opacity(0.4)
                                        .frame(width:40,height:40)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(backArrow)
                                        .frame(width: 40,height: 40)
                                }
                            }
                        )
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                isDialog = true
                            }, label: {
                                ZStack{
                                    Circle()
                                        .fill(swfontColor)
                                        .opacity(0.4)
                                        .frame(width:40,height:40)
                                    
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(backArrow)
                                        .frame(width: 40,height: 40)
                                }
                            }
                            
                            
                        )
                        
                    }
                    
                }
            }
        }

        .onAppear{
            let limit = purchaseManager.isPopcorn ? 30 : 10
            count_manager.ResetHandler(limit: limit)
            
            Task {
                detailUser = try await UserService.shared.fetchSelectUser(uid: selectUid)
                detailUser?.uid = selectUid
            }
            
            Task{
                preferences = await UserService.shared.fetchPreferences(uid: selectUid) ?? [["":""]]
            }
        }
    }
}
