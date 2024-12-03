//
//  DiMapView.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/3.
//

import Foundation
import SwiftUI
import MapKit

struct DiMapView: View {
    @State var mapData: DiMapData
    @State var region: MKCoordinateRegion

    var body: some View {
        
        Map(coordinateRegion: $region, annotationItems: mapData.getLocations()) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .onAppear {
            if let firstLocation = mapData.getLocations().last {
                region = MKCoordinateRegion(
                    center: firstLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
}


