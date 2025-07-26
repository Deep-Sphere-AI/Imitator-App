//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    //@StateObject private var llamaState = LlamaState()
    //@State private var multiLineText = ""
    
    var body: some View {
        Group {
            if hSizeClass == .regular {
                //iPad Mode
                HStack {
                    VStack {
                        ChatView()
                            .frame(maxWidth: .infinity)
                    }
                    CameraSignView()
                        .frame(maxWidth: .infinity)
                }
            } else {
                //iPhone Mode
                VStack {
                    ChatView()
                        .frame(maxHeight: .infinity)
                    CameraSignView()
                        .frame(maxHeight: .infinity)

                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ChatView: View {
    var body: some View {
        Color.blue
            .overlay(Text("Chat").foregroundColor(.white))
    }
}

struct CameraSignView: View {
    var body: some View {
        Color.green
            .overlay(Text("Camera").foregroundColor(.white))
    }
}

//        VStack {
//            Text(llamaState.messageLog)
//                .padding()
//                .task {
//                    sendText()
//                }
//        }
    
    
//    func sendText() {
//        Task {
//            await llamaState.complete(text: "What is the meaning of life?")
//            multiLineText = ""
//        }
//    }


struct ChatWithKeypointsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPad Pro (11-inch)")
                .previewDisplayName("iPad")

            ContentView()
                .previewDevice("iPhone 14")
                .previewDisplayName("iPhone")
        }
    }
}
