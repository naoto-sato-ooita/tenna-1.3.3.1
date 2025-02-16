//
//  ImageManagerModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/05/19.
//
import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

final class ImageManager : ObservableObject {
    
    
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    @Published var imagePath: String = ""
    static let shared = ImageManager()
    private let storage = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    

    
    // Load image from PhotosPicker and prepare for upload
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        do {
            guard let imageData = try await item.loadTransferable(type: Data.self) else { return }

            
            // Compress and prepare image for upload
            DispatchQueue.main.async {
                // Store the image data or UI processing if needed
                // Now handled by AsyncImage directly
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    func uploadImage(uid: String) async throws -> URL? {
        guard let storeImage = selectedItem else { return nil }
        guard let imageData = try await storeImage.loadTransferable(type: Data.self) else { return nil }
        
        // Convert to UIImage to apply compression
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        // Compress the image to JPEG with compression quality 0.1
        guard let compressedImageData = uiImage.jpegData(compressionQuality: 0.1) else { return nil }
        
        do {
            // 既存の画像パスを取得
            let userRef = Firestore.firestore().collection("users").document(uid)
            let document = try await userRef.getDocument()
            
            // 新しい画像の参照を作成
            let newImagePath = "users/\(uid)/profile.jpeg"
            let storageRef = storage.child(newImagePath)
            
            // 既存画像の削除を試みる
            if let existingPath = document.data()?["path"] as? String {
                do {
                    try await storage.child(existingPath).delete()
                } catch {
                    print("Previous image deletion failed: \(error)")
                    // 削除に失敗しても続行
                }
            }
            // Upload the compressed image
            let metadata = try await retry(maxAttempts: 5, delay: 1.0) {
                try await storageRef.putDataAsync(compressedImageData, metadata: nil)
            }
            
            // Get the download URL for the image
            let imageURL = try await storageRef.downloadURL()
            
            // Save image path to Firestore
            try await saveImagePathToFirestore(uid: uid, path: metadata.path ?? "")
            
            return imageURL
        } catch {
            print("Image upload error: \(error)")
            return nil
        }
    }
    
    
    // Save image path to Firestore
    func saveImagePathToFirestore(uid: String, path: String) async throws {
        let userDoc = Firestore.firestore().collection("users").document(uid)
        do {
            try await userDoc.setData(["path": path], merge: true)
        } catch {
            print("Error saving image path to Firestore: \(error)")
        }
    }
    
    
    // Download image URL from Firestore and fetch image from Storage
    func downloadImage(uid: String) async throws -> URL? {
        let userDoc = Firestore.firestore().collection("users").document(uid)
        
        do {
            let document = try await userDoc.getDocument()
            guard let path = document.get("path") as? String else {
                print("No path found in document")
                return nil
            }
            
            let imageURL = try await storage.child(path).downloadURL()
            return imageURL
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }
    
    // Retry logic with exponential backoff
    private func retry<T>(maxAttempts: Int, delay: TimeInterval, task: @escaping () async throws -> T) async throws -> T {
        var attempts = 0
        var currentDelay = delay
        
        while attempts < maxAttempts {
            do {
                return try await task()
            } catch {
                attempts += 1
                if attempts >= maxAttempts {
                    throw error
                }
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= 2
            }
        }
        throw NSError(domain: "RetryErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Max retry attempts reached"])
    }
    
    
    
    func saveTipsImage(data: Data, tipId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await storage.child("tips_images").child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }

    
    //MARK: - Kanban
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(uid: String) -> StorageReference {
        storage.child("users").child(uid)
    }
    
    private func groupReference(uid: String) -> StorageReference {
        storage.child("groups").child(uid)
    }
    
    func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    func getData(uid: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024) //Modify
    }
    
    func getImage(uid: String, path: String) async throws -> UIImage {
        let data = try await getData(uid: uid, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    func saveImage(data: Data, uid: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(uid: uid).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    func saveGroupImage(data: Data, uid: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await groupReference(uid: uid).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    func saveImage(image: UIImage, uid: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, uid: uid)
    }
    
    func deleteImage(path: String) async throws {
        try await getPathForImage(path: path).delete()
    }
    
}


// StorageReference extensions for async handling
extension StorageReference {
    func putDataAsync(_ uploadData: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            self.putData(uploadData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "Unknown error", code: -1, userInfo: nil))
                }
            }
        }
    }
    
    func getDataAsync(maxSize: Int64) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "Unknown error", code: -1, userInfo: nil))
                }
            }
        }
    }
}
