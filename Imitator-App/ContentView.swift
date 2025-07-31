//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var llamaState = LlamaState()
    @State private var selection: Tab = .sign
    
    enum Tab { case sign, chat }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 42/255, green: 54/255, blue: 70/255),
                    Color(red: 80/255, green: 90/255, blue: 110/255)  // customize your end color
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            TabView(selection: $selection) {
                CameraView()
                    .tabItem { Label("Sign", systemImage: "hand.raised.fill") }
                    .tag(Tab.sign)
                ChatView(llama: llamaState)
                    .tabItem { Label("Chat", systemImage: "message.fill") }
                    .tag(Tab.chat)
            }
        }
    }
}

struct ChatWithKeypointsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            ContentView()
               .previewDevice("iPhone 14 Pro")
        }
    }
}
