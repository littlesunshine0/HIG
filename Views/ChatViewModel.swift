//
//  ChatViewModel.swift
//  HIG
//
//  State holder for chat overlay and a pluggable data source.
//

import Foundation
import SwiftUI
import Combine
protocol ChatDataSource {
    func send(message: String) async -> String
}

final class ChatViewModel: ObservableObject {
    enum Tab: String, CaseIterable, Identifiable { case chat = "Chat", knowledge = "Knowledge", tasks = "Tasks"; var id: String { rawValue } }

    @Published var isExpanded: Bool = false {
        didSet {
            if isExpanded {
                unreadCount = 0
            }
        }
    }
    @Published var unreadCount: Int = 0
    @Published var messages: [Message] = []
    @Published var input: String = ""
    @Published var activeTab: Tab = .chat

    var dataSource: ChatDataSource?

    struct Message: Identifiable, Hashable {
        enum Role { case user, assistant }
        let id = UUID()
        let role: Role
        let text: String
        let date: Date
    }

    func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = Message(role: .user, text: trimmed, date: .now)
        messages.append(userMsg)
        input = ""

        Task { [weak self] in
            guard let self else { return }
            if let dataSource = self.dataSource {
                let reply = await dataSource.send(message: trimmed)
                await MainActor.run {
                    self.messages.append(Message(role: .assistant, text: reply, date: .now))
                    if !self.isExpanded { self.unreadCount += 1 }
                }
            } else {
                await MainActor.run {
                    self.messages.append(Message(role: .assistant, text: "(stub) Received: \(trimmed)", date: .now))
                    if !self.isExpanded { self.unreadCount += 1 }
                }
            }
        }
    }
}
