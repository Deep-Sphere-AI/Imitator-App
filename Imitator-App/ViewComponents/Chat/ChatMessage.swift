//
//  ChatMessage.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/29/25.
//

import Foundation

enum ChatRole: String, Codable {
  case system, user, assistant
}

struct ChatMessage: Identifiable, Codable {
  let id = UUID()
  let role: ChatRole
  var content: String
}
