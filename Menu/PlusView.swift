//
//  PlusView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/22.
//

import SwiftUI
import Firebase

struct PlusView: View {
    @StateObject private var viewModel = TalkingListViewModel()
    
    @Binding var isMenu : Bool
    @State private var isTalk: Bool = false
    @State private var isSet: Bool = false
    @State private var isTopic: Bool = false
    @State private var isMap: Bool = false
    @State private var showCreateTips: Bool = false
    @Binding var isEditFlow: Bool
    @State var isFromPlus: Bool = true
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(White)
                    )
                    .frame(width: UIScreen.main.bounds.width - 40, height: 80)
                
                
                HStack {
                    Spacer()
                    ButtonMenu(icon: "flame", title: "Tips", action: {
                        showCreateTips = true
                    })
                    ButtonMenu(icon: "message", title: "Message", action: {
                        isTalk = true
                    })
                    ButtonMenu(icon: "bookmark", title: "Topic", action: {
                        isTopic = true
                    })
                    ButtonMenu(icon: "map", title: "Route", action: {
                        Task{
                            //保存されてるなら、作成済を読み込み、編集有効化
                            if let userId = Auth.auth().currentUser?.uid {
                                await FlowLineViewModel.shared.loadFlowLine(userId: userId)
                                if !FlowLineViewModel.shared.annotations.isEmpty { //返さないので、直接参照
                                    isEditFlow.toggle()
                                } else { isMap = true } //保存なし、ならSelectFesに遷移
                            }
                        }
                    })
                    ButtonMenu(icon: "gearshape", title: "Setting", action: {
                        isSet = true
                    })
                    .padding(.trailing,20)
                }
            }
            .foregroundStyle(isMenu ? .black : .clear)
            
            
            
            .onTapGesture {
                withAnimation(.snappy) {
                    isMenu.toggle()
                }
            }

            .navigationDestination(isPresented: $showCreateTips) {
                CreateTipsView()
            }

            .navigationDestination(isPresented: $isTalk) {
                TalkingListView()
                    .environmentObject(viewModel)
            }
            .navigationDestination(isPresented: $isTopic) {
                CreateGroupView(makeGroup: $isTopic)
            }
            .navigationDestination(isPresented: $isMap) {
                SelectFesView(isFromPlus: $isFromPlus)
                    .toolbarTitleDisplayMode(.inline)  // Add this line
                    .navigationBarBackButtonHidden(true)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(White2,for: .navigationBar)
            }
            .navigationDestination(isPresented: $isSet) {
                SettingView()
            }

            .onAppear {
                Task{
                    try await SettingViewModel.shared.loadCurrentUser()
                }
            }
            
        }
    }
}

struct ButtonMenu: View {
    var icon: String
    var title: String
    var action : () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            VStack{
                ZStack{

                    Circle()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(.gray)
                        .opacity(0.2)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .frame(width: 40,height: 40)
                        //.background(.gray,in: Circle())
                }
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
            }
        }
        .tint(.primary)
    }
}
