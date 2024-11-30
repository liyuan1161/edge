//
//  Swift01App.swift
//  Swift01
//
//  Created by Yuan on 2024/11/30.
//

import SwiftUI

@main
struct Swift01App: App {
    var body: some Scene {
        DocumentGroup(newDocument: Swift01Document()) { file in
            ContentView(document: file.$document)
        }
    }
}
