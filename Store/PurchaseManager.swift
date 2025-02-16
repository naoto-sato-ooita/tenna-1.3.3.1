//
//  PurchaseManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/26.
//

import Foundation
import StoreKit

//MARK: 購入とトランザクションを処理

@MainActor
final class PurchaseManager: NSObject, ObservableObject {
    
    //MARK: 製品データの取得
    private let productIds = ["Premium", "Popcorn_service"]
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var isPremium = false
    @Published var isPopcorn = false
    
    private let entitlementManager: EntitlementManager
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    //MARK: 製品データを取得する処理
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        print("Loading products...")
        self.products = try await Product.products(for: productIds) //製品データの取得
        self.productsLoaded = true
        print("Products loaded: \(self.products.map { $0.displayName })")
    }
    
    //MARK: 購入の処理を開始
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        //MARK: 購入処理結果の検証
        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            await self.updatePurchasedProducts() //購入成功で更新
            UserDefaults.standard.set("", forKey: "lastLoginDate")
            CountManager.shared.ResetHandler(limit: 30)
        case .success(.unverified):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    //MARK: アプリの起動時、購入後、トランザクション更新時に購入状況を取得
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID) //失効してたら購入済から削除する
            }
        }

        self.isPopcornObserve()
        self.isPremiumObserve()
        self.entitlementManager.hasPro = !self.purchasedProductIDs.isEmpty


    }
    
    //MARK: 外部トランザクションの監視(アプリ外での更新や解約、購入失敗)
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }

    func isPremiumObserve() {
        self.isPremium = self.purchasedProductIDs.contains("Premium")
    }
    
    func isPopcornObserve() {
        self.isPopcorn = self.purchasedProductIDs.contains("Popcorn_service")
    }
    
}

//MARK: App Storeアプリからのアプリ内課金の購入に対応する
extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
