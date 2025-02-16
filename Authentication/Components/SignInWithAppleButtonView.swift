//
//  SignInWithAppleButtonView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/07/18.
//

import SwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices

struct SignInWithAppleButtonView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var errorMessage: String?
    @Binding var isAppleSignIn : Bool
    
    var body: some View {
        VStack {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { authResults in
                    switch authResults {
                    case .success(let authResults):
                        authManager.handleAppleSignIn(result: authResults)
                        isAppleSignIn = true

                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        print("Sign in with Apple errored: \(error)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 280, height: 60)
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
    }
}
