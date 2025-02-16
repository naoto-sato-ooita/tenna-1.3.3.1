//
//  EntitlementManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/26.
//

import SwiftUI

//MARK: 購入情報を他のデバイスと共有
class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.your.app")!
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
    
}
