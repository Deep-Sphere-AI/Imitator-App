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
    @Published var messageLog = ""
    
    private var llamaContext: LlamaContext?
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
        do {
            try loadModel(modelUrl: defaultModelUrl)
        } catch {
            messageLog += "Failed to load default model.\n"
        }
    }
    
    func loadModel(modelUrl: URL?) throws {
        if let modelUrl {
            messageLog += "Loading model...\n"
            llamaContext = try LlamaContext.create_context(path: modelUrl.path)
            messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
        } else {
            messageLog += "No model specified.\n"
        }
    }
    
    func complete(text: String) async {
        guard let llamaContext else {
            return
        }
        
        await llamaContext.completion_init(text: text)
        
        messageLog += "\(text)"
        
        Task.detached {
            while await !llamaContext.is_done {
                let result = await llamaContext.completion_loop()
                await MainActor.run {
                    self.messageLog += "\(result)"
                }
            }
            
            await llamaContext.clear()

            await MainActor.run {
                self.messageLog += """
                    Done
                    """
            }
        }
    }
    
    func clear() async {
        guard let llamaContext else {
            return
        }
        
        await llamaContext.clear()
        messageLog = ""
    }
}
