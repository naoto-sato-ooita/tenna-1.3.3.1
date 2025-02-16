//
//  SimpleRotation.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/08/23.
//

import SwiftUI

public struct SimpleRotation: ViewModifier {
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    @Binding private var angleSnap: Double?
    
    @State private var viewSize: CGSize = .zero
    
    // New states for rotation detection and handling
    @State private var rotationDetected: Bool = false
    @Binding var didRotateBeyondThreshold: Bool
    
    public init(rotationAngle: Angle = .degrees(0.0), angleSnap: Binding<Double?> = .constant(nil), didRotateBeyondThreshold: Binding<Bool> = .constant(false)) {
        _rotationAngle = State(initialValue: rotationAngle)
        _angleSnap = angleSnap
        _didRotateBeyondThreshold = didRotateBeyondThreshold
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeySimpleRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeySimpleRotation.self) { newSize in
                    viewSize = newSize
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
                .gesture(
                    DragGesture()
                        .updating($gestureRotation) { value, state, _ in
                            state = calculateRotation(value: value)
                        }
                        .onEnded { value in
                            let rotation = calculateRotation(value: value)
                            rotationAngle += rotation
                            
                            // Check if rotation exceeds 300° in a single gesture
                            if abs(rotation.degrees) >= 100 {
                                rotationDetected = true
                                didRotateBeyondThreshold.toggle()
                                
                                // Perform the action you want after detecting the rotation
                                performAction()
                                
                                // Reset rotation and state
                                rotationAngle = .zero
                                rotationDetected = false
                                //didRotateBeyondThreshold = false
                            }
                        }
                )
        }
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    public func calculateRotation(value: DragGesture.Value) -> Angle {
        let centerX = viewSize.width / 2
        let centerY = viewSize.height / 2
        let startVector = CGVector(dx: value.startLocation.x - centerX, dy: value.startLocation.y - centerY)
        let endVector = CGVector(dx: value.location.x - centerX, dy: value.location.y - centerY)
        let angleDifference = atan2(endVector.dy, endVector.dx) - atan2(startVector.dy, startVector.dx)
        var rotation = Angle(radians: Double(angleDifference))
        
        if let snap = angleSnap {
            let snapAngle = Angle(degrees: snap)
            let snappedRotation = round(rotation.radians / snapAngle.radians) * snapAngle.radians
            rotation = Angle(radians: snappedRotation)
        }
        
        return rotation
    }
    
    // Example function that gets triggered after rotation exceeds 300°
    private func performAction() {
        print("Rotation exceeded")
        // Add any other actions you want to trigger here
        
    }
}

struct FrameSizeKeySimpleRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func simpleRotation(
        rotationAngle: Angle? = nil,
        angleSnap: Binding<Double?> = .constant(nil),
        didRotateBeyondThreshold: Binding<Bool> = .constant(false)
    ) -> some View {
        let effect = SimpleRotation(
            rotationAngle: rotationAngle ?? .degrees(0.0),
            angleSnap: angleSnap,
            didRotateBeyondThreshold: didRotateBeyondThreshold
        )
        return self.modifier(effect)
    }
}
