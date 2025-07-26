//
//  Imitator_AppApp.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

@main
struct Imitator_AppApp: App {
    // This init runs once when the app launches
    init() {
        seedDummyFile()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func seedDummyFile() {
        let docsURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testURL = docsURL.appendingPathComponent("README.txt")

        // Only write if the file doesn’t already exist
        guard !FileManager.default.fileExists(atPath: testURL.path) else {
            return
        }
        do {
            try "Hello".write(
                to: testURL,
                atomically: true,
                encoding: .utf8
            )
            print("Test file created at \(testURL)")
        } catch {
            print("Failed to write test file:", error)
        }
    }
}
