//
//  RadarView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/12/08.
//

import SwiftUI


struct RadarView: View {
    @Binding var startAnimation: Bool
    @Binding var fadeAnimation1: Bool
    @Binding var fadeAnimation2: Bool
    @Binding var fadeAnimation3: Bool
    
    var body: some View {
        ZStack {
            
            Group {
                
                Circle()
                    .fill(RadialGradient.customRadialGradient)
                    .frame(width: 200)
                
                QuadCircle(start: .degrees(100), end: .degrees(270))
                    .fill(AngularGradient.customAngularGradient)
                    .frame(width: 200)
                    .rotationEffect(.degrees(startAnimation ? 360 : 0))
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.clear)
                    .frame(width: 5, height: 100, alignment: .center)
                    .offset(y: -50)
                    .rotationEffect(.degrees(startAnimation ? 360 : 0))
            }
        }
    }
}

struct QuadCircle: Shape {
    var start: Angle
    var end: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.midX, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}



extension RadialGradient {
    static var customRadialGradient: RadialGradient {
        RadialGradient(gradient: Gradient(colors: [Color.clear.opacity(0.2), new_yellow.opacity(0.1)]), center: .center, startRadius: 90, endRadius: -10)
    }
}

extension AngularGradient {
    static var customAngularGradient: AngularGradient {
        AngularGradient(gradient:  Gradient(colors: [new_yellow, new_yellow.opacity(0.05)]), center: .center, startAngle: .degrees(90), endAngle: .degrees(-250))
    }
}

