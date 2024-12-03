//
//  KalmanFilter.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/3.
//

import Foundation

class KalmanFilter {
    private var estimate: Double = 0.0
    private var errorEstimate: Double = 1.0
    private var errorMeasure: Double = 0.1
    private var q: Double = 0.1

    func filter(measurement: Double) -> Double {
        let prediction = estimate
        let errorPrediction = errorEstimate + q

        let k = errorPrediction / (errorPrediction + errorMeasure)
        estimate = prediction + k * (measurement - prediction)
        errorEstimate = (1 - k) * errorPrediction

        return estimate
    }
}