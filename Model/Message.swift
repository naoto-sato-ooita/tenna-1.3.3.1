//
//  Message.swift
//  air
//
//  Created by Naoto Sato on 2024/03/31.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable, Hashable{
    
    @DocumentID var messageId: String?
    let fromId: String
    let told: String
    let messageText: String
    let imageUrl: String?
    let timestamp: Timestamp
    
    var user: User?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var chatPartnerId: String {
        return fromId == Auth.auth().currentUser?.uid ? told : fromId
    }
    
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
    
    var timestampString: String {
        return timestamp.dateValue().timestampString()
    }
}


struct GroupMessage: Identifiable, Codable,Equatable {
    let id: String
    let senderId: String
    let senderName: String
    let message: String
    let imageUrl: String?
    let timestamp: Date
    var likeCount: Int
    var likedUserIds: [String]
    
    var isCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
    
    var isLikedByCurrentUser: Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        return likedUserIds.contains(currentUserId)
    }
    
    static func == (lhs: GroupMessage, rhs: GroupMessage) -> Bool {
        return lhs.id == rhs.id &&
        lhs.senderId == rhs.senderId &&
        lhs.senderName == rhs.senderName &&
        lhs.message == rhs.message &&
        lhs.timestamp == rhs.timestamp
    }
    
    init(from document: QueryDocumentSnapshot) {
        self.id = document.documentID
        let data = document.data()
        self.senderId = data["senderId"] as? String ?? ""
        self.senderName = data["senderName"] as? String ?? ""
        self.message = data["message"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.likeCount = data["likeCount"] as? Int ?? 0
        self.likedUserIds = data["likedUserIds"] as? [String] ?? []
    }
}
