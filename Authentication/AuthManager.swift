//
//  AuthManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//


import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage
import AuthenticationServices

protocol AuthenticationFormProtocol {
    var formisValid: Bool { get }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}


final class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    private let authRef = Auth.auth()
    private let storeRef = Firestore.firestore().collection("users")
    private let storage = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    
    private init() {
        self.userSession = authRef.currentUser
        loadCurrentUserData()
    }
    
    @Published var userSession: Firebase.User?
    @Published var currentUser: User?
    
    
    //MARK: - 現在ユーザーの更新 loadCurrentUserDataから名称と戻り値変更
    func getAuthenticatedUser()  throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(firebaseUser: user,path: "",fullname: "")
    }
    
    //MARK: - 現在ユーザーの更新
    func loadCurrentUserData() {
        Task {
            try await UserService.shared.fetchUser()
        }
    }
    
    //MARK: - ユーザーデータの更新
    private func uploadUserData(email: String, fullname: String, id: String) async throws {
        let user = User(fullname: fullname, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await storeRef.document(id).setData(encodedUser)
    }
    
    
    //MARK: - プロバイダー
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    //MARK: - プロバイダー共通
    
    func signOut() throws {
        
        do {
            try authRef.signOut()
            DispatchQueue.main.async {
                self.userSession = nil
                UserService.shared.currentUser = nil
                self.loadCurrentUserData()
            }
        }
        catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let uid = user.uid // uid is already a String
        
        // Get user's image path from Firestore
        let userDoc = try await Firestore.firestore().collection("users").document(uid).getDocument()
        if let imagePath = userDoc.data()?["path"] as? String {
            // Delete image from Storage
            try await storage.child(imagePath).delete()
        }
        // Firestoreからユーザーデータを削除
        let batch = Firestore.firestore().batch()
        
        // users collection
        let userRef = Firestore.firestore().collection("users").document(uid)
        batch.deleteDocument(userRef)
        
        // groups collection - ユーザーが所属するグループから削除
        let groupsRef = Firestore.firestore().collection("groups")
        let groups = try await groupsRef.whereField("members", arrayContains: uid).getDocuments()
        for group in groups.documents {
            batch.updateData(["members": FieldValue.arrayRemove([uid])], forDocument: group.reference)
        }
        
        // geoInfo collection
        let geoRef = Firestore.firestore().collection("locations").document(uid)
        batch.deleteDocument(geoRef)
        
        // バッチ処理を実行
        try await batch.commit()
        
        // Authenticationのアカウントを削除
        try await user.delete()
        
        DispatchQueue.main.async {
            self.userSession = nil
            UserService.shared.currentUser = nil
            self.loadCurrentUserData()
        }
    }
    
}


// MARK: - SIGN IN EMAIL

extension AuthManager {
    
    @MainActor
    func createUser(email: String, password: String, fullname: String) async throws {
        do {
            let result = try await authRef.createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Firestoreへのデータ保存を修正
            let user = User(fullname: fullname, email: email)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            
            self.loadCurrentUserData()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    @MainActor
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await authRef.signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.loadCurrentUserData()
        } catch let error as NSError {
            let authError: AuthError = {
                switch error.code {
                case AuthErrorCode.invalidEmail.rawValue:
                    return .invalidEmail
                case AuthErrorCode.wrongPassword.rawValue:
                    return .wrongPassword
                case AuthErrorCode.networkError.rawValue:
                    return .networkError
                case AuthErrorCode.userNotFound.rawValue:
                    return .userNotFound
                case AuthErrorCode.tooManyRequests.rawValue:
                    return .tooManyRequests
                default:
                    return .unknown
                }
            }()
            throw authError
        }
    }
    
    
    func sendPasswordReset(email: String) async throws {
        do {
            try await authRef.sendPasswordReset(withEmail: email)
        }
        catch{
            print("DEBUG: Failed to send a email")
        }
    }
    
    
    func updatePassword(password: String) async throws {
        guard let user = authRef.currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
    func saveNameFirestore(fullname:String) async throws{
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let storeRef = Firestore.firestore().collection("users").document(currentUid)
        
        do {
            try await storeRef.setData(["fullname": fullname],merge: true)
        } catch {
            print("Error saving name to Firestore: \(error)")
        }
    }
    
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let fullname: String?
    let path: String?
    
    init(firebaseUser: Firebase.User, path: String?,fullname: String?) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.path = path
        self.fullname = fullname
    }
}


extension AuthManager {
    
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        let result = try await authRef.signIn(with: credential)
        
        // Fetch the path from Firestore
        let path = try await fetchUserPath(uid: result.user.uid)
        let fullname = try await fetchUserFullname(uid: result.user.uid)
        
        let authDataResult = AuthDataResultModel(firebaseUser: result.user, path: path, fullname: fullname)
        DispatchQueue.main.async {
            self.userSession = result.user
            self.loadCurrentUserData()
        }
        return authDataResult
    }
    
    private func fetchUserPath(uid: String) async throws -> String? {
        let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return document.data()?["path"] as? String
    }
    
    private func fetchUserFullname(uid: String) async throws -> String? {
        let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return document.data()?["fullname"] as? String
    }
    
    // ユーザー名を変更するメソッド
    func editUserName(credential: AuthCredential, newName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        // 再認証
        try await user.reauthenticate(with: credential)
        
        // プロフィールの更新
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        try await changeRequest.commitChanges()
    }
    
    // メールサインインユーザーのユーザー名を変更するメソッド
    func editUserNameWithEmail(email: String, password: String, newName: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await editUserName(credential: credential, newName: newName)
        
    }
    
    func handleAppleSignIn(result: ASAuthorization) {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            // Handle error
            return
        }
        
        let userIdentifier = appleIDCredential.user
        let identityToken = appleIDCredential.identityToken
        let authorizationCode = appleIDCredential.authorizationCode
        
        // Convert identityToken to a string
        guard let token = identityToken else { return }
        let tokenString = String(data: token, encoding: .utf8)
        
        // Authenticate with Firebase
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString!, rawNonce: nil)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase sign in with Apple failed: \(error.localizedDescription)")
                return
            }
            // User is signed in to Firebase
            
        }
    }
    
    func isAppleSignInUser() -> Bool {
        do {
            let providers = try getProviders()
            return providers.contains(.apple)
        } catch {
            print("DEBUG: Failed to get providers with error \(error.localizedDescription)")
            return false
        }
    }
}


enum AuthError: Error {
    case invalidEmail
    case wrongPassword
    case networkError
    case userNotFound
    case tooManyRequests
    case unknown
    
    var description: String {
        switch self {
        case .invalidEmail:
            return "Invalid email format"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network connection error"
        case .userNotFound:
            return "User not found"
        case .tooManyRequests:
            return "Too many attempts. Please try again later"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
