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
    let back = AngularGradient(gradient: Gradient(colors: [.black,White2,.black,.black,White2,.black,.black])
                               ,center: .center, angle: .degrees(-45))
    
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
                        
                        HStack(spacing:10){
                            Circle()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .foregroundStyle(back)
                            
                            VStack(spacing:10){
                                Text("Scratch")
                                    .font(.footnote)
                                    .fontWeight(.bold)

                                Text("Search Tips")
                                    .font(.footnote)
                            }
                            .padding()
                        }

                        HStack(spacing:10){
                            ZStack{
                                    Circle()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(White)
                                    
                                    Circle()
                                        .scaledToFill()
                                        .frame(width: 58, height: 58)
                                        .foregroundStyle(new_yellow)
                                    
                                    Image(systemName: "line.horizontal.3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.black)
                                    
                            }
                            
                             VStack(spacing:10){
                                Text("Push")
                                    .font(.footnote)
                                    .fontWeight(.bold)

                                Text("Show Menu")
                                    .font(.footnote)

                                HStack(spacing:10){
                                    Image(systemName: "gear")
                                    Text("Add your photo")
                                }
                                .font(.footnote)
                                .fontWeight(.semibold)
                                 
                                HStack(spacing:10){
                                    Image(systemName: "map")
                                    Text("Edit the route of your fest.")
                                }
                                .font(.footnote)
                                .fontWeight(.semibold)
                                 
                            }
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
