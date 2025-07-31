//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var llamaState = LlamaState()
    @State private var selection: Tab = .sign
    @State private var keyboardHeight: CGFloat = 0
    
    private var keyboardPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { $0.height },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }

    
    enum Tab { case sign, chat }
    
    var body: some View {
        ZStack {
            Color("AccentColor")
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
        .onReceive(keyboardPublisher) { height in
            self.keyboardHeight = height
        }

    }
}
