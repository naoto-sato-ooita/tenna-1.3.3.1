//
//  UpdateFavView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/12/05.
//



import SwiftUI
import Firebase

struct UpdateFavView: View {
    
    @StateObject var viewModel = SettingViewModel.shared
    
    private let categories = ["Book","Music","Sport","Movie","Anime","Place","Hobby","Food"]
    @State private var preferences: [[String: String]] = []
    @State private var type1 : String = "Music"
    @State var fav1 : String = ""
    @State private var showField : Bool = false
    @State private var artistName2 = ""
    
    @Environment (\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                BackgroundView()
                
                VStack{
                    
                    Divider().background(.white)
                    
                    
                    Spacer()
                    
                        List {
                            ForEach(preferences, id: \.self) { preference in
                                if let category = preference["category"], let item = preference["preference"] {
                                    HStack {
                                        Image(systemName: iconName(for: category))
                                            .foregroundColor(.black)
                                        Text("\(item)")
                                    }
                                }
                                
                            }
                            .onMove(perform: rowReplace)
                            .onDelete { offsets in
                                UserService.shared.deletePreference(uid: viewModel.user?.uid ?? "", at: offsets, preferences: $preferences)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())

                    .frame(height: 300)
                    
                    VStack(spacing: 20) {
                        TextField("Favorite Artist", text: $artistName2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 300)
                        
                        Button {
                            if !artistName2.isEmpty {
                                
                                // Create new preference
                                let newPreference = ["category": "Music", "preference": artistName2]
                                
                                // Update UI immediately
                                preferences.append(newPreference)
                                
                                UserService.shared.savePreference(
                                    uid: viewModel.user?.uid ?? "",
                                    category: "Music",
                                    preference: artistName2
                                )
                                
                                artistName2 = ""
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 200, height: 40)
                                Text("Save")
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    Spacer()
                }
                
                .onAppear {
                    Task{
                        preferences = await UserService.shared.fetchPreferences(uid: viewModel.user?.uid ?? "") ?? [["":""]]
                        
                    }
                }
                
                .navigationBarTitleDisplayMode(.inline)
                
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                Task{
                                    try await SettingViewModel.shared.loadCurrentUser()
                                }
                                dismiss()
                            }, label: {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(backArrow)
                                    .frame(width: 40,height: 40)
                            }
                        )
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Fav Artists")
                            .font(.custom(fontx, size: 22))
                            .foregroundStyle(fontColor)
                            .fontWeight(.thin)
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                            .tint(.primary)
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(White2,for: .navigationBar)
                
            }
        }
        
    }
    func rowReplace(_ from: IndexSet, _ to: Int) {
        preferences.move(fromOffsets: from, toOffset: to)
    }
    
    
    
}
extension UpdateFavView {
    var fieldValid2 : Bool {
        return !fav1.isEmpty
        && fav1.count < 30
        
    }
}


func iconName(for category: String) -> String {
    switch category {
    case "Book":
        return "book.pages"
    case "Music":
        return "music.note"
    case "Sport":
        return "figure.flexibility"
    case "Movie":
        return "movieclapper"
    case "Anime":
        return "play.rectangle"
    case "Place":
        return "mappin.and.ellipse"
    case "Hobby":
        return "star.square"
    case "Food":
        return "fork.knife"
    default:
        return "questionmark.folder"
    }
}
