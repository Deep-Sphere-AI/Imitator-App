//
//  ChatViewModel.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        .init(role: .system, content: "You are a helpful assistant.")
    ]
    @Published var userInput: String = ""
    @Published var isSending = false

    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "<#Your OpenAI API Key#>"

    func sendMessage() async {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = ChatMessage(role: .user, content: userInput)
        messages.append(userMsg)
        userInput = ""
        isSending = true

        // Prepare request payload
        struct RequestBody: Codable {
            let model: String
            let messages: [ChatMessage]
        }
        let body = RequestBody(model: "gpt-4o-mini", messages: messages)

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let data = try? JSONEncoder().encode(body)
        else {
            isSending = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        do {
            let (responseData, _) = try await URLSession.shared.data(for: request)
            struct Response: Codable {
                struct Choice: Codable {
                    struct Msg: Codable {
                        let role: String
                        let content: String
                    }
                    let message: Msg
                }
                let choices: [Choice]
            }
            let decoded = try JSONDecoder().decode(Response.self, from: responseData)
            if let reply = decoded.choices.first?.message {
                let assistantMsg = ChatMessage(role: .assistant, content: reply.content)
                messages.append(assistantMsg)
            }
        } catch {
            let errorMsg = ChatMessage(role: .assistant,
                                       content: "❌ Error: \(error.localizedDescription)")
            messages.append(errorMsg)
        }
        isSending = false
    }
}
