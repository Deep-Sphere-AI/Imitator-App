//
//  ChatView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var llama: LlamaState
    @State private var inputText: String = ""
    @FocusState private var isInputActive: Bool
    
    var body: some View {
      VStack {
        ScrollViewReader { scroll in
          ScrollView {
            VStack(spacing: 8) {
              ForEach(llama.messages) { msg in
                ChatBubble(message: msg)
              }
            }
            .padding(.vertical, 12)
            .id("LOG_BOTTOM")
          }
          .onChange(of: llama.messages.count) { _ in
            withAnimation {
              scroll.scrollTo("LOG_BOTTOM", anchor: .bottom)
            }
          }
        }

          HStack {
              TextField("Type a message…", text: $inputText)
                  .focused($isInputActive)        // ②
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .onSubmit { send() }            // ③

              Button(action: send) {
                  Image(systemName: "paperplane.fill")
                      .rotationEffect(.degrees(45))
              }
              .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
          }
          .padding()
          .background(Color(.secondarySystemBackground))
      }
    }

    private func send() {
        let msg = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !msg.isEmpty else { return }
        Task { await llama.complete(text: msg) }
        inputText = ""
        isInputActive = false          // ④ this collapses the keyboard
      }
    }

struct ChatBubble: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.role == .assistant { Spacer() }
      Text(message.content)
        .padding(12)
        .background(
          message.role == .user
            ? Color.accentColor
            : Color(.secondarySystemBackground)
        )
        .foregroundColor(
          message.role == .user ? .white : .primary
        )
        .cornerRadius(16)
        .frame(maxWidth: .infinity,
               alignment: message.role == .user ? .trailing : .leading)
      if message.role == .user { Spacer() }
    }
    .padding(.horizontal, 8)
  }
}
