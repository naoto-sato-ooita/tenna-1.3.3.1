//
//  ImpressionDetailView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/17.
//

import Foundation
import SwiftUI
import Firebase

struct ImpressionDetailView: View {
    
    @Binding var ImpressionSendUser : User
    @Binding var showImpressionDetail : Bool
    
    @State var isReport: Bool = false
    @State var isBlock: Bool = false
    @State var isBlockComp: Bool = false
    @State var isDel : Bool = false
    @State var selectedUidForReport: String?
    
    
    
    var body: some View {
        HStack(spacing:4){
            
            Button {
                if let uid = ImpressionSendUser.uid {
                    ImpressionManager.shared.removeImpression(selectedUserId: uid)
                }
            } label: {
                ZStack{
                    Capsule()
                        .frame(width: 100,height: 50)
                        .foregroundStyle(.gray)
                    
                    Image(systemName:"trash.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                        .foregroundColor(swfontColor)
                }
            }
            
            
            Button {
                if let uid = ImpressionSendUser.uid {
                    selectedUidForReport = uid
                    isReport = true
                }
            } label: {
                ZStack{
                    Capsule()
                        .frame(width: 100,height: 50)
                        .foregroundStyle(new_yellow)
                    
                    Image(systemName:"flag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                        .foregroundColor(swfontColor)
                }
            }
            
            Button {
                isBlock = true

            } label: {
                ZStack{
                    Capsule()
                        .frame(width: 100,height: 50)
                        .foregroundStyle(sw_neg)
                    
                    Image(systemName:"circle.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                        .foregroundColor(swfontColor)
                }
            }
        }
        
        .sheet(isPresented: $isReport) {
            if let selectedUid = selectedUidForReport {
                ReportSendView(selectedUid: selectedUid)
                    .presentationDetents([.height(600)])
            }
        }
        
        .alert(isPresented: $isBlock) {
            Alert(
                title: Text("Block?"),
                message: Text(""),
                primaryButton: .destructive(Text("Yes")) {
                    if let uid = ImpressionSendUser.uid {
                        BlockManager.shared.blockUser(targetUserId: uid)
                    }
                    isBlockComp = true
                }
                ,secondaryButton: .cancel()
            )
        }
        
        .alert("Block Complete", isPresented: $isBlockComp) {
            Button {} label: { Text("Confirm") }
        }
    }
}
