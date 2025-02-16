//
//  AdMobBannerView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/12/10.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)

        //テスト広告ID
        //banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        //本番広告ID
        banner.adUnitID = "ca-app-pub-9520175546098083/2722761090"
        
        //本番アプリID ca-app-pub-9520175546098083~6252411171　これinfo-plist
        //テストアプリID ca-app-pub-3940256099942544~1458002511
        
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner // 最終的にインスタンスを返す
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 特にないのでメソッドだけ用意
    }
}
