//
//  MessageService.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/03/31.
//


import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChatService {
    
    let chatPartner: User
    private let authRef = Auth.auth()
    private let messageRef = Firestore.firestore().collection("messages")
    
    
    func sendMessage (_ messageText: String){
        guard let currentUid = authRef.currentUser?.uid else {return}
        let chatPartnerId = chatPartner.id
        
        //参照先の作成
        let currentUserRef = messageRef.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = messageRef.document(chatPartnerId).collection(currentUid)
        
        //最新の発言
        let recentCurrentUserRef = messageRef.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messageRef.document(chatPartnerId).collection("recent-message").document(currentUid)
        let messageId = currentUserRef.documentID
        
        //Messageドキュメントの中身
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            told: chatPartnerId,
            messageText: messageText,
            imageUrl: "",
            timestamp: Timestamp()
        )
        
        //一式を格納
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        recentCurrentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)
        
    }
    func sendImageMessage(imageUrl: String) {
        guard let currentUid = authRef.currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        // 参照先の作成
        let currentUserRef = messageRef.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = messageRef.document(chatPartnerId).collection(currentUid)
        
        // 最新の発言用の参照
        let recentCurrentUserRef = messageRef.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messageRef.document(chatPartnerId).collection("recent-message").document(currentUid)
        let messageId = currentUserRef.documentID
        
        // 画像メッセージの作成
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            told: chatPartnerId,
            messageText: "",
            imageUrl: imageUrl,
            timestamp: Timestamp()
        )
        
        // データの保存
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        recentCurrentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)
    }
    
    func observeMessages(completion: @escaping([Message]) -> Void) {
        guard let currentUid = authRef.currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        //日付、降順で並び替えて取得
        let query = messageRef
            .document(currentUid)
            .collection(chatPartnerId)
            .order(by: "timestamp" , descending: false)
        
        //データベースに更新があった際に通知され、リアルタイムで自動更新するため非同期処理ではない
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({$0.type == .added}) else { return }
            var messages = changes.compactMap( {try? $0.document.data(as: Message.self) } )
            
            for (index, message) in messages.enumerated() where !message.isFromCurrentUser {
                messages[index].user = chatPartner
            }
            
            completion(messages)
        }
    }
    
    func deleteMessage(messageId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = authRef.currentUser?.uid else {
            completion(false)
            return
        }
        let chatPartnerId = chatPartner.id
        
        let currentUserMessageRef = messageRef.document(currentUid).collection(chatPartnerId).document(messageId)
        let chatPartnerMessageRef = messageRef.document(chatPartnerId).collection(currentUid).document(messageId)
        let recentCurrentUserRef = messageRef.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messageRef.document(chatPartnerId).collection("recent-messages").document(currentUid)
        
        // Get the next most recent message before deleting
        messageRef.document(currentUid).collection(chatPartnerId)
            .order(by: "timestamp", descending: true)
            .limit(to: 2)  // Get two to have the next message after deletion
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let batch = Firestore.firestore().batch()
                batch.deleteDocument(currentUserMessageRef)
                batch.deleteDocument(chatPartnerMessageRef)
                
                // If there's a previous message, update recent messages
                if documents.count > 1, let nextMessage = try? documents[1].data(as: Message.self) {
                    if let messageData = try? Firestore.Encoder().encode(nextMessage) {
                        batch.setData(messageData, forDocument: recentCurrentUserRef)
                        batch.setData(messageData, forDocument: recentPartnerRef)
                    }
                } else {
                    // If no previous message exists, delete recent message documents
                    batch.deleteDocument(recentCurrentUserRef)
                    batch.deleteDocument(recentPartnerRef)
                }
                
                batch.commit { error in
                    completion(error == nil)
                }
            }
    }
    
    func updateRecentMessage(_ message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let recentCurrentUserRef = messageRef.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messageRef.document(chatPartnerId).collection("recent-messages").document(currentUid)
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        recentCurrentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)
    }
}


final class  TalkingListModel {
    @Published var documentChanges = [DocumentChange]()
    private let authRef = Auth.auth()
    private let messageRef = Firestore.firestore().collection("messages")
    
    func observeRecentMessages() {
        guard let uid = authRef.currentUser?.uid else{ return }
        
        let query = messageRef
            .document(uid).collection("recent-messages")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter( {
                $0.type == .added || $0.type == .modified
            }) else { return }
            
            self.documentChanges = changes
        }
    }
}
