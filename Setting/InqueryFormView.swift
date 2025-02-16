//
//  InqueryForm.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/27.
//

import SwiftUI

struct InqueryFormView: View {
    @Environment (\.dismiss) var dismiss
    @State private var typeInquery : String = "Add Topic"
    @State private var contentInquery : String = ""
    @State private var isConfirm : Bool = false
    @State private var isSend : Bool = false
    @State private var email2 : String = ""
    
    
    var body: some View {
        
        ZStack(alignment: .top){
            BackgroundView()
            
            
            VStack{
                Divider().background(.white)
                
                Spacer()
                
                VStack(alignment: .leading,spacing: 20) {
                    Text("About")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    
                    Picker("", selection: $typeInquery) {
                        Text("Add Topic").tag("Topic")
                        Text("System error").tag("System error")
                        Text("Purchase").tag("Purchase")
                        Text("Privacy").tag("Privacy")
                        Text("Others").tag("Others")
                    }

                    .pickerStyle(.menu)
                    .tint(.primary)
                    
                    Text("Content")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    
                    TextField("<300", text: $contentInquery,axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .background(.white)

                    Text("Email Address")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    TextField("",text: $email2)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .background(.white)
                        .keyboardType(.emailAddress)
                }
                
                
                Button {
                    isConfirm = true
                } label : {

                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.white)
                                    .opacity(1)
                            )
                            .frame(width: 150, height: 50)
                        
                        HStack {
                            Text("Send")
                                .font(.custom(fontx, size: 14))
                                .foregroundStyle(fontColor)
                            
                            Image(systemName: "envelope")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(fontColor)
                                .frame(width: 20,height: 20)
                        }
                    }
                    
                }
                
                .disabled(!formisValid)
                Spacer()
            }
            
            .frame(width: UIScreen.main.bounds.width - 32)
            
            .alert(isPresented: $isConfirm) {
                Alert(
                    title: Text("Send to admin?"),
                    message: Text(""),
                    primaryButton: .destructive(Text("YES")) {
                        ReportManager.shared.sendInquery(type: typeInquery,content: contentInquery,email: email2)
                        isSend = true
                    }
                    ,secondaryButton: .cancel()
                )
            }
            
            .alert("Inquery Complete", isPresented: $isSend) {
                Button {
                } label: {
                    Text("Confirm")
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
                Text("Contact")
                    .font(.custom(fontx, size: 22))
                    .foregroundStyle(fontColor)
                    .fontWeight(.thin)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(White2,for: .navigationBar)
    }
}


extension InqueryFormView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !email2.isEmpty
        && email2.contains("@")
        && email2.count < 30
        && !typeInquery.isEmpty
        && !contentInquery.isEmpty
        && contentInquery.count < 300
    }
}
