//
//  PurchaseView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/26.
//

import SwiftUI
import StoreKit
import SafariServices

struct PurchaseView: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) var openURL
    @Environment (\.dismiss) var dismiss
    
    @State private var isPrivacy : Bool = false
    @State private var isTerms : Bool = false
    
    let privacyPolicyUrl : String = "https://docs.google.com/document/d/1P5hTtGiMAos1cwtwL2-1aNxjrPg6qNAePQaU7FYT1zI/"
    let termsUrl : String = "https://docs.google.com/document/d/1ZJoxYaDdZ8AKtN7GyuuuiXxBsPh7P24XXEJh0v1zPfc/edit"
    @State private var url: URL? = nil
    private let font_color = Color.black
    
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top) {
                BackgroundView()
                
                
                VStack{
                    Divider().background(.white)
                    
                    ScrollView {
                        LazyVStack(alignment: .center){
                            
                            //MARK: - 製品1
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .fill(.clear)
                                    .frame(width:UIScreen.main.bounds.width - 40)
                                
                                VStack{
                                    Text("Additional Popcorn Pack")
                                        .font(.custom(fontx, size: 24))
                                    Text("(One-time purchase)")
                                        .font(.title3)
                                    if purchaseManager.isPopcorn {
                                        ZStack {
                                            Image("Pop1") //製品イメージ
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100,height: 100)
                                                .opacity(0.2)
                                            
                                            Text("Thanks!")
                                                .font(.custom(fontx, size: 30))
                                                .foregroundStyle(font_color)
                                                .fontWeight(.heavy)
                                        }
                                        .padding(.bottom,10)
                                    } else {
                                        Image("Pop1") //製品イメージ
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100,height: 100)
                                            .padding(.bottom,10)
                                    }
                                    
                                    HStack{
                                        Image(systemName: "popcorn")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25,height: 25)
                                        
                                        Text("Popcorn : 10/day.")
                                            .font(.footnote)
                                        
                                        Image(systemName:"arrowshape.right.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20,height: 20)
                                        
                                        Text("30/day!")
                                            .font(.title3)
                                    }
                                    .fontWeight(.heavy)
                                }
                                .padding()
                            }
                            .padding(.bottom,10)
                            

                            
                            //MARK: - 製品2
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .fill(.clear)
                                    .frame(width:UIScreen.main.bounds.width - 40)
                                
                                VStack(alignment: .center){
                                    
                                    Text("Tuner Upgrade Pack")
                                        .font(.custom(fontx, size: 24))
                                    Text("(Monthly subscription)")
                                        .font(.title3)
                                    
                                    if purchaseManager.isPremium {
                                        ZStack {
                                            Image("ante") //製品イメージ
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100,height: 100)
                                                .opacity(0.2)
                                            
                                            Text("Thanks!")
                                                .font(.custom(fontx, size: 30))
                                                .fontWeight(.heavy)
                                        }
                                        .padding(.bottom,10)
                                    } else {
                                        Image("ante") //製品イメージ
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100,height: 100)
                                            .padding(.bottom,10)
                                    }
                                    
                                    VStack(alignment: .leading,spacing: 10){
                                        HStack{
                                            Image(systemName: "antenna.radiowaves.left.and.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25,height: 25)
                                            Text("Expand search radius : 300m")
                                                .font(.footnote)
                                            Image(systemName:"arrowshape.right.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20,height: 20)
                                            Text("1000m!")
                                                .font(.title3)
                                        }
                                        .fontWeight(.heavy)
                                        
                                        
                                        
                                        HStack{
                                            Image(systemName: "flame")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25,height: 25)
                                            Text("Display topics : Max3")
                                                .font(.footnote)
                                            
                                            Image(systemName:"arrowshape.right.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20,height: 20)
                                            
                                            Text("Max 10!")
                                                .font(.title3)
                                            
                                        }
                                        .fontWeight(.heavy)
                                        
                                        HStack{
                                            Image(systemName: "sparkles")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25,height: 25)
                                            Text("Ad-free")
                                                .font(.title3)
                                        }
                                        .fontWeight(.heavy)
                                    }
                                }
                                .padding()
                            }
                            .padding(.bottom,10)

                            
                            Text("Purchase here")
                                .font(.title2)
                                .fontWeight(.heavy)
                            
                            
                            ForEach(purchaseManager.products) { product in
                                Button {
                                    _ = Task<Void, Never> {
                                        do {
                                            try await purchaseManager.purchase(product)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    VStack(spacing: 4){
                                        Text("\(product.displayName)")
                                            .font(.title)
                                            .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                                        
                                        Text("\(product.displayPrice)")
                                            .font(.title)
                                            .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                                    }
                                }
                                .foregroundStyle(.white)
                                .background(sw_pos)
                                .clipShape(Capsule())
                                .padding()
                                
                            }
                            
                            VStack(alignment: .leading,spacing: 2){
                                Text("-Tuner Upgrade Pack is Monthly subscription")
                                Text("-Subscriptions renew automatically")
                                Text("-Stop renewing at any time from Setting your Device")
                            }
                            .font(.footnote)
                            .padding(.leading,20)
                            
                            Divider().background(font_color)
                                .padding(.bottom,10)
                            
                            HStack(alignment: .center, spacing: 4){
                                //MARK: 購入の復元ボタン
                                Button {
                                    _ = Task<Void, Never> {
                                        do {
                                            try await AppStore.sync()
                                            print(purchaseManager.purchasedProductIDs)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    VStack{
                                        IconStyleView(imageName: "purchased.circle",
                                                      title: "",
                                                      tintColor: font_color)
                                        
                                        Text("Restore Purchases")
                                            .font(.caption2)
                                            .tint(.primary)
                                    }
                                }
                                //MARK: - 購入の復元ボタン
                                Button {
                                    isPrivacy = true
                                    
                                } label: {
                                    VStack{
                                        IconStyleView(imageName: "list.bullet.clipboard.fill",
                                                      title: "",
                                                      tintColor: font_color)
                                        
                                        Text("Privacy Policy")
                                            .font(.caption2)
                                            .tint(.primary)
                                    }
                                }
                                .alert(isPresented: $isPrivacy) {
                                    Alert(
                                        title: Text("Move to external site"),
                                        message: Text(""),
                                        primaryButton: .destructive(Text("Yes")) {
                                            openURL(URL(string: privacyPolicyUrl)!)
                                            
                                        }
                                        ,secondaryButton: .cancel()
                                    )
                                }
                                Button {
                                    isTerms = true
                                    
                                } label: {
                                    VStack{
                                        IconStyleView(imageName: "list.clipboard",
                                                      title: "",
                                                      tintColor: font_color)
                                        
                                        Text("Terms of Use")
                                            .font(.caption2)
                                            .tint(.primary)
                                    }
                                }
                                .alert(isPresented: $isTerms) {
                                    Alert(
                                        title: Text("Move to external site"),
                                        message: Text(""),
                                        primaryButton: .destructive(Text("Yes")) {
                                            openURL(URL(string: termsUrl)!)
                                            
                                        }
                                        ,secondaryButton: .cancel()
                                    )
                                }
                            }
                            
                            .padding(.bottom,20)
                            
                            
                        }
                        
                        .task {
                            _ = Task<Void, Never> {
                                do {
                                    try await purchaseManager.loadProducts()
                                    print("Products loaded: \(purchaseManager.products)")
                                } catch {
                                    print("Failed to load products: \(error)")
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)  // Add this line
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                            
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(backArrow)
                                .frame(width: 40,height: 40)
                        }
                    )
                }
                ToolbarItem(placement: .principal) {
                    Text("Store")
                        .font(.custom(fontx, size: 22))
                        .fontWeight(.thin)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)
        }
    }
}
