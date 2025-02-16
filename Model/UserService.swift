
//
//  UserService.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/03/26.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

final class UserService : ObservableObject {
    static let shared = UserService()
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    @Published var currentUser: User?

    
    
    private init() { }
    
    
    private func userDocument(uid: String) -> DocumentReference {
        userCollection.document(uid)
    }
    
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    func createNewUser(user: User) async throws {
        try userDocument(uid: user.uid ?? "").setData(from: user, merge: false)
    }
    
    func getUser(uid: String) async throws -> User {
        try await userDocument(uid: uid).getDocument(as: User.self)
    }


    
    func updateUserProfileImagePath(uid: String, path: String?, url: String?)  async throws{
        let storeURL = Firestore.firestore().collection("users").document(uid)
        
        do {
            try await storeURL.setData(["path": path ?? "","pathUrl": url ?? ""],merge: true)
        } catch {
            print("Error saving image path to Firestore: \(error)")
        }
    }
    
    //追加：
    func updateGroupPath(groupId: String, groupPath: String?) async throws{
        let storeURL = Firestore.firestore().collection("groups").document(groupId)
        
        do {
            try await storeURL.setData(["groupPath": groupPath ?? ""],merge: true)
        } catch {
            print("Error saving image path to Firestore: \(error)")
        }
    }
    func updateUserProfile(uid: String, profile: String?) async throws{
        let storeURL = Firestore.firestore().collection("users").document(uid)
        
        do {
            try await storeURL.setData(["profile": profile ?? ""],merge: true)
        } catch {
            print("Error saving image path to Firestore: \(error)")
        }
    }
    //ユーザー読み込み
    func fetchUsers(with ids: [String]) async -> [User] {
        let userRefs = ids.map { Firestore.firestore().collection("users").document($0) }
        var users: [User] = []
        
        for userRef in userRefs {
            do {
                let document = try await userRef.getDocument()
                let user = try document.data(as: User.self)
                users.append(user)
                
            } catch {
                print("Error fetching user: \(error)")
            }
        }
        return users
    }
    //currentUserの情報取得
    func fetchUser() async throws{
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await  Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    static func fetchChatUser(uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            completion(user)
        }
    }
    
    
    static func SendRequest(from_uid:String,to_uid:String) async throws{
        let sendURL = Firestore.firestore().collection("users").document(to_uid)
        do {
            try await sendURL.setData(["requestList": from_uid],merge: true)
        }
        catch { print("Error send request: \(error)") }
    }
    
    
    static func fetchRequest(withUid uid: String, limit: Int? = nil) async throws -> [User] {
        let query = Firestore.firestore().collection("users").document(uid).collection("requestLists")
        if let limit { query.limit(to: limit) }
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap( {try? $0.data(as: User.self) } )
    }
    
    func createNewUser(uid: String,email: String?) async throws -> User {
        
        let newUser = User(uid: uid, email: email ?? "")
        // Firestoreへの保存処理など
        try await saveUserToFirestore(user: newUser)
        currentUser = newUser
        return newUser
    }
    
    private func saveUserToFirestore(user: User) async throws {
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(user.uid ?? "").setData((encodedUser), merge: true)
    }
    
    
    func fetchSelectUser(uid: String) async throws -> User? {
        do {
            let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if document.exists {
                return User(from: document)
            } else {
                print("No such document")
                return nil
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            throw error
        }
    }
    func savePreference(uid: String ,category: String, preference: String) {
        guard !preference.isEmpty else { return }
        
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "category": category,
            "preference": preference
        ]
        
        db.collection("users").document(uid).updateData([
            "preferences": FieldValue.arrayUnion([data])
        ]) { error in
            if let error = error {
                print("Error saving preference: \(error.localizedDescription)")
            } else {
                print("Preference saved successfully!")
                
            }
        }
    }
    
    func fetchPreferences(uid: String) async -> [[String: String]]? {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if let data = document.data() {
                return data["preferences"] as? [[String: String]]
            } else {
                print("Document has no data.")
                return nil
            }
        } catch {
            print("Error fetching preferences: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deletePreference(uid: String, at offsets: IndexSet, preferences: Binding<[[String: String]]>) {
        guard let index = offsets.first else { return }
        let preferenceToDelete = preferences.wrappedValue[index]
        
        // Firestoreからデータを削除
        let db = Firestore.firestore()
        
        Task {
            do {
                let userRef = db.collection("users").document(uid)
                try await userRef.updateData([
                    "preferences": FieldValue.arrayRemove([preferenceToDelete])
                ])
                
                // 削除後にローカルのリストからも削除（メインスレッドで実行）
                DispatchQueue.main.async {
                    preferences.wrappedValue.remove(atOffsets: offsets)
                }
            } catch {
                print("Error deleting preference: \(error.localizedDescription)")
            }
        }
    }
}
