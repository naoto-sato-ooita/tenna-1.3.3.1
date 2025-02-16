//
//  User.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct User: Identifiable, Codable ,Hashable{
    
    @DocumentID var uid: String?
    var fullname: String?
    let email: String?
    let fcmToken: String?
    
    let path: String?
    let pathUrl: String?
    let latitude: String?
    let longitude : String?
    
    var profile: String?
    var address: String?
    var timestamp: Timestamp?
    let impressionList: [String]?
    let requestList: [String]?
    let friendList: [String]?
    let blockList: [String]?
    let isPremium: Bool?
    var id:String { return uid ?? NSUUID().uuidString }
    var bookmarkedGroups: [String]?
    var bookmarkedTips: [String]?
    
    init(auth: AuthDataResultModel) {
        self.uid = auth.uid
        self.fullname = nil
        self.email = auth.email
        self.fcmToken = nil
        self.path = nil
        self.pathUrl = nil
        self.latitude = nil
        self.longitude = nil
        self.profile = nil
        self.address = nil
        self.timestamp = nil
        self.impressionList = nil
        self.requestList = nil
        self.friendList = nil
        self.blockList = nil
        self.isPremium = false
        self.bookmarkedGroups = nil
        self.bookmarkedTips = nil
    }
    
    init(
        uid: String? = nil,
        fullname: String? = nil,
        email: String? = nil,
        fcmToken: String? = nil,
        comment: String? = nil,
        path: String? = nil,
        pathUrl : String? = nil,
        latitude: String? = nil,
        longitude: String? = nil,
        geoPoint: String? = nil,
        profile: String? = nil,
        address: String? = nil,
        timestamp: Timestamp? = nil,
        impressionList: [String]? = nil,
        requestList: [String]? = nil,
        friendList: [String]? = nil,
        blockList: [String]? = nil,
        isPremium: Bool? = nil,
        bookmarkedGroups: [String]? = nil,
        bookmarkedTips: [String]? = nil
    ) {
        self.uid = uid
        self.fullname = fullname
        self.email = email
        self.fcmToken = fcmToken
        self.path = path
        self.pathUrl = pathUrl
        self.latitude = latitude
        self.longitude = longitude
        self.profile = profile
        self.address = address
        self.timestamp = timestamp
        self.impressionList = impressionList
        self.requestList = requestList
        self.friendList = friendList
        self.blockList = blockList
        self.isPremium = isPremium
        self.bookmarkedGroups = bookmarkedGroups
        self.bookmarkedTips = bookmarkedTips
    }
    
    init(id: String) {
        self.uid = id
        self.fullname = nil
        self.email = nil
        self.fcmToken = nil
        self.path = nil
        self.pathUrl = nil
        self.latitude = nil
        self.longitude = nil
        self.profile = nil
        self.address = nil
        self.timestamp = nil
        self.impressionList = nil
        self.requestList = nil
        self.friendList = nil
        self.blockList = nil
        self.isPremium = nil
        self.bookmarkedGroups = nil
        self.bookmarkedTips = nil
    }
    
    init(from document: DocumentSnapshot) {
        uid = document["uid"] as? String
        fullname = document["fullname"] as? String
        fcmToken = document["fcmToken"] as? String
        pathUrl = document["pathUrl"] as? String
        profile = document["profile"] as? String
        address = document["address"] as? String
        timestamp = document["timestamp"] as? Timestamp
        path = nil
        latitude = nil
        longitude = nil
        email = nil
        impressionList = nil
        requestList = nil
        friendList = nil
        blockList = nil
        isPremium = nil
        bookmarkedGroups = nil
        bookmarkedTips = nil
    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname ?? ""){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: fullname ?? "")
        return components?.givenName ?? ""
    }
}

extension User {
    static var MOCK_USER = User(fullname: "Now Loading", email: "sample@mail.com")
}

struct Topic: Identifiable, Codable, Hashable {
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: String
    let name: String
    let creatorId: String
    var members: [String]
    let region: String
    let createdAt: Date
    let numberOfFav: Int
    var memberCount: Int {
        return members.count
    }
    var annotations: [RouteAnnotation]
    let timestamp: Timestamp?
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "creatorId": creatorId,
            "members": members,
            "memberCount": memberCount,
            "region": region,
            "createdAt": createdAt,
            "numberOfFav": numberOfFav,
            "timestamp": FieldValue.serverTimestamp(),
            "annotations": annotations.map { annotation in
                [
                    "id": annotation.id,
                    "title": annotation.title,
                    "imageUrl": annotation.imageUrl,
                    "latitude": annotation.latitude,
                    "longitude": annotation.longitude,
                    "orders": annotation.orders,
                    "timestamp": FieldValue.serverTimestamp()
                ]
            }
        ]
    }
}

struct Tips: Identifiable, Codable ,Equatable{
    let id: String
    let content: String
    let creatorId: String
    var imagePath: String?
    var likeCount: Int
    let createdAt: Date
    let lat: Double
    let lng: Double
    let geoHash: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "content": content,
            "creatorId": creatorId,
            "imagePath": imagePath ?? "",
            "likeCount": likeCount,
            "createdAt": createdAt,
            "lat": lat,
            "lng": lng,
            "geoHash": geoHash
        ]
    }
}

extension Topic {
    init(from data: [String: Any]) throws {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.creatorId = data["creatorId"] as? String ?? ""
        self.members = data["members"] as? [String] ?? []
        self.region = data["region"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.numberOfFav = data["numberOfFav"] as? Int ?? 0
        self.timestamp = data["timestamp"] as? Timestamp
        
        if let annotationsData = data["annotations"] as? [[String: Any]] {
            self.annotations = annotationsData.map { annotationData in
                RouteAnnotation(
                    id: annotationData["id"] as? String ?? UUID().uuidString,
                    title: annotationData["title"] as? String ?? "",
                    imageUrl: annotationData["imageUrl"] as? String ?? "",
                    latitude: annotationData["latitude"] as? Double ?? 0.0,
                    longitude: annotationData["longitude"] as? Double ?? 0.0,
                    orders: annotationData["orders"] as? [Int] ?? [0]
                    //timestamp不要？
                )
            }
        } else {
            self.annotations = []
        }
    }
}

extension Tips {
    init(from data: [String: Any]) throws {
        self.id = data["id"] as? String ?? ""
        self.content = data["content"] as? String ?? ""
        self.creatorId = data["creatorId"] as? String ?? ""
        self.imagePath = data["imagePath"] as? String
        self.likeCount = data["likeCount"] as? Int ?? 0
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lat = data["lat"] as? Double ?? 0
        self.lng = data["lng"] as? Double ?? 0
        self.geoHash = data["geoHash"] as? String ?? ""
    }
}
