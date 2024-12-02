//
//  LocationManagerHandler.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import CoreLocation
import CoreMotion

class LocationManagerHandler: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    var onLocationUpdate: ((CLLocationSpeed, CLLocationDirection) -> Void)?
    var onAccelerationUpdate: ((CMAcceleration) -> Void)?
    var onRotationUpdate: ((CMRotationRate) -> Void)?
    
    override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                if let acceleration = data?.acceleration {
                    Logger.shared.log("加速度: x=\(acceleration.x), y=\(acceleration.y), z=\(acceleration.z)")
                    self?.onAccelerationUpdate?(acceleration)
                }
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in
                if let rotationRate = data?.rotationRate {
                    Logger.shared.log("旋转速率: x=\(rotationRate.x), y=\(rotationRate.y), z=\(rotationRate.z)")
                    self?.onRotationUpdate?(rotationRate)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Logger.shared.log("位置更新: 速度=\(location.speed), 方向=\(location.course)")
        onLocationUpdate?(location.speed, location.course)
    }
}
