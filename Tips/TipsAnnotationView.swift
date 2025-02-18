//
//  TipsAnnotationView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/24.
//

import SwiftUI

struct TipsAnnotationView: View {
    
    @State private var zoomLevel: Double = 1.0
    @Binding var isSelected: Bool
    
    let tip: Tips
    let frameColor: Color = new_yellow
    let baseSize: CGFloat = 38
    
    var dynamicSize: CGFloat {
        return baseSize * CGFloat(zoomLevel)
    }
    
    var body: some View {
        VStack {
            Text(String(tip.content.prefix(10)))
                .font(.caption)
                .foregroundStyle(fontColor)
            
            ZStack {
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: dynamicSize, height: dynamicSize)
                    .foregroundStyle(new_yellow)
                    .rotationEffect(.degrees(isSelected ? 10 : -10))
                    .animation(
                        isSelected ?
                        Animation.easeInOut(duration: 0.2).repeatForever(autoreverses: true) :
                                .default,
                        value: isSelected
                    )
                
                AsyncImage(url: URL(string: tip.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width:46, height:46)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(new_yellow, lineWidth: 2)
                        )
                } placeholder: {
                    Circle()
                        .fill(.gray)
                        .frame(width: 40, height: 40)
                }
                
            }
        }
        .onAppear {
            updateZoomLevel(likeCount: tip.likeCount)
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                isSelected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isSelected = false
                    }
                }
            } else {
                isSelected = false
            }
        }
    }
    private func updateZoomLevel(likeCount: Int) {
        switch likeCount {
        case 6...10: zoomLevel = 1.2
        case 11...30: zoomLevel = 1.6
        case 31...100: zoomLevel = 2.0
        case 101...: zoomLevel = 2.4
        default: zoomLevel = 1.0
        }
    }
}
