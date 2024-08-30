//
// SearchResultConversation.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct SearchResultConversation: Codable {

    public var answer: String
    public var conversationHistory: [String: String]
    public var conversationId: String
    public var query: String

    public init(answer: String, conversationHistory: [String: String], conversationId: String, query: String) {
        self.answer = answer
        self.conversationHistory = conversationHistory
        self.conversationId = conversationId
        self.query = query
    }

    public enum CodingKeys: String, CodingKey {
        case answer
        case conversationHistory = "conversation_history"
        case conversationId = "conversation_id"
        case query
    }

}
