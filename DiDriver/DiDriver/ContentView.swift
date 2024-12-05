//
//  ContentView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var behaviorDetector = DrivingBehaviorDetector()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("驾驶行为检测")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Text("\(behaviorDetector.detectedBehavior)-\(behaviorDetector.speedChangeBehavior)")
                     .font(.footnote)
                     .foregroundColor(.white)
                     .padding()
                     .background(Color.black.opacity(0.7))
                     .cornerRadius(10)

                SpeedometerView(speed: behaviorDetector.currentSpeed)
                HStack(spacing: 20) {
                    Text("原始速度: \(String(format: "%.1f", behaviorDetector.rawSpeed)) km/h")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                   
                    Text("平滑速度: \(String(format: "%.1f", behaviorDetector.smoothedSpeed)) km/h")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }


                let defaultCoordinate = CLLocationCoordinate2D(latitude: 34.2692, longitude: 108.9465) // 西安钟楼

                // 创建一个默认的 MKCoordinateRegion
                let defaultRegion = MKCoordinateRegion(
                    center: defaultCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // 缩放级别
                )

                // 如果 behaviorDetector.mapData 有特定逻辑，也可以自定义
                if let lastLocation = behaviorDetector.mapData.getLocations().last {
                    let customRegion = MKCoordinateRegion(
                        center: lastLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    
                    DiMapView(mapData: behaviorDetector.mapData, region: customRegion)
                } else {
                    DiMapView(mapData: behaviorDetector.mapData, region: defaultRegion)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
