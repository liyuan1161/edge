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
}
