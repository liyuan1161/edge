//
//  LocationManagerHandler.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import CoreLocation
import CoreMotion

class LocationManagerHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManagerHandler()
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onAccelerationUpdate: ((CMAcceleration) -> Void)?
    var onRotationUpdate: ((CMRotationRate) -> Void)?
    
    private override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                if let acceleration = data?.acceleration {
                    //Logger.shared.log("加速度: x=\(acceleration.x), y=\(acceleration.y), z=\(acceleration.z)")
                    self?.onAccelerationUpdate?(acceleration)
                }
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in
                if let rotationRate = data?.rotationRate {
                    //Logger.shared.log("旋转速率: x=\(rotationRate.x), y=\(rotationRate.y), z=\(rotationRate.z)")
                    self?.onRotationUpdate?(rotationRate)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startMonitoringSignificantLocationChanges()
            Logger.shared.log("位置授权成功")
        case .denied, .restricted:
            Logger.shared.log("位置授权被拒绝或受限")
        case .notDetermined:
            Logger.shared.log("位置授权未确定")
        @unknown default:
            Logger.shared.log("未知的授权状态")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Logger.shared.log("位置更新: 速度=\(location.speed), 方向=\(location.course), 时间戳=\(location.timestamp)")
        onLocationUpdate?(location)
    }
}
