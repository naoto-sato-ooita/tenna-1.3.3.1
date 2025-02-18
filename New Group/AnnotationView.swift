//
//  AnnotationView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/02/10.
//

import SwiftUI
import Firebase

struct AnnotationView: View {
    
    let annotation: RouteAnnotation
    @Binding var isSelectedAnno: Bool
    @State private var isHovered = false
    @Binding var isEditOK: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Main circle with shadow and animation
                Circle()
                    .fill(White)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                    .frame(width: isHovered ? 50 : 44, height: isHovered ? 50 : 44)
                
                AsyncImage(url: URL(string: annotation.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: isHovered ? 46 : 40, height: isHovered ? 46 : 40)
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
                
                // Order numbers with improved visual style
                if !isEditOK {
                    HStack(spacing: -5) {
                        ForEach(annotation.orders, id: \.self) { order in
                            Circle()
                                .fill(new_yellow)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("\(order + 1)")
                                        .foregroundColor(.black)
                                        .font(.body)
                                        .fontWeight(.bold)
                                )
                        }
                    }
                    .offset(x: 20, y: -20)
                }
            }
            
            // Enhanced title display
            Text(annotation.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(new_yellow.opacity(0.6))
                        .shadow(color: .black.opacity(0.1), radius: 2)
                )
        }
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct DropPin: Shape {
  var startAngle: Angle = .degrees(180)
  var endAngle: Angle = .degrees(0)

  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                              control1: CGPoint(x: rect.midX, y: rect.maxY),
                              control2: CGPoint(x: rect.minX, y: rect.midY + rect.height / 4))
    path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                              control1: CGPoint(x: rect.maxX, y: rect.midY + rect.height / 4),
                              control2: CGPoint(x: rect.midX, y: rect.maxY))
    return path
  }
}

