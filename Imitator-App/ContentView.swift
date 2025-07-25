//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var llamaState = LlamaState()
    @State private var multiLineText = ""
    
    var body: some View {
        VStack {
            Text(llamaState.messageLog)
                .padding()
                .task {
                    sendText()
                }
        }
    }
    
    func sendText() {
        Task {
            await llamaState.complete(text: "What is the meaning of life?")
            multiLineText = ""
        }
    }
}

#Preview {
    ContentView()
}
