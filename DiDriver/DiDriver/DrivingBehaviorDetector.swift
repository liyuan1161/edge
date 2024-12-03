//
//  DrivingBehaviorDetector.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import UIKit
import CoreLocation
import CoreMotion
import SwiftUI

class DrivingBehaviorDetector: ObservableObject {
    private var locationHandler = LocationManagerHandler.shared
    
    // 用于存储上一次的速度和方向
    private var lastSpeed: CLLocationSpeed = 0.0
    private var lastHeading: CLLocationDirection = 0.0
    
    // 卡尔曼滤波器实例
    private var kalmanFilter = KalmanFilter()
    
    // 用于发布检测到的行为和当前时速
    @Published var detectedBehavior: String = "等待检测..."
    @Published var currentSpeed: Double = 0.0 // 当前时速，单位为 km/h
    @Published var rawSpeed: Double = 0.0 // 原始速度，单位为 km/h
    @Published var smoothedSpeed: Double = 0.0 // 平滑后的速度，单位为 km/h
    @Published var speedChangeBehavior: String = "速度无变化" // 新字段
    @Published var mapData = DiMapData() // 使用 @Published
    
    // 旋转检测参数
    private var rotationSamples: [(time: TimeInterval, angle: Double)] = []
    private let windowDuration: TimeInterval = 3.0
    private let maxSamples = 100
    private var angleThresholds: (emergencyRight: Double, emergencyLeft: Double, right: Double, left: Double, straight: Double) = (0.5, -0.5, 0.2, -0.2, 0.05)

    init() {
        setupHandlers()
    }
    
    private func setupHandlers() {
        locationHandler.onLocationUpdate = { [weak self] location in
            self?.updateLocationData(location: location)
        }
        
        locationHandler.onRotationUpdate = { [weak self] rotationRate in
            self?.detectRotationWithAngle(rotationRate)
        }
    }
    
    // 更新位置数据
    private func updateLocationData(location: CLLocation) {
        guard location.speed.isFinite, location.speed >= 0 else { return }
        
        let filteredSpeed = kalmanFilter.filter(measurement: location.speed) // 使用卡尔曼滤波器平滑速度
        
        // 将速度从 m/s 转换为 km/h
        rawSpeed = location.speed * 3.6
        smoothedSpeed = filteredSpeed * 3.6
        currentSpeed = smoothedSpeed
        
        // 添加位置到 DiMapData
        mapData.addLocation(location)
        
        // 检测加速/减速
        detectSpeedBehavior(speedDifference: filteredSpeed - lastSpeed)
        
        // 检测启动和停止
        detectStartStopBehavior(filteredSpeed: filteredSpeed)
        
        lastSpeed = filteredSpeed
        lastHeading = location.course
    }
    
    private func detectSpeedBehavior(speedDifference: Double) {
        let accelerationThreshold: Double = 2.0
        let decelerationThreshold: Double = -2.0

        if speedDifference > accelerationThreshold {
            speedChangeBehavior = "快速加速"
        } else if speedDifference > 0 {
            speedChangeBehavior = "平稳加速"
        } else if speedDifference < decelerationThreshold {
            speedChangeBehavior = "快速减速"
        } else if speedDifference < 0 {
            speedChangeBehavior = "平稳减速"
        } else {
            speedChangeBehavior = "速度保持不变"
        }
        
        logMessage("Speed Change Behavior: \(speedChangeBehavior), Speed Difference: \(speedDifference)",level: .info)
    }
    
    private func detectStartStopBehavior(filteredSpeed: CLLocationSpeed) {
        if filteredSpeed > 0 && lastSpeed == 0 {
            speedChangeBehavior = "启动"
            logMessage(detectedBehavior)
        } else if filteredSpeed == 0 && lastSpeed > 0 {
            speedChangeBehavior = "停止"
            logMessage(detectedBehavior,level: .info)
        }
    }
    
    // 检测旋转变化
    private func detectRotationWithAngle(_ rotationRate: CMRotationRate) {
        guard rotationRate.z.isFinite else { return }
        
        let currentTime = Date().timeIntervalSince1970
        let currentAngle = rotationRate.z

        // 添加样本并移除过期样本
        rotationSamples.append((time: currentTime, angle: currentAngle))
        pruneSamples()
        
        // 计算总旋转角度并评估行为
        let totalRotationAngle = calculateTotalRotationAngle()
        evaluateRotationBehavior(totalRotationAngle)
    }

    private func pruneSamples() {
        let currentTime = Date().timeIntervalSince1970
        rotationSamples.removeAll { currentTime - $0.time > windowDuration }
        if rotationSamples.count > maxSamples {
            rotationSamples.removeFirst(rotationSamples.count - maxSamples)
        }
    }

    private func calculateTotalRotationAngle() -> Double {
        return rotationSamples.enumerated().reduce(0.0) { total, element in
            let (index, sample) = element
            if index > 0 {
                let deltaTime = sample.time - rotationSamples[index - 1].time
                return total + sample.angle * deltaTime
            }
            return total
        }
    }

    private func evaluateRotationBehavior(_ totalRotationAngle: Double) {
        if totalRotationAngle > angleThresholds.emergencyRight {
            detectedBehavior = "紧急右转"
        } else if totalRotationAngle < angleThresholds.emergencyLeft {
            detectedBehavior = "紧急左转"
        } else if totalRotationAngle > angleThresholds.right {
            detectedBehavior = "右转"
        } else if totalRotationAngle < angleThresholds.left {
            detectedBehavior = "左转"
        } else if abs(totalRotationAngle) < angleThresholds.straight {
            detectedBehavior = "直行"
        } else {
            detectedBehavior = "轻微调整"
        }

        logMessage("Detected Behavior: \(detectedBehavior), Total Rotation Angle: \(totalRotationAngle)",level: .info)
    }
}

// 简单的卡尔曼滤波器实现


