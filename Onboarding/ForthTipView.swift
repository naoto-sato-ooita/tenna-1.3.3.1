//
//  ForthTipView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/09/03.
//

import SwiftUI

struct ForthTipView: View {
    
    @Binding var showTip: Bool
    let onAgree: () -> Void
    @Binding var selection : Int
    
    var body: some View {
        ZStack{
            
            BackgroundView()
            
            VStack(alignment: .center,spacing: 20){

                    Text("How to Use")
                        .font(.custom(fontx, size: 34))
                        .padding(.top,50)
                Spacer()
                HStack{
                    Image("tip3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 2 ,height: UIScreen.main.bounds.height / 2)
                    
                    
                    VStack(alignment: .leading,spacing: 20){
                        
                        HStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(White)
                                            .opacity(1)
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "line.horizontal.3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.black)
                            }
                            
                            VStack{
                                Text("Show Menu")
                                Text("-> Check Topic")
                            }
                                .font(.footnote)
                                .padding()
                        }
                        
                        HStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(.white)
                                    )
                                    .frame(width: 50, height: 100)
                                
                                Image(systemName: "flame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.black)
                            }
                            
                            
                            Text("Share Tips")
                                .font(.footnote)
                                .padding()
                        }
                        
                        HStack{
                            ZStack{
                                Circle()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.white)
                                
                                
                                Image(systemName: "arrow.triangle.2.circlepath.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50,height: 50)
                                    .foregroundStyle(.black)
                                    .fontWeight(.ultraLight)
                            }
                            
                            
                            Text("Search Tips")
                                .font(.footnote)
                                .padding()
                        }
                        
                    }
                    
                    
                    

                }
                Spacer()
                HStack(spacing: 20){
                    Button{
                        selection = 3
                    } label: {
                        HStack{
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20,height: 20)
                            Text("Back")
                                .font(.custom(fontx, size: 20))
                        }
                    }
                    .foregroundStyle(.black)
                    
                    Button{
                        onAgree()
                        showTip = false
                        
                    } label: {
                        
                        HStack {
                            Text("I got it!")
                                .font(.custom(fontx, size: 20))
                                .foregroundStyle(.black)
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(fontColor)
                                .frame(width: 30,height: 30)
                        }
                    }
                }
                .padding(.bottom,50)
            }
            .onDisappear{
                Task { await requestAuthorization()}
            }
            
        }
    }
    public func requestAuthorization() async {
        do {
            let requestResult = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if requestResult {
                print("通知の許可を得られたよ")
            } else {
                print("通知の許可を得られなかったよ")
            }
        } catch {
            print(error)
        }
    }
}
