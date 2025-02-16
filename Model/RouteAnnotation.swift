//
//  RouteAnnotation.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/02/05.
//

import CoreLocation
import MapKit

struct RouteAnnotation: Identifiable, Codable {
    let id: String
    let title: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    var orders: [Int]
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl
        case latitude
        case longitude
        case orders
    }
}

extension RouteAnnotation {
    init(from data: [String: Any]) throws {
        self.id = data["id"] as? String ?? UUID().uuidString
        self.title = data["title"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.latitude = data["latitude"] as? Double ?? 0.0
        self.longitude = data["longitude"] as? Double ?? 0.0
        self.orders = data["orders"] as? [Int] ?? []
    }
}
