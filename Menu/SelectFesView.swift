//
//  SelectFesView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/18.
//
import Firebase
import SwiftUI

struct SelectFesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GroupViewModel.shared
    
    @State private var selectedCountry = "USA"
    @State private var selectedGroup: Topic? = nil
    @State private var selectedGroups: Set<String> = []
    
    let countries = ["USA","EU","ASIA"]
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var filteredGroups: [Topic] {
        viewModel.groups.filter { $0.region == selectedCountry }
    }
    
    @Binding var isFromPlus : Bool
    //@Binding var isEditFlow : Bool
    
    var body: some View {
        ZStack{
            
            White
            
            VStack(spacing: 20) {
                Picker("Region", selection: $selectedCountry) {
                    ForEach(countries, id: \.self) { country in
                        Text(country)
                            .tag(country)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedCountry) { newRegion in
                    loadGroups(for: newRegion)
                    if let firstGroup = filteredGroups.first {
                        selectedGroup = firstGroup
                    }
                }
                Picker("Groups", selection: $selectedGroup) {
                    ForEach(filteredGroups) { group in
                        Text(group.name)
                            .tag(Optional(group))
                    }
                }
                .pickerStyle(.wheel)
                
                Button {
                    if !isFromPlus {
                        if let group = selectedGroup {
                            Task {
                                await viewModel.toggleBookmark(groupId: group.id)
                            }
                            selectedGroups.insert(group.id)
                        }
                    } else {
                        //　選択したグループのannotationを読み込み、アノテーション反映
                        
                        Task{
                            if let group = selectedGroup {
                                await FlowLineViewModel.shared.fetchAnnotations(for: group.id)
                            }
                        }
                        dismiss()
                    }
                    
                } label: {
                    
                    Text(isFromPlus ? "Create Route" : "Add to Bookmarks")
                        .frame(width: 200, height: 40)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                
                if !isFromPlus {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedGroups), id: \.self) { groupId in
                                BookmarkTag(groupId: groupId) {
                                    selectedGroups.remove(groupId)
                                    Task {
                                        await GroupViewModel.shared.toggleBookmark(groupId: groupId)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
            
        }
        .onAppear {
            Task {
                await viewModel.fetchGroups(for: selectedCountry)
                if selectedGroup == nil, let firstGroup = filteredGroups.first {
                    selectedGroup = firstGroup
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: { Text(errorMessage) }
        
            .onChange(of: selectedCountry) { newRegion in
                loadGroups(for: newRegion)
            }
            .task {
                // Fetch existing bookmarks when view appears
                if let currentUserId = Auth.auth().currentUser?.uid {
                    do {
                        let bookmarksDoc = try await Firestore.firestore()
                            .collection("users")
                            .document(currentUserId)
                            .getDocument()
                        
                        if let bookmarks = bookmarksDoc.data()?["bookmarks"] as? [String] {
                            selectedGroups = Set(bookmarks)
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                        }, label: {
                            ZStack{
                                Circle()
                                    .fill(swfontColor)
                                    .opacity(0.4)
                                    .frame(width:40,height:40)
                                
                                Image(systemName: "arrow.left")
                                    .foregroundColor(backArrow)
                                    .frame(width: 40,height: 40)
                            }
                        }
                    )
                }
            }
    }
    private func loadGroups(for region: String) {
        isLoading = true
        Task {
            do {
                await viewModel.fetchGroups(for: region)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}
