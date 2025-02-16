//
//  ContentView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/14.
//
import Foundation
import UIKit
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authviewModel : AuthManager
    
    @State private var isSearch = true
    @State var timerOngoing: Bool = false
    @State var isPremium: Bool = false
    @State private var showTermsOfService = false
    @State private var showTip : Bool = false
    private let termsManager = TermsAgreementManager()
    
    var body: some View {
        
        if authviewModel.userSession != nil {
            
            ZStack {
                Color.clear.edgesIgnoringSafeArea(.all)
                MapView(isSearch: $isSearch, user: UserService.shared.currentUser ?? User.MOCK_USER)
                    .onAppear {
                        if !termsManager.hasTip() { //本番は！つける
                            showTip = true
                        }
                    }
                    .fullScreenCover(isPresented: $showTip) {
                        TipLandingView(showTip: $showTip,isSearch: $isSearch){
                            termsManager.setTip()
                        }
                    }
            }

        }
        
        else {
            LandingView()
                .onAppear {
                    if !termsManager.hasAgreedToTerms() { //本番は！つける
                        showTermsOfService = true
                    }
                }
                .fullScreenCover(isPresented: $showTermsOfService) {
                    TermsOfServiceView(showTooltip: $showTermsOfService) {
                        termsManager.setTermsAgreed()
                    }
                }
        }
    }
//    for DEBUG
//    private func checkTerms() async {
//        if termsManager.hasTip() {
//            showTip = true
//        }
//    }
//    
//    private func checkTermsOfService() async {
//        if !termsManager.hasAgreedToTerms() {
//            showTermsOfService = true
//        }
//    }
}


final class TermsAgreementManager {
    private let termsAgreedKey = "termsAgreed"
    private let maptip = "mapTip"
    
    // Check if the terms have been agreed to
    func hasAgreedToTerms() -> Bool {
        return UserDefaults.standard.bool(forKey: termsAgreedKey)
    }
    
    // Mark the terms as agreed
    func setTermsAgreed() {
        UserDefaults.standard.set(true, forKey: termsAgreedKey)
    }
    
    func hasTip() -> Bool {
        return UserDefaults.standard.bool(forKey: maptip)
    }
    func setTip() {
        UserDefaults.standard.set(true, forKey: maptip)
    }
}
