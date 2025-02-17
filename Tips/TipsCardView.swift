//
//  TipsCardView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/02/15.
//

import Firebase
import SwiftUI

struct TipsCardView: View {
    @ObservedObject private var locationManager = LocationManager.shared
    @StateObject private var viewModel = TipsViewModel.shared
    
    @State private var distance: Double = 0
    @State private var showUserDetail = false
    @State private var selectedUserId: String?
    
    @State private var isLiked = false
    @State private var creator: User?
    @State private var showDeleteAlert = false
    
    @State private var showLikeAnimation = false
    @State private var heartScale: CGFloat = 1.0
    @State private var selectedImage: URL? = nil
    @State private var isTipTo = false
    @State private var showImageViewer = false
    @Binding var isShow: Bool
    
    // Add state variable to track active sheet
    //@State private var activeSheet: ActiveSheet?
    
    let tips: Tips
    
    var likeCount: Int {
        viewModel.aroundTips.first(where: { $0.id == tips.id })?.likeCount ?? tips.likeCount
    }
    
    var isCurrentUser: Bool {
        tips.creatorId == Auth.auth().currentUser?.uid
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationStack{
            HStack(spacing: 10) {
                
                Button{
                    selectedImage = URL(string: imagePath)
                    showImageViewer = true
                } label:{
                    if let imagePath = tips.imagePath {
                        AsyncImage(url: URL(string: imagePath)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .cornerRadius(12)
                        } placeholder: {
                        }
                    }
                }
                
                //Text,date,distance
                VStack(alignment: .leading, spacing: 10){
                    Text(tips.content)
                        .font(.body)
                        .lineLimit(3)
                    
                    Text(dateFormatter.string(from: tips.createdAt))
                        .font(.caption)
                        .foregroundStyle(.gray)
                    HStack{
                        Text(String(format: "%.0fm away", distance))
                            .font(.subheadline)
                        Image(systemName: "figure.walk")
                            .foregroundStyle(.gray)
                        Text(String(format: "%.0f min", distance / 60))
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
                Button {
                    selectedUserId = tips.creatorId
                    showUserDetail = true
                } label: {
                    if let creator = creator {
                        if let urlString = creator.pathUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(profileBack)
                            }
                        }
                    }
                }
                Button {
                    isTipTo = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                
                
            }
            .padding(.leading,20)
            .frame(width: UIScreen.main.bounds.width - 20, height: 120)
            .background(White)
            .cornerRadius(12)
            
            
            .confirmationDialog("", isPresented: $isTipTo) {

                Button("Unlike") {
                    Task {
                        await viewModel.toggleLike(for: tips.id)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showLikeAnimation = true
                            heartScale = 1.3
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                showLikeAnimation = false
                                heartScale = 1.0
                            }
                        }
                        isLiked.toggle()
                    }
                }
                if tips.creatorId == Auth.auth().currentUser?.uid {
                    Button("Delete") {
                        showDeleteAlert = true
                    }
                }
            }
            
           .sheet(isPresented: $showUserDetail) {
               if let userId = selectedUserId {
                   DetailView(selectUid: .constant(userId), showDetail: $showUserDetail)
               }
           }
           .sheet(isPresented: $showImageViewer) {
               ImageView(selectedImage: $selectedImage, showImageViewer: $showImageViewer)
                   .navigationBarBackButtonHidden(true)
           }
            
            
            .alert("Delete", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteTip()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this tip?")
            }
            
            .onAppear {
                Task {
                    creator = try? await TipsViewModel.shared.fetchTipCreator(uid: tips.creatorId)
                }
                checkIfLiked()
                calculateDistance()
            }
            .navigationBarBackButtonHidden(true)
            
        }
    }
    private func checkIfLiked() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let likeDoc = try? await Firestore.firestore()
                .collection("tips")
                .document(tips.id)
                .collection("likes")
                .document(uid)
                .getDocument()
            
            DispatchQueue.main.async {
                isLiked = likeDoc?.exists ?? false
            }
        }
    }
    private func deleteTip() {
        Task {
            do {
                try await TipsViewModel.shared.deleteTip(tipId: tips.id)
                withAnimation {
                    isShow = false
                }
            } catch {
                print("Error deleting tip: \(error)")
            }
        }
    }
    private func calculateDistance() {
        let tipsLocation = CLLocation(latitude: tips.lat, longitude: tips.lng)
        let userLocation = CLLocation(
            latitude: locationManager.userLocation.latitude,
            longitude: locationManager.userLocation.longitude
        )
        distance = tipsLocation.distance(from: userLocation)
    }
}
