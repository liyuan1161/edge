//
//  DiMapData.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/3.
//

import Foundation
import CoreLocation

class DiMapData: ObservableObject {
    @Published private(set) var locations: [CLLocation] = []

    // 添加位置
    func addLocation(_ location: CLLocation) {
        guard let lastLocation = locations.last else {
            locations.append(location)
            return
        }

        let distance = lastLocation.distance(from: location)
        if distance > 20 {
            locations.append(location)
        }
    }

    // 获取所有位置
    func getLocations() -> [IdentifiableLocation] {
        return locations.map { location in
            IdentifiableLocation(coordinate: location.coordinate,course: location.course)
        }
    }

    // 清除所有位置
    func clearLocations() {
        locations.removeAll()
    }
}
