//
//  Global.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import Foundation

func logMessage(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    let log = "[\(fileName):\(function):\(line)] \(message)"
    Logger.shared.log(log)
}
