//
//  Logger.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

func logMessage(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    let log = "[\(level.rawValue)] [\(fileName):\(function):\(line)] \(message)"
    
    #if DEBUG
    if level == .debug {
        print(log)
        return
    }
    #endif
    
    Logger.shared.log(log)
}

class Logger {
    static let shared = Logger() // 单例实例
    
    private var logFileURL: URL
    private let logQueue = DispatchQueue(label: "com.example.logger", qos: .background)
    private var logBuffer: [String] = [] // 缓冲区，用于暂存日志消息
    private let bufferLimit = 10 // 缓冲区大小限制

    private init() {
        logFileURL = Logger.getLogFileURL() // 使用静态方法获取日志文件路径
        
        // 初始化日志文件，如果文件不存在则创建
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: logFileURL.path) {
            fileManager.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }
    }
    
    // 记录日志消息
    func log(_ message: String) {
        logQueue.async { [weak self] in
            guard let self = self else { return }
            let timestamp = self.currentTimestamp()
            let logMessage = "[\(timestamp)] \(message)\n"
            self.logBuffer.append(logMessage) // 将日志消息添加到缓冲区
            
            // 如果缓冲区达到限制，执行写入操作
            if self.logBuffer.count >= self.bufferLimit {
                self.flush()
            }
        }
    }
    
    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale.current // 使用当前设备的地区设置
        return formatter.string(from: Date())
    }
    
    // 获取当前日期的日志文件路径
    private static func getLogFileURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 日期格式
        let dateString = dateFormatter.string(from: Date())
        let fileName = "DrivingBehaviorLog-\(dateString).txt" // 以日期命名的文件名
        return urls[0].appendingPathComponent(fileName)
    }
    
    // 将缓冲区中的日志消息写入文件
    private func flush() {
        let logMessages = logBuffer.joined() // 合并缓冲区中的消息
        logBuffer.removeAll() // 清空缓冲区
        
        if let data = logMessages.data(using: .utf8) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile() // 移动到文件末尾
                fileHandle.write(data) // 写入数据
                fileHandle.closeFile() // 关闭文件
            } else {
                // 如果文件无法打开，创建新文件
                try? data.write(to: logFileURL)
            }
        }
    }
}
