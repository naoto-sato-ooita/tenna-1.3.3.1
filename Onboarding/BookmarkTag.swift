//
//  BookmarkTag.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/24.
//

import SwiftUI
import Firebase

struct BookmarkTag: View {
    
    let groupId: String
    let onRemove: () -> Void
    @State private var groupName: String = ""
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(groupName)
                .font(.footnote)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 1)
                )
            
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            
        }
        
        .onTapGesture {
            onRemove()
        }
        .onAppear {
            fetchGroupName()
        }
    }
    
    private func fetchGroupName() {
        Task {
            if let group = try? await Firestore.firestore().collection("groups").document(groupId).getDocument(),
               let name = group.data()?["name"] as? String {
                DispatchQueue.main.async {
                    self.groupName = name
                }
            }
        }
    }
}
