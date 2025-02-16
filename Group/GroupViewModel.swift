//
//  BoardViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/20.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseFirestoreSwift
import PhotosUI

final class GroupViewModel : ObservableObject {
    
    static let shared = GroupViewModel()
    
    @Published var groups: [Topic] = []
    @Published var popularGroups: [Topic] = []
    @Published var bookmarkedGroups: [Topic] = []
    @Published var lastCreatedGroup: (id: String, name: String)? = nil
    
    private let hasActiveGroupKey = "hasActiveGroup"
    private let userDefaults = UserDefaults.standard
    
    private let groupRef = Firestore.firestore().collection("groups")
    
    init() {
        fetchBookmarkedGroups()
    }
    
    // Region別グループ
    func fetchGroups(for region: String) async {
        do {
            let snapshot = try await groupRef
                .whereField("region", isEqualTo: region)
                .getDocuments()
            
            DispatchQueue.main.async {
                self.groups = snapshot.documents.compactMap { try? Topic(from: $0.data()) }
            }
        } catch {
            print("Error fetching groups: \(error)")
        }
    }
    
    // 最新グループ
    func fetchRecentGroups() async {
        let snapshot = try? await groupRef
            .order(by: "createdAt", descending: true)
            .limit(to: 5)
            .getDocuments()
        
        if let documents = snapshot?.documents {
            DispatchQueue.main.async {
                self.popularGroups = documents.compactMap { document in
                    try? Topic(from: document.data())
                }
            }
        }
    }
    
    
    // お気に入りのサブスク
    func fetchBookmarkedGroups() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users")
            .document(currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let document = snapshot else { return }
                let bookmarkedIds = document.data()?["bookmarkedGroups"] as? [String] ?? []
                
                // ブックマークから削除されたグループをリストからも削除
                self?.bookmarkedGroups.removeAll { group in
                    !bookmarkedIds.contains(group.id)
                }
                
                // 新しいブックマークのみを取得
                let newBookmarks = bookmarkedIds.filter { groupId in
                    !(self?.bookmarkedGroups.contains(where: { $0.id == groupId }) ?? false)
                }
                
                self?.fetchGroupDetails(for: newBookmarks)
            }
    }
    
    // お気に入りの詳細取得
    private func fetchGroupDetails(for groupIds: [String]) {
        groupIds.forEach { groupId in
            Firestore.firestore().collection("groups")
                .document(groupId)
                .getDocument { [weak self] snapshot, error in
                    if let data = snapshot?.data(),
                       let group = try? Topic(from: data) {
                        DispatchQueue.main.async {
                            if !(self?.bookmarkedGroups.contains(where: { $0.id == group.id }) ?? false) {
                                self?.bookmarkedGroups.append(group)
                                
                            }
                        }
                    }
                }
        }
    }
    
    
    func createGroup(name: String, region: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              !userDefaults.bool(forKey: hasActiveGroupKey) else { return }
        
        let newGroup = Topic(
            id: UUID().uuidString,
            name: name,
            creatorId: currentUserId,
            members: [currentUserId],
            region: region,
            createdAt: Date(),
            numberOfFav: 0,
            annotations: [],
            timestamp: Timestamp()
        )
        
        groupRef.document(newGroup.id).setData(newGroup.dictionary)
        userDefaults.set(true, forKey: hasActiveGroupKey)
        lastCreatedGroup = (id: newGroup.id, name: newGroup.name)
        
        Firestore.firestore().collection("users")
            .document(currentUserId)
            .updateData([
                "bookmarkedGroups": FieldValue.arrayUnion([newGroup.id])
            ])
    }
    
    //　ブックマークの切り替え
    func toggleBookmark(groupId: String) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              !groupId.isEmpty else { return false }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        //トランザクションで一貫性
        do {
            let result = try await Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
                let userDoc: DocumentSnapshot
                //　更新前を取得
                do {
                    userDoc = try transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                var bookmarkedGroups = userDoc.data()?["bookmarkedGroups"] as? [String] ?? []
                
                if bookmarkedGroups.contains(groupId) {
                    bookmarkedGroups.removeAll { $0 == groupId }
                } else {
                    bookmarkedGroups.append(groupId)
                }
                
                transaction.updateData(["bookmarkedGroups": bookmarkedGroups], forDocument: userRef)
                return true
            }
            
            return result as? Bool ?? false
        } catch {
            print("Error updating bookmark: \(error)")
            return false
        }
    }
    
    
    // 作成済グループの削除
    
    func deleteCreatedGroup() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        groupRef
            .whereField("creatorId", isEqualTo: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    let groupId = document.documentID
                    
                    // Delete group
                    self?.groupRef.document(groupId).delete { error in
                        if error == nil {
                            DispatchQueue.main.async {
                                self?.userDefaults.set(false, forKey: self?.hasActiveGroupKey ?? "")
                                
                                // Remove from bookmarks
                                Firestore.firestore().collection("users")
                                    .document(currentUserId)
                                    .updateData([
                                        "bookmarkedGroups": FieldValue.arrayRemove([groupId])
                                    ])
                                
                                // Remove from local bookmarkedGroups array
                                self?.bookmarkedGroups.removeAll { $0.id == groupId }
                            }
                        }
                    }
                }
            }
    }
    
    // グループへの合流
//    func joinGroup(groupId: String,memberCount: Int) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        
//        groupRef.document(groupId).updateData([
//            "members": FieldValue.arrayUnion([currentUserId]),
//            "memberCount": memberCount + 1
//        ])
//    }
    // グループからの離脱
//    func leaveGroup(groupId: String,memberCount: Int) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        
//        groupRef.document(groupId).getDocument { [weak self] snapshot, error in
//            guard let members = snapshot?.data()?["members"] as? [String] else { return }
//            
//            if members.count == 1 && members.contains(currentUserId) {
//                // 最後のメンバーが退出する場合
//                self?.groupRef.document(groupId).updateData([
//                    "members": FieldValue.arrayRemove([currentUserId]),
//                    "memberCount": memberCount - 1,
//                    "lastEmptyTimestamp": Timestamp()
//                ])
//            } else {
//                // 通常の退出
//                self?.groupRef.document(groupId).updateData([
//                    "members": FieldValue.arrayRemove([currentUserId])
//                ])
//            }
//        }
//    }
}


