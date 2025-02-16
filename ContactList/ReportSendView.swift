//
//  ReportSendView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/27.
//

import SwiftUI

struct ReportSendView: View {
    
    @State private var typeReason : String = ""
    @State private var isConfirm : Bool = false
    @State private var isSend : Bool = false
    @State private var email3 : String = ""
    @Environment (\.dismiss) var dismiss
    
    var selectedUid : String
    
    let reasons: [String] = [
        NSLocalizedString("It's spam", comment: ""),
        NSLocalizedString("I just don't like it", comment: ""),
        NSLocalizedString("Nudity or Sexual activity", comment: ""),
        NSLocalizedString("Fraud/Deception", comment: ""),
        NSLocalizedString("Hate speech or Discriminatory symbols", comment: ""),
        NSLocalizedString("False report", comment: ""),
        NSLocalizedString("Bullying or Harassment", comment: ""),
        NSLocalizedString("Violent or Dangerous group", comment: ""),
        NSLocalizedString("Intellectual property infringement", comment: ""),
        NSLocalizedString("Sale of illegal or Regulated goods", comment: ""),
        NSLocalizedString("Suicide or Self-harm", comment: ""),
        NSLocalizedString("Eating disorder", comment: "")
    ]
    
    var body: some View {
        
        ZStack{
            BackgroundView()

            
            VStack(alignment: .center) {
                Text("Please select the reason for reporting")
                    .fontWeight(.bold)
                    .padding(.top,10)
                
                Picker("", selection: $typeReason) {
                    ForEach(reasons, id: \.self) { reason in
                        Text(reason)
                    }
                }
                .pickerStyle(.wheel)
                
                TextField("Your email address",text: $email3)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .padding()
                
                VStack(alignment: .leading){
                    Text("When you make a report, the following information will be sent to the administrator and will be used to confirm the content of the report, respond to it, and prevent unauthorized use.")

                    Text("Internal identifier of the person to be reported, reason for report, email address for confirmation of details, date and time of transmission.")
                }

                .foregroundStyle(.black)


                Button {
                    isConfirm = true
                } label : {
                    HStack{
                        Text("Agree & Report")
                            .fontWeight(.semibold)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                            .background(sw_pos)
                            .cornerRadius(10)
                            .foregroundColor(swfontColor)
                            .disabled(!formisValid)
                    }
                }
            }
            .padding()
            
            .alert(isPresented: $isConfirm) {
                Alert(
                    title: Text("Report to administrator?"),
                    message: Text(""),
                    primaryButton: .destructive(Text("YES")) {
                        ReportManager.shared.sendReport(selectedUid : selectedUid,reason: typeReason, email: email3)
                        isSend = true
                    }
                    ,secondaryButton: .cancel()
                )
            }
            
            .alert("Thank you for posting.", isPresented: $isSend) {
                Button {
                    dismiss()
                } label: {
                    Text("Confirm")
                }
            }
        }
    }
}
extension ReportSendView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !typeReason.isEmpty
        && email3.contains("@")
        && email3.count < 30
    }
}
