//
//  ContentView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var behaviorDetector = DrivingBehaviorDetector()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("驾驶行为检测")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                SpeedometerView(speed: behaviorDetector.currentSpeed)
                
                Text("原始速度: \(String(format: "%.1f", behaviorDetector.rawSpeed)) km/h")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)

                Text("平滑速度: \(String(format: "%.1f", behaviorDetector.smoothedSpeed)) km/h")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                HStack(spacing: 20) {
                    Text(behaviorDetector.speedChangeBehavior)
                         .font(.title)
                         .foregroundColor(.white)
                         .padding()
                         .background(Color.black.opacity(0.7))
                         .cornerRadius(10)

                     Text(behaviorDetector.detectedBehavior)
                         .font(.title)
                         .foregroundColor(.white)
                         .padding()
                         .background(Color.black.opacity(0.7))
                         .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
        }
    }
}
