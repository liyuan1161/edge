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
    private var locationHandler = LocationManagerHandler()
    private var logger = Logger()
    
    // 用于存储上一次的速度和方向
    private var lastSpeed: CLLocationSpeed = 0.0
    private var lastHeading: CLLocationDirection = 0.0
    
    // 时间窗口
    private var speedWindow: [CLLocationSpeed] = []
    private var headingWindow: [CLLocationDirection] = []
    private let windowSize = 5 // 5秒的时间窗口
    
    // 卡尔曼滤波器参数
    private var kalmanFilter: KalmanFilter = KalmanFilter()
    
    // 用于发布检测到的行为
    @Published var detectedBehavior: String = "等待检测..."
    
    init() {
        // 初始化代码
    }
    
    // 检测加速度变化
    private func detectAcceleration(_ acceleration: CMAcceleration) {
        // 加速度阈值
        let stableAccelerationThreshold: Double = 2.0 // m/s²
        let fastAccelerationThreshold: Double = 4.0 // m/s²
        let rapidAccelerationThreshold: Double = 6.0 // m/s²
        
        // 减速度阈值
        let mildDecelerationThreshold: Double = -4.0 // m/s²
        let strongDecelerationThreshold: Double = -6.0 // m/s²
        
        // 计算加速度的大小
        let magnitude = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
        
        // 加速检测
        if magnitude > rapidAccelerationThreshold {
            detectedBehavior = "赛车级加速"
        } else if magnitude > fastAccelerationThreshold {
            detectedBehavior = "急加速"
        } else if magnitude > stableAccelerationThreshold {
            detectedBehavior = "快速加速"
        } else if magnitude > 0 {
            detectedBehavior = "平稳加速"
        }
        
        // 减速检测
        if acceleration.x < strongDecelerationThreshold || acceleration.y < strongDecelerationThreshold || acceleration.z < strongDecelerationThreshold {
            detectedBehavior = "紧急刹车"
        } else if acceleration.x < mildDecelerationThreshold || acceleration.y < mildDecelerationThreshold || acceleration.z < mildDecelerationThreshold {
            detectedBehavior = "减速"
        }
        
        logger.log(detectedBehavior) // 记录日志
    }
    
    // 检测旋转变化
    private func detectRotation(_ rotationRate: CMRotationRate) {
        let threshold: Double = 10.0 // 每秒度数，转弯的阈值
        if rotationRate.z > threshold {
            detectedBehavior = "右拐弯"
            logger.log(detectedBehavior) // 记录日志
        } else if rotationRate.z < -threshold {
            detectedBehavior = "左拐弯"
            logger.log(detectedBehavior) // 记录日志
        }
    }
    
    // 更新位置数据
    func updateLocationData(speed: CLLocationSpeed, heading: CLLocationDirection) {
        let filteredSpeed = kalmanFilter.filter(measurement: speed) // 使用卡尔曼滤波器平滑速度
        
        // 检测启动和停止
        if filteredSpeed > 0 && lastSpeed == 0 {
            detectedBehavior = "启动"
            logger.log(detectedBehavior) // 记录日志
        } else if filteredSpeed == 0 && lastSpeed > 0 {
            detectedBehavior = "停止"
            logger.log(detectedBehavior) // 记录日志
        }
        
        lastSpeed = filteredSpeed // 更新上一次的速度
        lastHeading = heading // 更新上一次的方向
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