//
//  ChatView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var llama = LlamaState()
    @State private var userInput: String = ""
    @State private var isSending = false

    var body: some View {
        VStack {
            // 1. Scrollable log of the conversation
            ScrollViewReader { scroll in
                ScrollView {
                    Text(llama.messageLog)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .id("LOG_BOTTOM")
                }
                .onChange(of: llama.messageLog) { _ in
                    // scroll to bottom whenever new text arrives
                    withAnimation {
                        scroll.scrollTo("LOG_BOTTOM", anchor: .bottom)
                    }
                }
            }
            .background(Color(white: 0.95))
            .cornerRadius(8)
            .padding()

            // 2. Input field & send button
            HStack {
                TextField("Type a message…", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isSending)
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .padding(8)
                }
                .disabled(isSending || userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Chat with LLM")
    }


    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSending = true
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        userInput = ""
        Task {
            await llama.complete(text: text)
            isSending = false
        }
    }
}
