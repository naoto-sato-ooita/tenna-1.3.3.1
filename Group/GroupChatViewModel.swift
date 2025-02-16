//
//  GroupChatViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/12/25.
//

import Combine
import Firebase
import _PhotosUI_SwiftUI
import FirebaseStorage

class GroupChatViewModel: ObservableObject {
    
    @Published var messages: [GroupMessage] = []
    @Published var groupMembers: [User] = []
    @Published var topMessages: [GroupMessage] = []
    @Published var userImageCache: [String: URL] = [:]
    
    @Published var localLikeStates: [String: Bool] = [:]
    @Published var localLikeCounts: [String: Int] = [:]
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { try await uploadImage() } }
    }
    @Published var isCreator: Bool = false
    @Published var isBookmarked = false
    
    private let storage = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    private let imageManager = ImageManager.shared
    private let groupId: String
    
    init(groupId: String) {
        self.groupId = groupId
        print("Initializing GroupChatViewModel with groupId: \(groupId)")
        checkIfCreator()
        observeMessages()
        fetchAndObserveMembers()
        observeBookmarkStatus(groupId: groupId)
    }
    private func checkIfCreator() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("groups")
            .document(groupId)
            .getDocument { [weak self] snapshot, error in
                if let creatorId = snapshot?.data()?["creatorId"] as? String {
                    DispatchQueue.main.async {
                        self?.isCreator = creatorId == currentUserId
                    }
                }
            }
    }
    private func observeBookmarkStatus(groupId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users")
            .document(currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let document = snapshot else { return }
                let bookmarkedGroups = document.data()?["bookmarkedGroups"] as? [String] ?? []
                
                DispatchQueue.main.async {
                    self?.isBookmarked = bookmarkedGroups.contains(groupId)
                }
            }
    }
    func toggleBookmark(groupId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let groupRef = Firestore.firestore().collection("groups").document(groupId)
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        do {
            _ = try await Firestore.firestore().runTransaction { transaction, _ -> Any? in
                let groupDoc = try? transaction.getDocument(groupRef)
                let currentFavs = max(0, groupDoc?.data()?["numberOfFav"] as? Int ?? 0)
                
                let userDoc = try? transaction.getDocument(userRef)
                let bookmarkedGroups = userDoc?.data()?["bookmarkedGroups"] as? [String] ?? []
                
                if bookmarkedGroups.contains(groupId) {
                    let newFavCount = max(0, currentFavs - 1)
                    transaction.updateData(["numberOfFav": newFavCount], forDocument: groupRef)
                    transaction.updateData(["bookmarkedGroups": FieldValue.arrayRemove([groupId])], forDocument: userRef)
                } else {
                    transaction.updateData(["numberOfFav": currentFavs + 1], forDocument: groupRef)
                    transaction.updateData(["bookmarkedGroups": FieldValue.arrayUnion([groupId])], forDocument: userRef)
                }
                
                return nil
            }
        } catch {
            print("Error updating bookmark: \(error)")
        }
    }
    
    func updateGroupName(_ newName: String) {
        guard isCreator else { return }
        
        Firestore.firestore().collection("groups")
            .document(groupId)
            .updateData(["name": newName])
    }
    
    private func fetchAndObserveMembers() {
        // 初回一括取得
        Firestore.firestore().collection("groups")
            .document(groupId)
            .getDocument { [weak self] snapshot, error in
                guard let memberIds = snapshot?.data()?["members"] as? [String] else { return }
                self?.fetchUserDetails(for: memberIds)
            }
        
        // メンバー変更の監視開始
        Firestore.firestore().collection("groups")
            .document(groupId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let memberIds = snapshot?.data()?["members"] as? [String] else { return }
                self?.fetchUserDetails(for: memberIds)
            }
    }
    //メンバーの詳細情報を取得・更新
    private func fetchUserDetails(for userIds: [String]) {
        let userRefs = userIds.map { userId in
            Firestore.firestore().collection("users").document(userId)
        }
        
        userRefs.forEach { userRef in
            userRef.getDocument { [weak self] snapshot, error in
                guard let document = snapshot else { return }
                let user = User(from: document)
                
                if !(self?.groupMembers.contains(where: { $0.id == user.id }) ?? false) {
                    self?.groupMembers.append(user)
                }
            }
        }
    }
    func loadUserImage(for userId: String) {
        if userImageCache[userId] == nil {
            Task {
                if let imageURL = try? await ImageManager.shared.downloadImage(uid: userId) {
                    DispatchQueue.main.async {
                        self.userImageCache[userId] = imageURL
                    }
                }
            }
        }
    }
    
    
    func sendMessage(_ messageText: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let messageData: [String: Any] = [
            "senderId": currentUser.uid,
            "senderName": currentUser.displayName ?? "Unknown",
            "message": messageText,
            "timestamp": Timestamp(),
            "likeCount": 0,
            "likedUserIds": []  // 空の配列で初期化
        ]
        
        Firestore.firestore().collection("groups")
            .document(groupId)
            .collection("messages")
            .addDocument(data: messageData)
    }
    

    func uploadImage() async throws {
        guard let imageData = try await selectedImage?.loadTransferable(type: Data.self) else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        
        
        // Convert to UIImage to apply compression
        guard let uiImage = UIImage(data: imageData) else { return }
        
        // Compress the image to JPEG with compression quality 0.1
        guard let compressedImageData = uiImage.jpegData(compressionQuality: 0.4) else { return }
        
        // 画像をStorageにアップロード
        let imagePath = "groups/\(groupId)/\(UUID().uuidString).jpg"
        let storageRef = storage.child(imagePath)
        _ = try await storageRef.putDataAsync(compressedImageData)
        let imageUrl = try await storageRef.downloadURL()
        
        // メッセージとして保存
        let messageData: [String: Any] = [
            "senderId": currentUser.uid,
            "senderName": currentUser.displayName ?? "Unknown",
            "imageUrl": imageUrl.absoluteString,
            "timestamp": Timestamp(),
            "likeCount": 0,
            "likedUserIds": []
        ]
        
        try await Firestore.firestore().collection("groups")
            .document(groupId)
            .collection("messages")
            .addDocument(data: messageData)
    }
    
    
    private func observeMessages() {
        Firestore.firestore()
            .collection("groups")
            .document(groupId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No messages found for groupId: \(self?.groupId ?? "")")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.messages = documents.compactMap { document in
                        GroupMessage(from: document)
                    }
                    self?.updateTopMessages()
                }
            }
    }


    private func updateTopMessages() {
        topMessages = messages
            .sorted { $0.likeCount > $1.likeCount }
            .prefix(3)
            .map { $0 }
    }
    func deleteMessage(_ messageId: String) {
        Firestore.firestore().collection("groups")
            .document(groupId)
            .collection("messages")
            .document(messageId)
            .delete()
    }

    func toggleLike(for messageId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let isCurrentlyProcessing = localLikeStates[messageId] != nil
        if isCurrentlyProcessing { return }
        
        let messageRef = Firestore.firestore().collection("groups")
            .document(groupId)
            .collection("messages")
            .document(messageId)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let messageDocument: DocumentSnapshot
            do {
                try messageDocument = transaction.getDocument(messageRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = messageDocument.data() else { return nil }
            var likedUserIds = data["likedUserIds"] as? [String] ?? []
            var likeCount = data["likeCount"] as? Int ?? 0
            
            if likedUserIds.contains(currentUserId) {
                likedUserIds.removeAll { $0 == currentUserId }
                likeCount -= 1
                DispatchQueue.main.async {
                    self.localLikeStates[messageId] = false
                    self.localLikeCounts[messageId] = likeCount
                }
            } else {
                likedUserIds.append(currentUserId)
                likeCount += 1
                DispatchQueue.main.async {
                    self.localLikeStates[messageId] = true
                    self.localLikeCounts[messageId] = likeCount
                }
            }
            
            transaction.updateData([
                "likedUserIds": likedUserIds,
                "likeCount": likeCount
            ], forDocument: messageRef)
            
            return nil
        }) { [weak self] _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            }
            DispatchQueue.main.async {
                self?.localLikeStates[messageId] = nil
            }
        }
    }
}
