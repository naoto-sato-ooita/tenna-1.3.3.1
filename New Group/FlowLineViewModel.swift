//
//  FlowLineViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/02/06.
//


import Firebase

class FlowLineViewModel: ObservableObject {
    
    static let shared = FlowLineViewModel()
    @Published var annotations: [RouteAnnotation] = [] // 現在選択しているルートアノテーション
    
    func hasExistingFlowLine(userId: String) async -> Bool {
        let db = Firestore.firestore()
        let flowLineRef = db.collection("flowline").document(userId)
        
        do {
            let document = try await flowLineRef.getDocument()
            return document.exists && document.data()?["annotations"] != nil
        } catch {
            print("Error checking flowline: \(error)")
            return false
        }
    }
    //　"flowline"を保存
    func saveFlowLine(userId: String, orderedAnnotations: [RouteAnnotation]) async throws {
        let db = Firestore.firestore()
        let flowLineRef = db.collection("flowline").document(userId)
        
        // Create orders map for each annotation
        var annotationOrders: [String: [Int]] = [:]
        for (index, annotation) in orderedAnnotations.enumerated() {
            if var orders = annotationOrders[annotation.id] {
                orders.append(index)
                annotationOrders[annotation.id] = orders
            } else {
                annotationOrders[annotation.id] = [index]
            }
        }
        
        // Create final annotation data
        let annotationsData = annotations.map { annotation in
            [
                "id": annotation.id,
                "title": annotation.title,
                "imageUrl": annotation.imageUrl,
                "latitude": annotation.latitude,
                "longitude": annotation.longitude,
                "orders": annotationOrders[annotation.id] ?? []
            ]
        }
        
        try await flowLineRef.setData(["annotations": annotationsData])
    }
//    func saveFlowLine(userId: String, orderedAnnotations: [RouteAnnotation]) async throws {
//        let db = Firestore.firestore()
//        let flowLineRef = db.collection("flowline").document(userId)
//        
//        let annotationsData = orderedAnnotations.enumerated().map { index, annotation in
//            [
//                "id": annotation.id,
//                "title": annotation.title,
//                "imageUrl": annotation.imageUrl,
//                "latitude": annotation.latitude,
//                "longitude": annotation.longitude,
//                "order": index
//            ]
//        }
//        
//        try await flowLineRef.setData(["annotations": annotationsData])
//    }

    //新規作成を取得
    func fetchAnnotations(for topicId: String) async {
        let annotationsRef = Firestore.firestore()
            .collection("groups")
            .document(topicId)
            .collection("annotations")
        
        do {
            let snapshot = try await annotationsRef.getDocuments()
            await MainActor.run {
                self.annotations = snapshot.documents.compactMap { document in
                    try? RouteAnnotation(from: document.data())
                }
            }
        } catch {
            print("Error fetching annotations: \(error)")
        }
    }
    //作成済みを取得
    func loadFlowLine(userId: String) async {
        let flowLineRef = Firestore.firestore()
            .collection("flowline")
            .document(userId)
        
        do {
            let document = try await flowLineRef.getDocument()
            if let data = document.data(),
               let annotationsData = data["annotations"] as? [[String: Any]] {
                await MainActor.run {
                    self.annotations = annotationsData.compactMap { data in
                        guard let id = data["id"] as? String,
                              let title = data["title"] as? String,
                              let imageUrl = data["imageUrl"] as? String,
                              let latitude = data["latitude"] as? Double,
                              let longitude = data["longitude"] as? Double,
                              let orders = data["orders"] as? [Int] else {
                            return nil
                        }
                        
                        return RouteAnnotation(
                            id: id,
                            title: title,
                            imageUrl: imageUrl,
                            latitude: latitude,
                            longitude: longitude,
                            orders: orders
                        )
                    }
                }
            }
        } catch {
            print("Error loading flowline: \(error)")
        }
    }
    
    
    // 削除用 Viewに残るからこれを作り直すところから
    func deleteFlowLine(userId: String) async throws {
        let db = Firestore.firestore()
        let flowLineRef = db.collection("flowline").document(userId)
        
        try await flowLineRef.delete()
        
        await MainActor.run {
            self.annotations.removeAll()
            //何がしか履歴残って再Editできない
        }
        
    }
    
    
    // Test data creation
    // Test data creation
    func createTestData(topicId: String) async {
        let annotationsRef = Firestore.firestore()
            .collection("groups")
            .document(topicId)
            .collection("annotations")
        
        let testAnnotations = [
            RouteAnnotation(
                id: UUID().uuidString,
                title: "Main Stage",
                imageUrl: "https://example.com/main.jpg",
                latitude: 35.6812,
                longitude: 139.7671,
                orders: [0]
            ),
            RouteAnnotation(
                id: UUID().uuidString,
                title: "Food Area",
                imageUrl: "https://example.com/food.jpg",
                latitude: 35.6815,
                longitude: 139.7675,
                orders: [1]
            )
        ]
        
        for annotation in testAnnotations {
            try? await annotationsRef.document(annotation.id).setData([
                "id": annotation.id,
                "title": annotation.title,
                "imageUrl": annotation.imageUrl,
                "latitude": annotation.latitude,
                "longitude": annotation.longitude,
                "orders": annotation.orders
            ])
        }
    }

}
