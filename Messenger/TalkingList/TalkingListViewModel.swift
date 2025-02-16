//
//  InboxViewModel.swift
//  air
//
//  Created by Naoto Sato on 2024/03/26.
//

import Foundation
import Combine
import Firebase

final class TalkingListViewModel: ObservableObject {
    var currentUser: User?
    @Published var recentMessages = [Message]()
    //@Published var friendUsers = [User]()
    
    private var cancellables = Set<AnyCancellable>()
    private let service = TalkingListModel()
    
    
    init(){
        setupSubscribers()
        service.observeRecentMessages()

    }
    
    private func setupSubscribers(){
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
        
        service.$documentChanges.sink { [weak self] changes in
            self?.loadInitialMessages(fromChanges: changes)
        }.store(in: &cancellables)
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        var messages = changes.compactMap { try? $0.document.data(as: Message.self) }
        
        for i in 0..<messages.count {
            let message = messages[i]
            
            UserService.fetchChatUser(uid: message.chatPartnerId) { user in
                messages[i].user = user
                self.updateRecentMessages(with: messages[i])
            }
        }
    }
    
    private func updateRecentMessages(with message: Message) {
        DispatchQueue.main.async {
            // Remove existing message from same user
            self.recentMessages.removeAll { $0.chatPartnerId == message.chatPartnerId }
            // Add new message
            self.recentMessages.append(message)
            // Sort by timestamp
            self.recentMessages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        }
    }
    
    func deleteOldMessages(for chatPartnerId: String) {
        
        let user = User(id:chatPartnerId)
        let chatViewModel = ChatViewModel(user: user)
        
        chatViewModel.messages.forEach { message in
            if message.fromId == Auth.auth().currentUser?.uid {
                chatViewModel.deleteMessage(messageId: message.messageId!)
            }
        }
        
        DispatchQueue.main.async {
            self.recentMessages.removeAll { $0.chatPartnerId == chatPartnerId }
        }
    }

    
}
