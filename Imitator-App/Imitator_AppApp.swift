//
//  Imitator_AppApp.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI
import llama

actor LLMModel {
    private var state: LlmState?
    
    @LlmActor
    func load(at modelPath: String) async throws {
        let params = CommonParams(seed: UInt32.random(in: UInt32.min...UInt32.max))
        let state = try? LlmState.create(modelPath: modelPath, params: params)
    }
    
    func run(prompt: String) async throws -> String {
        guard let state  = state else {
            throw NSError(domain: "GemmaModel", code:1,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        var output = ""
        for try await token in await state.predict(text:prompt) {
            output += token
        }
        return output
    }
}

@main
struct Imitator_AppApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
