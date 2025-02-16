//
//  DocumentListView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/14.
//

import SwiftUI

struct DocumentListView: View {
    @Environment (\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    let privacyPolicyUrl : String = "https://docs.google.com/document/d/1P5hTtGiMAos1cwtwL2-1aNxjrPg6qNAePQaU7FYT1zI/"
    let descriptionUrl : String = "https://docs.google.com/document/d/1CWqiH92YnLYNQe3JHNknq500Cx7jiBADDcYw-wAEaH4/edit?usp=sharing"
    let termUrl : String = "https://docs.google.com/document/d/1ZJoxYaDdZ8AKtN7GyuuuiXxBsPh7P24XXEJh0v1zPfc/edit"
    
    @State private var isPrivacy : Bool = false
    @State private var isDescription : Bool = false
    @State private var isTerms : Bool = false
    
    @State private var url: URL? = nil
    
    var body: some View {
        
        ZStack(alignment: .top){
            
            BackgroundView()
            
            VStack {

                Divider().background(.white)
                
                List{
                    //MARK: -
                    
                    Button {
                        isDescription = true
                        
                    } label: {
                        HStack{
                            IconStyleView(imageName: "list.bullet.clipboard",
                                          title: "",
                                          tintColor: Color(.blue))
                            
                            Text("About Tenna2")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .tint(.primary)
                        }
                    }
                    .alert(isPresented: $isDescription) {
                        Alert(
                            title: Text("Move to external site"),
                            message: Text(""),
                            primaryButton: .destructive(Text("Yes")) {
                                openURL(URL(string: descriptionUrl)!)
                                
                            }
                            ,secondaryButton: .cancel()
                        )
                    }
                    
                    //MARK: -
                    
                    Button {
                        isPrivacy = true
                        
                    } label: {
                        HStack{
                            IconStyleView(imageName: "list.bullet.clipboard.fill",
                                          title: "",
                                          tintColor: Color(.systemIndigo))
                            
                            Text("Privacy Policy")
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
                        HStack{
                            IconStyleView(imageName: "list.clipboard",
                                          title: "",
                                          tintColor: Color(.systemPink))
                            
                            Text("Terms of Use")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .tint(.primary)
                        }
                    }
                    .alert(isPresented: $isTerms) {
                        Alert(
                            title: Text("Move to external site"),
                            message: Text(""),
                            primaryButton: .destructive(Text("Yes")) {
                                openURL(URL(string: termUrl)!)
                                
                            }
                            ,secondaryButton: .cancel()
                        )
                    }
                    
                    //MARK: -
                    HStack{
                        
                        IconStyleView(imageName: "gear",
                                      title: "",
                                      tintColor: Color(.systemGray))
                        Text("Version")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }
                    
                }

            }
            .scrollContentBackground(.hidden)
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
                Text("About us")
                    .font(.custom(fontx, size: 22))
                    .foregroundStyle(fontColor)
                    .fontWeight(.heavy)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(White2,for: .navigationBar)
    }
}

#Preview {
    DocumentListView()
}
