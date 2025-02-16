//
//  AuthenticationViewModel.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/07/17.
//

import SwiftUI
import FirebaseAuth
import Combine
import AuthenticationServices

@MainActor
final class AuthenticationViewModel: ObservableObject {
    

    var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSignedIn = false
    @Published var isAppleSignInUser = false

    
    @MainActor
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthManager.shared.signInWithApple(tokens: tokens)
        user = try await UserService.shared.createNewUser(uid: authDataResult.uid,email: authDataResult.email)
        AuthManager.shared.loadCurrentUserData()  // ユーザー情報を再読み込み
    }
    
    // Appleのユーザー名を変更するメソッド
    @MainActor
    func updateAppleUserName(newName: String) async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        
        try await AuthManager.shared.editUserName(credential: credential, newName: newName)
        try await AuthManager.shared.saveNameFirestore(fullname: newName)
        AuthManager.shared.loadCurrentUserData()  // ユーザー情報を再読み込み
    }
    
    // メールサインインユーザーのユーザー名を変更するメソッド
    @MainActor
    func updateEmailUserName(email: String, password: String, newName: String) async throws {
        try await AuthManager.shared.editUserNameWithEmail(email: email, password: password, newName: newName)
        try await AuthManager.shared.updateEmail(email: email)
        try await AuthManager.shared.updatePassword(password: password)
        try await AuthManager.shared.saveNameFirestore(fullname: newName)
        AuthManager.shared.loadCurrentUserData()  // ユーザー情報を再読み込み
    }
    
}
