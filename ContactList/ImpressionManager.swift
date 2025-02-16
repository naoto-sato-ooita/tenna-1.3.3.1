//
//  ImpressionManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/05.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

final class ImpressionManager : ObservableObject {
    
    static let shared = ImpressionManager()
    
    @Published var impressionUsers: [User] = []
    @Published var impressionData:  [String: Any] = [:]
    
    private let storageURL = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    
    //MARK: - 追加
    
    func addImpression(selectedUserId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        //MARK: - 1 User情報を取得
        
        let locationRef = Firestore.firestore().collection("locations").document(currentUserId)
        locationRef.getDocument { document, error in
            
            guard let document = document, document.exists else { return }
            guard let data = document.data() else { return }
            guard let fullname = data["fullname"] as? String else { return }
            guard let latitude = data["lat"] as? Double else { return }
            guard let longitude = data["lng"] as? Double else { return }
            
            //MARK: - 2 住所、日付を取得、impressionDataを作成
            
            self.reverseGeocode(latitude: latitude, longitude: longitude) { address in
                guard let address = address else { return }
                print(address)
                let impressionData: [String: Any] = [
                    "uid" : currentUserId,
                    "fullname" : fullname,
                    "address" : address,
                    "timestamp" : Timestamp()
                ]
                
                //MARK: - 3 impressionData を collection("impressions")にアップロード
                self.addOrUpdateImpression(for: selectedUserId, impressionData: impressionData) { success in
                    if success {
                        print("Impression updated successfully")
                    } else {
                        print("Failed to update impression")
                    }
                }
                
                
            }
        }
    }
    
    //逆ジオコーディング関数
    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error reverse geocoding: \(error)")
                completion(nil)
            } else if let placemark = placemarks?.first {
                let address = [placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 } //nilを除去
                    .joined(separator: ", ") //,を入れて結合
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
    
    
    //アップロード関数
    func addOrUpdateImpression(for selectedUserId: String, impressionData: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let impressionRef = Firestore.firestore().collection("impressions").document(selectedUserId)
        
        impressionRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(false)
                return
            }
            
            var impressionList = [[String: Any]]()
            
            if let document = document, document.exists {
                if let existingImpressionList = document.get("impressionList") as? [[String: Any]] {
                    // 現在のユーザーからの既存のインプレッションを削除
                    impressionList = existingImpressionList.filter { ($0["fromUserId"] as? String) != currentUserId }
                }
            }
            
            // 新しいインプレッションを追加
            var newImpressionData = impressionData
            newImpressionData["fromUserId"] = currentUserId
            newImpressionData["timestamp"] = Timestamp(date: Date())
            impressionList.append(newImpressionData)
            
            impressionRef.setData(["impressionList": impressionList]) { error in
                if let error = error {
                    print("Error updating impressions: \(error)")
                    completion(false)
                } else {
                    print("Success updating impressions")
                    completion(true)
                }
            }
        }
    }

    
    //MARK: - いいね削除
    func removeImpression(selectedUserId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("impressions").document(currentUserId)
        
        docRef.getDocument { document, error in
            //中身を読み出し
            if let document = document, document.exists {
                guard var impressionList = document.get("impressionList") as? [[String: Any]] else { return }
                
                //選択ユーザーと合致するものを削除
                impressionList.removeAll { impression in
                    guard let impressionUID = impression["uid"] as? String else { return false }
                    return impressionUID == selectedUserId
                }
                
                //リスト更新
                docRef.updateData(["impressionList": impressionList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    //MARK: - load impressionList
    
//    func loadImpressions(uid: String) {
//
//        
//        let impressionRef = Firestore.firestore().collection("impressions").document(uid)
//        
//        impressionRef.getDocument { [weak self] document, error in
//            if let error = error {
//                print("Error fetching impressions: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let document = document,
//                    document.exists,
//                  let impressionData = document.data()?["impressionList"] as? [[String: Any]] else {
//                print("No impression data found for user: \(uid)")
//                return
//            }
//            
//
//            for impression in impressionData {
//                guard let uid = impression["uid"] as? String,
//                      let fullname = impression["fullname"] as? String,
//                      let address = impression["address"] as? String,
//                      let timestamp = impression["timestamp"] as? Timestamp else {
//                    print("Invalid impression data format")
//                    continue
//                }
//
//                self?.fetchUser(uid: uid) { user in
//                    if let user = user {
//                        var updatedUser = user
//                        updatedUser.fullname = fullname
//                        updatedUser.address = address
//                        updatedUser.timestamp = timestamp
//                        self?.impressionUsers.append(updatedUser)
//                        print(self?.impressionUsers ?? [])
//                    }
//                }
//            }
//        }
//    }
    func loadImpressions(uid: String) {
        let impressionRef = Firestore.firestore().collection("impressions").document(uid)
        
        Task { @MainActor in
            do {
                let document = try await impressionRef.getDocument()
                guard let impressionData = document.data()?["impressionList"] as? [[String: Any]] else { return }
                
                impressionUsers.removeAll()
                
                for impression in impressionData {
                    if let uid = impression["uid"] as? String,
                       let fullname = impression["fullname"] as? String,
                       let address = impression["address"] as? String,
                       let timestamp = impression["timestamp"] as? Timestamp {
                        
                        let userRef = Firestore.firestore().collection("users").document(uid)
                        let userDoc = try await userRef.getDocument()
                        if var user = try? userDoc.data(as: User.self) {
                            user.fullname = fullname
                            user.address = address
                            user.timestamp = timestamp
                            impressionUsers.append(user)
                        }
                    }
                }
                
                impressionUsers.sort { $0.timestamp?.dateValue() ?? Date() > $1.timestamp?.dateValue() ?? Date() }
            } catch {
                print("Error loading impressions: \(error)")
            }
        }
    }
    


    //ユーザー情報取得関数
    private func fetchUser(uid: String, completion: @escaping (User?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { document, error in
            guard let document = document, document.exists else {
                completion(nil)
                return
            }
            let user = try? document.data(as: User.self)
            completion(user)
        }
    }
    

}
