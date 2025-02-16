//
//  ChatViewModel.swift
//  air
//
//  Created by Naoto Sato on 2024/03/31.
//

import _PhotosUI_SwiftUI
import FirebaseStorage
import Firebase

final class ChatViewModel: ObservableObject{
    
    
    @Published var messageText = ""
    @Published var messages = [Message]()
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { try await uploadImage() } }
    }
    private let storage = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    let service: ChatService
    let currentUser: User
    
    init(user: User){
        self.service = ChatService(chatPartner: user)
        self.currentUser = user
        observeMessages()
    }
    
    func observeMessages(){
        service.observeMessages() { messages in
            self.messages.append(contentsOf: messages)
        }
    }
    
    func sendMessage(){
        service.sendMessage(messageText)
    }
    
    func uploadImage() async throws {
        guard let imageData = try await selectedImage?.loadTransferable(type: Data.self) else { return }
        
        // Convert and compress image
        guard let uiImage = UIImage(data: imageData) else { return }
        guard let compressedImageData = uiImage.jpegData(compressionQuality: 0.1) else { return }
        
        // Upload to Storage
        let imagePath = "chat/\(currentUser.id)/\(UUID().uuidString).jpg"
        let storageRef = storage.child(imagePath)
        _ = try await storageRef.putDataAsync(compressedImageData)
        let imageUrl = try await storageRef.downloadURL()
        
        // Send as message using existing service
        service.sendImageMessage(imageUrl: imageUrl.absoluteString)
    }
    
    func deleteMessage(messageId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if let message = messages.first(where: { $0.messageId == messageId }) {
            if message.fromId == currentUid {
                service.deleteMessage(messageId: messageId) { [weak self] success in
                    if success {
                        self?.messages.removeAll { $0.messageId == messageId }
                        // Update recent messages for TalkingListView
                        if messageId == self?.messages.last?.messageId {
                            // If deleted message was the last one, update with new last message
                            if let newLastMessage = self?.messages.last {
                                self?.service.updateRecentMessage(newLastMessage)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
