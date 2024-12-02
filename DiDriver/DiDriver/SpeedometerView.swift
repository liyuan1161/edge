//
//  SpeedometerView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import SwiftUI

struct SpeedometerView: View {
    var speed: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                .frame(width: 220, height: 220)
                .shadow(radius: 10)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(speed / 240, 1.0))) // 假设最大速度为240 km/h
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: speed)
            
            Text(String(format: "%.0f km/h", speed))
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
        .frame(width: 220, height: 220)
        .padding()
    }
}

