//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var result: String = "Loading.."
    let model = LLMModel()
    
    var body: some View {
        VStack {
            Text(result)
                .padding()
                .task{
                    do {
                        if let resourcePath = Bundle.main.resourcePath {
                            let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath)
                            print("Bundle resources:", files ?? [])
                        }
                        
                        guard let url = Bundle.main.url(
                            forResource: "gemma-3n-E2B-it-Q4_K_M",
                            withExtension: "gguf",
                        ) else {
                            result = "❌ Model file missing"
                            return
                        }
                    
                        try await model.load(at: url.path)
                    
                        result = try await model.run(prompt: "What is the meaning of life?")
                } catch {
                    result = "Error: \(error)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
