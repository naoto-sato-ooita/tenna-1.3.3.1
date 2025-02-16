//
//  Tenna2App.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/11.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct Tenna2App: App {
    
    @StateObject private var authviewModel = AuthManager.shared
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var purchaseManager: PurchaseManager
    
    @State var showSplashScreen = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplashScreen {
                    SplashScreenView(showSplashScreen: $showSplashScreen)
                    
                }  else {
                    ContentView()
                        .environmentObject(authviewModel)
                        .environmentObject(entitlementManager)
                        .environmentObject(purchaseManager)
                        .task {
                            await purchaseManager.updatePurchasedProducts()
                        }
                }
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            
            //Notify
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            
            //AdMob
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            
            //Push通知許可のポップアップ表示
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
            
            //try? Tips.resetDatastore()
        }
        return true
        
    }
}


extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //通知の受信処理
        if let messageID = userInfo["gcm.message_id"] {
            print("MessageID: \(messageID)")
        }
        print(userInfo)
        completionHandler(.newData)
    }
    
    // アプリがForeground時にPush通知を受信する処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // アプリ起動時にFCM Tokenを取得、その後RDBのusersツリーにTokenを保存
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        if let uid = Auth.auth().currentUser?.uid {
            setFcmToken(uid: uid, fcmToken: fcmToken)
        }
    }
    
    func setFcmToken(uid: String, fcmToken: String) {
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.updateData(["fcmToken":fcmToken])
    }
    
}

//シミュレーターテスト用
extension AppDelegate: MessagingDelegate {
    
    //    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    //        Messaging.messaging().token { token, error in
    //            if let error = error {
    //                print("Error fetching FCM registration token: \(error)")
    //            } else if let token = token {
    //                print("FCM registration token: \(token)")
    //            }
    //        }
    //    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
//タップ後の処理を気記述
//extension AppDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        // Handle notification tap and perform actions like navigating to a specific view
//        completionHandler()
//    }
//}
