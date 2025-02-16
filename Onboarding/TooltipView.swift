//
//  TooltipView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/07/01.
//
import SwiftUI

struct TermsOfServiceView: View {
    
    @Environment(\.openURL) var openURL
    
    @Binding var showTooltip: Bool
    @State private var isTermsCheck: Bool = false
    @State private var url: URL? = nil
    
    let onAgree: () -> Void
    let termUrl : String = "https://docs.google.com/document/d/1ZJoxYaDdZ8AKtN7GyuuuiXxBsPh7P24XXEJh0v1zPfc/edit"
    
    var body: some View {
        
        ZStack{
            
            BackgroundView()
            
            Image("floq")
                .resizable()
                .clipped()
                .ignoresSafeArea()
            
            ZStack{
                
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: UIScreen.main.bounds.width - 100 ,height: UIScreen.main.bounds.height - 300)
                    .shadow(radius: 10)

                
                VStack(alignment: .center){
                    Text("Welcome")
                        .font(.custom(fontx, size: 30))
                        .foregroundStyle(.black)
                        .padding()
                    
                    Text("Before you begin,")
                        .font(.custom(fontx, size: 16))
                        .foregroundStyle(.black)
                    Text("You must agree to the Terms of Use.")
                        .font(.custom(fontx, size: 18))
                        .foregroundStyle(.black)
                    
                    Button{
                        isTermsCheck = true
                        
                    } label: {
                        Text("Terms of Use")
                            .font(.custom(fontx, size: 20))
                            .frame(width: UIScreen.main.bounds.width / 2 ,height: UIScreen.main.bounds.height / 14)
                        
                            .foregroundColor(.white)
                            .background(sw_pos)
                    }
                    .cornerRadius(20)
                    .padding()
                    
                    .alert(isPresented: $isTermsCheck) {
                        Alert(
                            title: Text("Move to external site"),
                            message: Text(""),
                            primaryButton: .destructive(Text("Yes")) {
                                openURL(URL(string: termUrl)!)
                                
                            }
                            ,secondaryButton: .cancel()
                        )
                    }
                    
                    Button{
                        onAgree()
                        showTooltip = false
                    } label: {
                        
                        Text("Agree")
                            .font(.custom(fontx, size: 20))
                            .frame(width: UIScreen.main.bounds.width / 2 ,height: UIScreen.main.bounds.height / 14)
                        
                            .foregroundColor(.white)
                            .background(sw_normal)
                    }
                    .cornerRadius(20)
                }
                .frame(width: UIScreen.main.bounds.width - 32 ,height: UIScreen.main.bounds.height / 2.4)
                .opacity(0.96)
                .fontWeight(.semibold)
                .shadow(radius: 10)
                .cornerRadius(10)
            }
        }

    }
    
}
