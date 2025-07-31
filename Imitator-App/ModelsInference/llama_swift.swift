//
//  llama_swfit.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//
import SwiftUI
import Foundation
import Combine

@MainActor
class LlamaState: ObservableObject {
    private var ctx: LlamaContext?
    @Published var messages: [ChatMessage] = []
    var systemPrompt: String = "You are a helpful AI assistant. Answer as helpfully as possible."
    
    private func ensureSystemPrompt() {
            if messages.first?.role != .system {
                messages.insert(ChatMessage(role: .system, content: systemPrompt), at: 0)
            }
    }
    
    func formatForGemma(messages: [ChatMessage], addGenerationPrompt: Bool = true) -> String {
        var result = "<bos>\n"
        var firstUserPrefix = ""
        var loopMessages = messages

        // Handle system message at beginning
        if let first = messages.first, first.role == .system {
            firstUserPrefix = first.content + "\n\n"
            loopMessages = Array(messages.dropFirst())
        }

        for (i, message) in loopMessages.enumerated() {
            // Enforce alternation: user/assistant/user/assistant...
            let expectedRole: ChatRole = (i % 2 == 0) ? .user : .assistant
            if message.role != expectedRole {
                // Skip or throw an error if conversation roles do not alternate
                print("Conversation roles must alternate user/assistant/user/assistant/...")
                continue
            }
            // Use "model" instead of "assistant" as per template
            let role = (message.role == .assistant) ? "model" : message.role.rawValue
            result += "<start_of_turn>\(role)\n"
            // Only prefix the first user message with the system content, if present
            if i == 0 && !firstUserPrefix.isEmpty {
                result += firstUserPrefix
            }
            result += message.content.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
            result += "<end_of_turn>\n"
        }
        if addGenerationPrompt {
            result += "<start_of_turn>model\n"
        }
        return result
    }
    
    private var defaultModelUrl: URL? {
        // 1. Locate the Documents directory
        let docsURL = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        
        // 2. Append your model’s filename
        let modelURL = docsURL.appendingPathComponent("gemma-3n-E2B-it-Q4_K_M.gguf")
        
        // 3. Return it if the file actually exists
        return FileManager.default.fileExists(atPath: modelURL.path)
            ? modelURL
            : nil
    }

    init() {
        loadDefaultModel()
    }
    
    private func loadDefaultModel() {
        guard let modelUrl = defaultModelUrl else {
            print("No default model URL found.")
            return
        }

        do {
            ctx = try LlamaContext.create_context(path: modelUrl.path)
            print("Loaded default model: \(modelUrl.lastPathComponent)")
        } catch {
            print("Failed to load default model:", error)
        }
    }

    
    func complete(text: String) async {
        guard let ctx = ctx else { return }

        await MainActor.run { ensureSystemPrompt() }

        let userMsg = ChatMessage(role: .user, content: text)
        await MainActor.run { messages.append(userMsg) }
                
        let prompt = formatForGemma(messages: messages)
        
        await ctx.completion_init(text: prompt)

        let assistantIndex = messages.count
        await MainActor.run { messages.append(.init(role: .assistant, content: "")) }

        Task.detached {
          while await !ctx.is_done {
            let chunk = await ctx.completion_loop()
            await MainActor.run {
              self.messages[assistantIndex].content += chunk
            }
          }
          await ctx.clear()
        }
      }

    func clear() {
        Task { @MainActor in
          self.messages.removeAll()
        }
      }
}
