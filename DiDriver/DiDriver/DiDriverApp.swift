//
//  DiDriverApp.swift
//  DiDriver
//
//  Created by Yuan on 2024/12/2.
//

import SwiftUI

@main
struct DiDriverApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var locationHandler = LocationManagerHandler.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 检查应用是否因位置更新而启动
        if let _ = launchOptions?[.location] {
            // 处理后台位置启动逻辑
            logMessage("app 从后台启动")
        }
        return true
    }
}
