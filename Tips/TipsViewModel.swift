//
//  TipsViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/24.
//

import Firebase
import SwiftUI
import PhotosUI
import FirebaseStorage

class TipsViewModel: ObservableObject {
    static let shared = TipsViewModel()
    
    @EnvironmentObject var purchaseManager : PurchaseManager
    @Published var aroundTips: [Tips] = []
    @Published var bookmarkedTips: [Tips] = []
    @Published var errorMessage: String?
    @Published var showError = false
    
    
    private let tipsRef = Firestore.firestore().collection("tips")
    
    
    enum TipsError: LocalizedError {
        case locationUnavailable
        case networkError
        case tooManyRequests
        case dailyLimitReached
        
        var errorDescription: String? {
            switch self {
            case .locationUnavailable:
                return "Location services are required to view tips"
            case .networkError:
                return "Network connection error. Please try again"
            case .tooManyRequests:
                return "Too many requests. Please wait a moment"
            case .dailyLimitReached:
                return "You've reached your daily limit for creating tips"
            }
        }
    }
    
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

   
    //　Tipsの保存
    func createTips(content: String, image: PhotosPickerItem?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let lat = LocationManager.shared.userLocation.latitude
        let lng = LocationManager.shared.userLocation.longitude
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let geoHash = GFUtils.geoHash(forLocation: coordinate)
        
        var imagePath: String?
        if let image = image {
            imagePath = try await uploadTipsImage(image: image, uid: uid)
        }
        
        let tips = Tips(
            id: UUID().uuidString,
            content: content,
            creatorId: uid,
            imagePath: imagePath,
            likeCount: 0,
            createdAt: Date(),
            lat: lat,
            lng: lng,
            geoHash: geoHash
        )
        
        try await tipsRef.document(tips.id).setData(tips.dictionary)
        
        // Update aroundTips on main thread
        await MainActor.run {
            self.aroundTips.insert(tips, at: 0)
        }
    }
    
    // Tips画像の保存
    private func uploadTipsImage(image: PhotosPickerItem, uid: String) async throws -> String? {
        guard let imageData = try await image.loadTransferable(type: Data.self) else { return nil }
        
        // Convert to UIImage and compress
        guard let uiImage = UIImage(data: imageData),
              let compressedData = uiImage.jpegData(compressionQuality: 0.1) else { return nil }
        
        let (path, _) = try await ImageManager.shared.saveTipsImage(data: compressedData, tipId: UUID().uuidString)
        let storageRef = Storage.storage().reference()
        return try await storageRef.child(path).downloadURL().absoluteString
    }
    
    // Tipsの検索
    func searchTips(center: CLLocationCoordinate2D, radiusInM: Double, targetNum: Int) async {
        
        
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
        
        let queries = queryBounds.map { bound -> Query in
            return tipsRef
                .order(by: "geoHash")
                .order(by: "likeCount", descending: true)
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
                .limit(to: targetNum)
        }
        
        @Sendable func fetchMatchingDocs(from query: Query,
                                         center: CLLocationCoordinate2D,
                                         radiusInMeters: Double) async throws -> [QueryDocumentSnapshot] {
            let snapshot = try await query.getDocuments()
            
            return snapshot.documents.filter { document in
                let lat = document.data()["lat"] as? Double ?? 0
                let lng = document.data()["lng"] as? Double ?? 0
                let coordinates = CLLocation(latitude: lat, longitude: lng)
                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                
                return distance <= radiusInM
            }
        }
        
        do {
            let aroundTips = try await withThrowingTaskGroup(of: [QueryDocumentSnapshot].self) { group -> [QueryDocumentSnapshot] in
                for query in queries {
                    group.addTask {
                        try await fetchMatchingDocs(from: query, center: center, radiusInMeters: radiusInM)
                    }
                }
                var aroundTips = [QueryDocumentSnapshot]()
                for try await documents in group {
                    aroundTips.append(contentsOf: documents)
                }
                return aroundTips
            }
            
            let tips = aroundTips.compactMap { try? Tips(from: $0.data()) }
            
            
            await MainActor.run {
                self.aroundTips = tips
            }

            
        } catch {
            print("Unable to fetch tips data. \(error)")
        }
    }

    
    //　いいね
    func toggleLike(for tipId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let tipRef = tipsRef.document(tipId)
        let likeRef = tipRef.collection("likes").document(uid)
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        do {
            let likeDoc = try await likeRef.getDocument()
            
            if likeDoc.exists {
                try await likeRef.delete()
                try await tipRef.updateData([
                    "likeCount": FieldValue.increment(Int64(-1))
                ])
                
                // Remove from bookmarkedTips
                try await userRef.updateData([
                    "bookmarkedTips": FieldValue.arrayRemove([tipId])
                ])
                
                // Update local state immediately
                await MainActor.run {
                    if let index = aroundTips.firstIndex(where: { $0.id == tipId }) {
                        aroundTips[index].likeCount -= 1
                    }
                }
            } else {
                try await likeRef.setData(["timestamp": Timestamp()])
                try await tipRef.updateData([
                    "likeCount": FieldValue.increment(Int64(1))
                ])
                
                // Add to bookmarkedTips
                try await userRef.updateData([
                    "bookmarkedTips": FieldValue.arrayUnion([tipId])
                ])
                
                
                // Update local state immediately
                await MainActor.run {
                    if let index = aroundTips.firstIndex(where: { $0.id == tipId }) {
                        aroundTips[index].likeCount += 1
                    }
                }
            }
        } catch {
            print("Error toggling like: \(error)")
        }
    }
    
    // TipsDetail用
    func fetchTipCreator(uid: String) async throws -> User? {
        let userDoc = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return try? userDoc.data(as: User.self)
    }
    
    
    func loadBookmarkedTips() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let userDoc = try await Firestore.firestore().collection("users").document(uid).getDocument()
                if let user = try? userDoc.data(as: User.self),
                   let bookmarkedIds = user.bookmarkedTips {
                    
                    let tips = try await withThrowingTaskGroup(of: Tips?.self) { group in
                        for tipId in bookmarkedIds {
                            group.addTask {
                                let doc = try await self.tipsRef.document(tipId).getDocument()
                                return try? Tips(from: doc.data() ?? [:])
                            }
                        }
                        
                        var loadedTips: [Tips] = []
                        for try await tip in group {
                            if let tip = tip {
                                loadedTips.append(tip)
                            }
                        }
                        return loadedTips
                    }
                    
                    await MainActor.run {
                        self.bookmarkedTips = tips
                    }
                }
            } catch {
                print("Error loading bookmarked tips: \(error)")
            }
        }
    }
    // Tips削除　作成者のみ表示、文書、画像、アノテーション
    func deleteTip(tipId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let tipRef = tipsRef.document(tipId)
        let tipDoc = try await tipRef.getDocument()
        
        guard let creatorId = tipDoc.data()?["creatorId"] as? String,
              creatorId == uid else { return }
        
        // Modify image deletion logic
        if let imagePath = tipDoc.data()?["imagePath"] as? String,
           let imageURL = URL(string: imagePath) {
            // Get the storage path from the URL
            let storagePath = imageURL.lastPathComponent
            try await Storage.storage().reference().child("tips_images").child(storagePath).delete()
        }
        
        // Delete tip document
        try await tipRef.delete()
        
        // Update local array on main thread
        await MainActor.run {
            self.aroundTips.removeAll { $0.id == tipId }
        }
    }
    
    
}
