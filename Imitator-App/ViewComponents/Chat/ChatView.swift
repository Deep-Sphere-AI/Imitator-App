//
//  ChatView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var vm = ChatViewModel()

    var body: some View {
        VStack {
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { msg in
                            HStack {
                                if msg.role == .assistant { Spacer() }
                                Text(msg.content)
                                    .padding(10)
                                    .background(msg.role == .user
                                                ? Color.blue.opacity(0.2)
                                                : Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                if msg.role == .user { Spacer() }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _ in
                    if let last = vm.messages.last {
                        scroll.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Type a message…", text: $vm.userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(vm.isSending)
                Button(action: {
                    Task { await vm.sendMessage() }
                }) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                }
                .disabled(vm.isSending || vm.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat with LLM")
    }
}
