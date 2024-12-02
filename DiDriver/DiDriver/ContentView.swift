//
//  ContentView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var behaviorDetector = DrivingBehaviorDetector()
    @State private var behaviorMessage: String = "等待检测..."
    @State private var speedMessage: String = "当前速度: 0 km/h"
    @State private var rawSpeedMessage: String = "原始速度: 0 km/h"
    @State private var smoothedSpeedMessage: String = "平滑速度: 0 km/h"

    var body: some View {
        ZStack {
            // 背景色
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("驾驶行为检测")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                Text(behaviorMessage)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .onReceive(behaviorDetector.$detectedBehavior) { behavior in
                        behaviorMessage = behavior
                    }

                Text(rawSpeedMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .onReceive(behaviorDetector.$rawSpeed) { speed in
                        rawSpeedMessage = String(format: "原始速度: %.1f km/h", speed)
                    }

                Text(smoothedSpeedMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .onReceive(behaviorDetector.$smoothedSpeed) { speed in
                        smoothedSpeedMessage = String(format: "平滑速度: %.1f km/h", speed)
                    }

                Spacer()
            }
            .padding()
        }
    }
}
