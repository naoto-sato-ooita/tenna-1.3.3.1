//
//  TipsDetailView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/24.
//
import Firebase
import SwiftUI

struct TipsDetailView: View {
    
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
    @State private var showImageViewer = false
    
    @Binding var isShow: Bool
    
    
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
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 10){
                        Text(tips.content)
                            .font(.body)
                            .lineLimit(3)
                        Text(dateFormatter.string(from: tips.createdAt))
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        
                        HStack {
                            Text(String(format: "%.0fm away", distance))
                                .font(.subheadline)
                            Image(systemName: "figure.walk")
                                .foregroundStyle(.black)
                            Text(String(format: "%.0f min", distance / 60))
                                .font(.subheadline)
                                .foregroundStyle(.black)
                        }
                        
                        
                        HStack{
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
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                            
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundStyle(profileBack)
                                        }
                                    }
                                }
                            }
                            
                            Button {
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
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(isLiked ? .red : .gray)
                                        .scaleEffect(heartScale)
                                        .overlay {
                                            if showLikeAnimation {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.red)
                                                    .scaleEffect(1.5)
                                                    .opacity(0)
                                            }
                                        }
                                    Text("\(likeCount)")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        if let creator = creator {
                            Text(creator.fullname ?? "")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    
                    if let imagePath = tips.imagePath {
                        AsyncImage(url: URL(string: imagePath)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .onTapGesture {
                                    selectedImage = URL(string: imagePath)
                                    showImageViewer = true
                                }
                                .cornerRadius(12)
                        } placeholder: {
                            
                        }
                    }
                    
                }
                .padding()
                .frame(width: 360, height: 220)
                .background(White)
                .cornerRadius(12)
                .shadow(radius: 5)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 8) {
                    if isCurrentUser {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.red)
                        }
                    }
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isShow = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(8)
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
            
            
            .alert("Delete Tip", isPresented: $showDeleteAlert) {
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


struct ImageView : View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage : URL?
    @Binding var showImageViewer : Bool
    
    var body: some View {
        
        ZStack {
            Color.black
            
            if let url = selectedImage {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                } placeholder: {
                    ProgressView()
                }
            }
            
        }
        .background(.black)
        
        //        .toolbar {
        //            ToolbarItem(placement: .navigationBarLeading) {
        //                Button(action: {
        //                    dismiss()
        //                } ,label: {
        //                    Image(systemName: "arrow.left")
        //                        .foregroundColor(backArrow)
        //                        .frame(width: 40,height: 40)
        //                }
        //                )
        //            }
        //        }
        
    }
}
