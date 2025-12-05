//
//  AIService.swift
//  HIG
//
//  AI service for chat with HIG knowledge context
//

import Foundation

// MARK: - AI Configuration

struct AIConfig: Codable, Equatable {
    var provider: AIProvider = .ollama
    var model: String = "llama3.2"
    var baseURL: String = "http://localhost:11434"
    var apiKey: String? = nil
    var maxTokens: Int = 2048
    var temperature: Double = 0.7
    
    // Web search settings
    var enableWebSearch: Bool = true
    var enableAppleDocs: Bool = true
    var enableSwiftDocs: Bool = true
    var enableGitHub: Bool = true
    
    enum AIProvider: String, CaseIterable, Identifiable, Codable {
        case ollama = "Ollama (Local)"
        case openai = "OpenAI"
        case anthropic = "Anthropic"
        
        var id: String { rawValue }
    }
    
    // MARK: - Persistence
    
    private static let configKey = "aiConfig"
    
    /// Save configuration to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.configKey)
        }
    }
    
    /// Load configuration from UserDefaults
    static func load() -> AIConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(AIConfig.self, from: data) else {
            return AIConfig()
        }
        return config
    }
}

// MARK: - Chat Message

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: Role
    let content: String
    let timestamp: Date
    let context: [String]? // HIG topics used as context
    var rating: FeedbackRating? // User feedback rating
    
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }
    
    enum FeedbackRating: String, Codable {
        case thumbsUp
        case thumbsDown
    }
    
    init(role: Role, content: String, context: [String]? = nil, rating: FeedbackRating? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.context = context
        self.rating = rating
    }
}

// MARK: - AI Service

@MainActor
@Observable
class AIService {
    var config = AIConfig() {
        didSet {
            config.save()
        }
    }
    var isProcessing = false
    var error: String?
    
    private let knowledgeBase: HIGKnowledgeBase
    
    init(knowledgeBase: HIGKnowledgeBase) {
        self.knowledgeBase = knowledgeBase
        self.config = AIConfig.load()
    }
    
    @MainActor convenience init() {
        self.init(knowledgeBase: HIGKnowledgeBase.shared)
    }
    
    // MARK: - Chat
    
