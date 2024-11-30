//
//  ContentView.swift
//  Swift01
//
//  Created by Yuan on 2024/11/30.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Swift01Document

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(Swift01Document()))
}
