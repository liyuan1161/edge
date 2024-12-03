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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 1 // 每次移动 1 米更新一次位置
        locationManager.activityType = .automotiveNavigation // 针对驾驶优化定位
        locationManager.pausesLocationUpdatesAutomatically = false // 禁止自动暂停位置更新
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        } else{
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.pausesLocationUpdatesAutomatically = false
                locationManager.startMonitoringSignificantLocationChanges()
            } else {
                logMessage("位置服务不可用，请检查设备设置",level: .error)
            }
        }
    }
    
    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                if let acceleration = data?.acceleration {
                    //logMessage("加速度: x=\(acceleration.x), y=\(acceleration.y), z=\(acceleration.z)")
                    self?.onAccelerationUpdate?(acceleration)
                }
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in
                if let rotationRate = data?.rotationRate {
                    //logMessage("旋转速率: x=\(rotationRate.x), y=\(rotationRate.y), z=\(rotationRate.z)")
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
            locationManager.startUpdatingLocation()

            logMessage("位置授权成功")
        case .denied, .restricted:
            logMessage("位置授权被拒绝或受限")
        case .notDetermined:
            logMessage("位置授权未确定")
        @unknown default:
            logMessage("未知的授权状态")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 检查位置精度
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 50 {
            logMessage("位置精度不足: \(location.horizontalAccuracy) 米")
            return
        }

        // 检查速度和方向的有效性
        let speedKmH = location.speed >= 0 ? location.speed * 3.6 : 0 // 转换为 km/h
        let course = location.course >= 0 ? location.course : -1 // -1 表示方向不可用

        // 格式化时间戳
        let formattedTime = formatDate(location.timestamp)

        // 日志记录
        logMessage("位置更新: 速度=\(speedKmH) km/h, 方向=\(course), 时间戳=\(formattedTime)",level: .debug)

        // 调用更新回调
        onLocationUpdate?(location)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
