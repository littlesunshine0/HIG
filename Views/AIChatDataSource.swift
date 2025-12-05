//
//  AIChatDataSource.swift
//  HIG
//
//  Simple data source that can be replaced with a real AI backend call.
//

import Foundation

final class AIChatDataSource: ChatDataSource {
    func send(message: String) async -> String {
        // TODO: Replace with your backend integration.
        // For now, return a canned response.
        return "AI: I received “\(message)”. How can I help further?"
    }
}
