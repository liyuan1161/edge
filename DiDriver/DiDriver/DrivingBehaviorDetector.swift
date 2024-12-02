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
    
    // 卡尔曼滤波器参数
    private var kalmanFilter: KalmanFilter = KalmanFilter()
    
    // 用于发布检测到的行为和当前时速
    @Published var detectedBehavior: String = "等待检测..."
    @Published var currentSpeed: Double = 0.0 // 当前时速，单位为 km/h
    @Published var rawSpeed: Double = 0.0 // 原始速度，单位为 km/h
    @Published var smoothedSpeed: Double = 0.0 // 平滑后的速度，单位为 km/h
    
    init() {
        setupHandlers()
    }
    
    private func setupHandlers() {
        locationHandler.onLocationUpdate = { [weak self] location in
            self?.updateLocationData(location: location)
        }
        
        locationHandler.onAccelerationUpdate = { [weak self] acceleration in
            self?.detectAcceleration(acceleration)
        }
        
        locationHandler.onRotationUpdate = { [weak self] rotationRate in
            self?.detectRotationWithAngle(rotationRate)
        }
    }
    
    // 检测加速度变化
    private func detectAcceleration(_ acceleration: CMAcceleration) {
        // 这里不再使用加速度传感器来判断加速或减速
    }
    
    // 检测旋转变化
    private var rotationSamples: [(time: TimeInterval, angle: Double)] = []
    private let windowDuration: TimeInterval = 3.0 // 窗口持续时间
    private var angleThresholds: (emergencyRight: Double, emergencyLeft: Double, right: Double, left: Double, straight: Double) = (45.0, -45.0, 15.0, -15.0, 5.0)

    private func detectRotationWithAngle(_ rotationRate: CMRotationRate) {
        let currentTime = Date().timeIntervalSince1970
        let currentAngle = rotationRate.z

        // 添加当前样本到窗口
        rotationSamples.append((time: currentTime, angle: currentAngle))

        // 移除超出窗口的样本
        rotationSamples.removeAll { currentTime - $0.time > windowDuration }

        // 计算窗口内的总旋转角度（基于时间加权）
        let totalRotationAngle = calculateTotalRotationAngle()

        // 判断行为
        evaluateRotationBehavior(totalRotationAngle)
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

        logMessage("Detected Behavior: \(detectedBehavior), Total Rotation Angle: \(totalRotationAngle)")
    }
    
    // 更新位置数据
    private func updateLocationData(location: CLLocation) {
        let filteredSpeed = kalmanFilter.filter(measurement: location.speed) // 使用卡尔曼滤波器平滑速度
        
        // 将速度从 m/s 转换为 km/h
        rawSpeed = location.speed * 3.6
        smoothedSpeed = filteredSpeed * 3.6
        
        // 更新当前速度
        currentSpeed = smoothedSpeed
        
        // 根据速度变化检测加速和减速
        let speedDifference = filteredSpeed - lastSpeed
        
        if speedDifference > 0 {
            if speedDifference > 2.0 { // 设定一个阈值来判断快速加速
                detectedBehavior = "快速加速"
            } else {
                detectedBehavior = "平稳加速"
            }
        } else if speedDifference < 0 {
            if speedDifference < -2.0 { // 设定一个阈值来判断快速减速
                detectedBehavior = "快速减速"
            } else {
                detectedBehavior = "平稳减速"
            }
        }
        
        logMessage(detectedBehavior) // 使用全局函数记录日志
        
        // 检测启动和停止
        if filteredSpeed > 0 && lastSpeed == 0 {
            detectedBehavior = "启动"
            logMessage(detectedBehavior) // 使用全局函数记录日志
        } else if filteredSpeed == 0 && lastSpeed > 0 {
            detectedBehavior = "停止"
            logMessage(detectedBehavior) // 使用全局函数记录日志
        }
        
        lastSpeed = filteredSpeed // 更新上一次的速度
        lastHeading = location.course // 更新上一次的方向
    }
}

// 简单的卡尔曼滤波器实现
class KalmanFilter {
    private var estimate: Double = 0.0 // 当前估计值
    private var errorEstimate: Double = 1.0 // 当前估计误差
    private let errorMeasure: Double = 0.1 // 测量误差
    private let q: Double = 0.1 // 过程噪声
    
    func filter(measurement: Double) -> Double {
        // 预测阶段
        let prediction = estimate
        let errorPrediction = errorEstimate + q
        
        // 更新阶段
        let k = errorPrediction / (errorPrediction + errorMeasure) // 计算卡尔曼增益
        estimate = prediction + k * (measurement - prediction) // 更新估计值
        errorEstimate = (1 - k) * errorPrediction // 更新估计误差
        
        return estimate
    }
}
