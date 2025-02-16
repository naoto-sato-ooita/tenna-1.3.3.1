//
//  SettingViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/04.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class SettingViewModel: ObservableObject {
    
    static let shared = SettingViewModel()
    @Published private(set) var user: User? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await UserService.shared.getUser(uid: authDataResult.uid)
    }
    
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await ImageManager.shared.saveImage(data: data, uid: user.uid ?? "")
            print("SUCCESS!")
            print(path)
            print(name)
            let url = try await ImageManager.shared.getUrlForImage(path: path)
            try await UserService.shared.updateUserProfileImagePath(uid: user.uid ?? "", path: path, url: url.absoluteString)
            try await self.loadCurrentUser()
        }
    }
    
    func deleteProfileImage() {
        guard let user, let path = user.path else { return }
        
        Task {
            try await ImageManager.shared.deleteImage(path: path)
            try await UserService.shared.updateUserProfileImagePath(uid: user.uid ?? "", path: nil, url: nil)
        }
    }
}
