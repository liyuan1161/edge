//
//  DiMapView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/3.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct DiMapView: View {
    @State var mapData: DiMapData
    @State var region: MKCoordinateRegion
    @State private var isAnimating = false
    @State private var locationManager = CLLocationManager()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: mapData.getLocations()) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .shadow(radius: 3)
                    }
                }
            }
            .cornerRadius(15)
            .onAppear {
                isAnimating = true
                if let lastLocation = mapData.getLocations().last {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        region = MKCoordinateRegion(
                            center: lastLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if let currentLocation = locationManager.location {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                region.center = currentLocation.coordinate
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
}

