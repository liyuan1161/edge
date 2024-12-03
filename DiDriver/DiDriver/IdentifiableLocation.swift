//
//  IdentifiableLocation.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/3.
//

import Foundation
import CoreLocation

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
