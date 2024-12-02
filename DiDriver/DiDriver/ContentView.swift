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

    var body: some View {
        VStack {
            Text("驾驶行为检测")
                .font(.largeTitle)
                .padding()

            Text(behaviorMessage)
                .font(.title)
                .padding()
                .onReceive(behaviorDetector.$detectedBehavior) { behavior in
                    behaviorMessage = behavior
                }

            Spacer()
        }
        .padding()
    }
}
