//
//  ChatMessage.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import Foundation
import Combine

struct ChatMessage: Identifiable, Codable {
    enum Role: String, Codable {
        case system, user, assistant
    }

    let id = UUID()
    let role: Role
    let content: String
}