    func chat(messages: [ChatMessage], query: String) async -> ChatMessage? {
        isProcessing = true
        error = nil
        defer { isProcessing = false }
        
        do {
            // Retrieve knowledge from multiple sources
            let retriever = KnowledgeRetriever()
            let retrievedKnowledge = await retriever.retrieve(query: query, limit: 5)
            
            // Also search local HIG knowledge base
            let relevantTopics = knowledgeBase.search(query: query, limit: 3)
            
            // Build comprehensive context
            let context = buildHybridContext(
                localTopics: relevantTopics,
                retrievedKnowledge: retrievedKnowledge
            )
            
            // Build messages with context
            var allMessages = messages
            
            // Add system message with hybrid context
            let systemMessage = ChatMessage(
                role: .system,
                content: buildSystemPrompt(context: context)
            )
            allMessages.insert(systemMessage, at: 0)
            
            // Add user message
            allMessages.append(ChatMessage(role: .user, content: query))
            
            // Call AI provider
            let response = try await callProvider(messages: allMessages)
            
            // Include sources in response
            let sourcesInfo = buildSourcesInfo(retrievedKnowledge: retrievedKnowledge)
            let responseWithSources = response + "\n\n" + sourcesInfo
            
            return ChatMessage(
                role: .assistant,
                content: responseWithSources,
                context: relevantTopics.map { $0.id }
            )
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Context Building
    
    private func buildSystemPrompt(context: String) -> String {
        """
        You are an expert Apple platform developer assistant.
        
        **Your Knowledge Sources:**
        1. **User's Local Context** (PRIORITY): Their project documentation, notes, and code
        2. **Official Documentation**: Apple Developer, Swift.org (for authoritative knowledge)
        3. **GitHub Examples**: Only when user wants to build/create something
        
        **How to Use Sources:**
        - **Context**: Use local docs to understand the user's project and codebase
        - **Knowledge**: Get facts, APIs, and guidelines from Apple/Swift.org
        - **Examples**: Show GitHub code only when user asks to create/build/implement
        
        **Response Guidelines:**
        - Start with user's local context if available
        - Reference official Apple/Swift docs for technical accuracy
        - Include GitHub examples ONLY for "how to build" questions
        - Provide SwiftUI/Swift code examples following Apple's guidelines
        - Consider all Apple platforms (iOS, macOS, visionOS, watchOS, tvOS)
        - Emphasize accessibility and best practices
        - Always cite sources with clickable links
        
        **Available Context:**
        \(context)
        
        Be helpful, accurate, and trust official sources over community content.
        """
    }
    
    private func buildContext(from topics: [HIGTopic]) -> String {
        topics.map { topic in
            """
            ## \(topic.title)
            Category: \(topic.displayCategory)
            \(topic.abstract)
            
            \(topic.sections.prefix(2).map { section in
                if section.heading.isEmpty { return "" }
                let content = section.content.compactMap { $0.text }.joined(separator: "\n")
                return "### \(section.heading)\n\(content.prefix(500))"
            }.joined(separator: "\n"))
            """
        }.joined(separator: "\n\n---\n\n")
    }
    
    private func buildHybridContext(localTopics: [HIGTopic], retrievedKnowledge: [RetrievedKnowledge]) -> String {
        var context = ""
        
        // Add local documentation
        if !localTopics.isEmpty {
            context += "## Local Documentation\n\n"
            context += buildContext(from: localTopics)
            context += "\n\n"
        }
        
        // Add web-retrieved knowledge
        if !retrievedKnowledge.isEmpty {
            context += "## External References\n\n"
            for knowledge in retrievedKnowledge {
                context += """
                ### \(knowledge.sourceLabel) - \(knowledge.title)
                \(knowledge.content.prefix(500))
                
                """
            }
        }
        
        return context
    }
    
    private func buildSourcesInfo(retrievedKnowledge: [RetrievedKnowledge]) -> String {
        guard !retrievedKnowledge.isEmpty else { return "" }
        
        var sources = "---\n\n**Sources:**\n"
        for knowledge in retrievedKnowledge {
            if let url = knowledge.url {
                sources += "- \(knowledge.sourceLabel) [\(knowledge.title)](\(url))\n"
            } else {
                sources += "- \(knowledge.sourceLabel) \(knowledge.title)\n"
            }
        }
        
        return sources
    }
    
    // MARK: - Provider Calls
    
    private func callProvider(messages: [ChatMessage]) async throws -> String {
        switch config.provider {
        case .ollama:
            do {
                return try await callOllama(messages: messages)
            } catch {
                // If Ollama fails, fall back to local knowledge base response
                return generateLocalResponse(messages: messages)
            }
        case .openai:
            return try await callOpenAI(messages: messages)
        case .anthropic:
            return try await callAnthropic(messages: messages)
        }
    }
    
    // MARK: - Local Fallback
    
    /// Generates a response using only the local HIG knowledge base (no AI required)
    private func generateLocalResponse(messages: [ChatMessage]) -> String {
        guard let userMessage = messages.last(where: { $0.role == .user }) else {
            return "I'm sorry, I couldn't process your question."
        }
        
        let query = userMessage.content
        let relevantTopics = knowledgeBase.search(query: query, limit: 3)
        
        if relevantTopics.isEmpty {
            return """
            I couldn't find specific HIG guidance for "\(query)".
            
            **Note:** This app works best with Ollama running locally. To enable AI-powered responses:
            
            1. Install Ollama from https://ollama.ai
            2. Run: `ollama pull llama3.2`
            3. Restart DocuChat
            
            In the meantime, try browsing the HIG topics in the sidebar or searching for specific terms.
            """
        }
        
        // Build a response from the knowledge base
        var response = "Based on the Apple Human Interface Guidelines:\n\n"
        
        for (index, topic) in relevantTopics.enumerated() {
            response += "**\(index + 1). \(topic.title)**\n"
            response += "\(topic.abstract)\n\n"
            
            // Add first section if available
            if let firstSection = topic.sections.first, !firstSection.heading.isEmpty {
                response += "**\(firstSection.heading)**\n"
                if let firstContent = firstSection.content.first?.text {
                    response += "\(firstContent.prefix(300))...\n\n"
                }
            }
        }
        
        response += """
        
        ---
        
        **💡 Tip:** For AI-powered responses with code examples and detailed guidance, install Ollama locally:
        
        1. Download from https://ollama.ai
        2. Run: `ollama pull llama3.2`
        3. Restart DocuChat
        
        Click on the topic tags above to view full HIG documentation.
        """
        
        return response
    }
    
    // MARK: - Ollama
    
    private func callOllama(messages: [ChatMessage]) async throws -> String {
        let url = URL(string: "\(config.baseURL)/api/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": config.model,
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
            "stream": false,
            "options": [
                "temperature": config.temperature,
                "num_predict": config.maxTokens
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let message = json?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - OpenAI
    
    private func callOpenAI(messages: [ChatMessage]) async throws -> String {
        guard let apiKey = config.apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": config.model.isEmpty ? "gpt-4" : config.model,
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
            "max_tokens": config.maxTokens,
            "temperature": config.temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Anthropic
    
    private func callAnthropic(messages: [ChatMessage]) async throws -> String {
        guard let apiKey = config.apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        // Anthropic uses separate system parameter
        let systemMessage = messages.first { $0.role == .system }?.content ?? ""
        let chatMessages = messages.filter { $0.role != .system }
        
        let body: [String: Any] = [
            "model": config.model.isEmpty ? "claude-3-sonnet-20240229" : config.model,
            "system": systemMessage,
            "messages": chatMessages.map { ["role": $0.role.rawValue, "content": $0.content] },
            "max_tokens": config.maxTokens
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = json?["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw AIError.invalidResponse
        }
        
        return text
    }
}

// MARK: - Errors

enum AIError: LocalizedError {
    case requestFailed
    case invalidResponse
    case missingAPIKey
    case ollamaNotRunning
    
    var errorDescription: String? {
        switch self {
        case .requestFailed: 
            return "Request to AI service failed. Check your connection and settings."
        case .invalidResponse: 
            return "Invalid response from AI service"
        case .missingAPIKey: 
            return "API key is required for this provider"
        case .ollamaNotRunning:
            return "Ollama is not running. Install from https://ollama.ai and run 'ollama pull llama3.2'"
        }
    }
}

