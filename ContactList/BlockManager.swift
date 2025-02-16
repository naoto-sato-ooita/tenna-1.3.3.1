//
//  BlockManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/05.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

final class BlockManager : ObservableObject {
    
    static let shared = BlockManager()
    private let userDefaults = UserDefaults.standard
    
    @Published var blockedUsers: [String] = []
    
    init() {
        loadBlockList()
    }
    
    // ブロック
    func blockUser(targetUserId: String) {
        
        // Userdefault
        var blockedUsers = userDefaults.stringArray(forKey: "blockedList") ?? []
        guard !blockedUsers.contains(targetUserId) else { return } // 登録済か確認
        blockedUsers.append(targetUserId)
        userDefaults.set(blockedUsers, forKey: "blockedList")
        
        // Firebase
        updateBlockedUsers(selectedUser: targetUserId)
        //deleteFromUserList(userId: targetUserId)
        
        // 共通　リストの更新
        self.blockedUsers = blockedUsers
        //Viewから消す
        ImpressionManager.shared.removeImpression(selectedUserId: targetUserId)
    }
    
    // Update blocked users in Firestore
    private func updateBlockedUsers(selectedUser: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("block").document(selectedUser)
        let blockListRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.setData([
            "blockedUsers": FieldValue.arrayUnion([currentUserId])],merge: true) { error in
                if let error = error {
                    print("Error updating blocked users: \(error)")
                } else {
                    print("Blocked users updated successfully")
                }
            }
        blockListRef.setData([
            "blockList": FieldValue.arrayUnion([selectedUser])],merge: true) { error in
                if let error = error {
                    print("Error updating blocked users: \(error)")
                } else {
                    print("Blocked users updated successfully")
                }
            }
    }
    
    // Remove request and friend
//    private func deleteFromUserList(userId: String) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        let userRef = Firestore.firestore().collection("users").document(currentUserId)
//        
//        userRef.updateData([
//            "requestList": FieldValue.arrayRemove([userId]),
//            "friendList": FieldValue.arrayRemove([userId])
//        ]) { error in
//            if let error = error {
//                print("Error declining request: \(error)")
//            } else {
//            }
//        }
//    }
    
    //ブロック解除
    func unblockUser(targetUserId: String) {
        
        // Userdefault
        var blockedUsers = userDefaults.stringArray(forKey: "blockedList") ?? []
        blockedUsers.removeAll{ $0 == targetUserId}
        userDefaults.set(blockedUsers, forKey: "blockedList")
        
        deleteFromBlockList(userId: targetUserId)
        self.blockedUsers = blockedUsers
    }
    
    private func deleteFromBlockList(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("block").document(userId)
        let blockList = Firestore.firestore().collection("users").document(currentUserId)
        
        
        userRef.updateData([
            "blockedUsers": FieldValue.arrayRemove([currentUserId])
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            } else {
                print("Success delete from blockedList")
            }
        }
        
        blockList.updateData([
            "blockList": FieldValue.arrayRemove([userId])
        ]) { error in
                if let error = error {
                    print("Error updating blocked users: \(error)")
                } else {
                    print("Success delete from blockedList")
                }
            }
    }
    
    // ブロックユーザーかどうか確認 true or false
    func isBlocked(targetUserId: String) -> Bool {
        // Userdefault
        guard let blockedUsers = userDefaults.stringArray(forKey: "blockedList") else { return false }
        return blockedUsers.contains(targetUserId)
    }
    
    
    func loadBlockList() {
        // Userdefault
        blockedUsers = userDefaults.stringArray(forKey: "blockedList") ?? []
    }
    
    func unblockAllUser() {
        // Userdefault
        var blockedUsers = userDefaults.stringArray(forKey: "blockedList") ?? []
        blockedUsers.removeAll()
        userDefaults.set(blockedUsers, forKey: "blockedList")
        
        // 共通
        self.blockedUsers = blockedUsers
    }
    
    
}
