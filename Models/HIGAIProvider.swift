//
//  HIGAIProvider.swift
//  HIG
//
//  AIProvider implementation that uses HIG knowledge base
//

import SwiftUI
import Combine

// MARK: - AI Protocol Definitions

/// Protocol for AI providers
protocol AIProvider: AnyObject {
    func ask(query: String, context: AIContext?) async throws -> AIResponse
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error>
    func executeAction(_ action: AIAction) async throws -> AIActionResult
}

/// AI context for queries
struct AIContext {
    let currentFile: String?
    let selectedText: String?
    let projectContext: String?
}

/// AI response from provider
struct AIResponse {
    let message: String
    let canGenerate: Bool
    let suggestedActions: [AIAction]
    let codeBlocks: [CodeBlock]
}

/// Action that AI can suggest
struct AIAction: Identifiable {
    let id: String
    let label: String
    let icon: String
    let metadata: [String: Any]?
    
    init(id: String, label: String, icon: String, metadata: [String: Any]? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
        self.metadata = metadata
    }
}

/// Result of executing an AI action
enum AIActionResult {
    case success(message: String)
    case failure(error: String)
}


/// AI suggestion for quick actions
struct AISuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

@MainActor
final class HIGAIProvider: ObservableObject {
    
    // MARK: - Properties
    
    @Published var suggestions: [AISuggestion] = []
    @Published var showAIPanel: Bool = true
    
    private let knowledgeBase: HIGKnowledgeBase
    private let ollamaURL: String
    private let model: String
    
    // MARK: - Initialization
    
    init(
        knowledgeBase: HIGKnowledgeBase,
        ollamaURL: String = "http://localhost:11434",
        model: String = "llama3.2"
    ) {
        self.knowledgeBase = knowledgeBase
        self.ollamaURL = ollamaURL
        self.model = model
        
        // Set up HIG-specific suggestions
        self.suggestions = Self.higSuggestions
    }
    
    @MainActor convenience init(
        ollamaURL: String = "http://localhost:11434",
        model: String = "llama3.2"
    ) {
        self.init(knowledgeBase: HIGKnowledgeBase.shared, ollamaURL: ollamaURL, model: model)
    }
    
    // MARK: - Default Suggestions
    
    static let higSuggestions: [AISuggestion] = [
        AISuggestion(
            title: "Design buttons",
            description: "HIG best practices for buttons",
            icon: "hand.tap"
        ),
        AISuggestion(
            title: "Color guidelines",
            description: "Using color effectively",
            icon: "paintpalette"
        ),
        AISuggestion(
            title: "Accessibility tips",
            description: "Make your app accessible",
            icon: "accessibility"
        ),
        AISuggestion(
            title: "Dark mode support",
            description: "Implement dark mode properly",
            icon: "moon.fill"
        ),
        AISuggestion(
            title: "Navigation patterns",
            description: "HIG navigation best practices",
            icon: "arrow.triangle.branch"
        ),
        AISuggestion(
            title: "Generate SwiftUI code",
            description: "Create HIG-compliant components",
            icon: "wand.and.stars"
        )
    ]
    
    // MARK: - AIProvider Implementation
    
    func ask(query: String, context: AIContext?) async throws -> AIResponse {
        // Find relevant HIG topics
        let relevantTopics = knowledgeBase.search(query: query, limit: 5)
        let higContext = buildHIGContext(from: relevantTopics)
        
        // Build the prompt with HIG context
        let systemPrompt = buildSystemPrompt(higContext: higContext)
        let fullPrompt = "\(systemPrompt)\n\nUser Question: \(query)"
        
        // Call Ollama
        let response = try await callOllama(prompt: fullPrompt, query: query)
        
        // Extract code blocks if any
        let codeBlocks = extractCodeBlocks(from: response)
        
        // Build suggested actions based on response
        let actions = buildSuggestedActions(from: relevantTopics)
        
        return AIResponse(
            message: response,
            canGenerate: !codeBlocks.isEmpty,
            suggestedActions: actions,
            codeBlocks: codeBlocks
        )
    }
    
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // Find relevant HIG topics
                    let relevantTopics = self.knowledgeBase.search(query: query, limit: 5)
                    let higContext = self.buildHIGContext(from: relevantTopics)
                    
                    // Build the prompt
                    let systemPrompt = self.buildSystemPrompt(higContext: higContext)
                    
                    // Stream from Ollama
                    try await self.streamFromOllama(
                        systemPrompt: systemPrompt,
                        query: query,
                        continuation: continuation
                    )
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func executeAction(_ action: AIAction) async throws -> AIActionResult {
        // Handle HIG-specific actions
        switch action.id {
        case "view_topic":
            if let topicId = action.metadata?["topicId"] as? String {
                return .success(message: "Opening topic: \(topicId)")
            }
        case "generate_code":
            return .success(message: "Code generation initiated")
        default:
            break
        }
        return .success(message: "Action executed: \(action.label)")
    }
    
    // MARK: - Context Building
    
    private func buildSystemPrompt(higContext: String) -> String {
        """
        You are an expert Apple Human Interface Guidelines (HIG) assistant. \
        Your role is to help developers build great Apple platform apps by providing \
        guidance based on HIG best practices.
        
        IMPORTANT GUIDELINES:
        - Always reference specific HIG guidelines when relevant
        - Provide SwiftUI code examples that follow HIG principles
        - Consider all Apple platforms (iOS, macOS, visionOS, watchOS, tvOS)
        - Emphasize accessibility and inclusive design
        - Use semantic system colors and SF Symbols
        - Follow platform conventions
        
        When providing code:
        - Use SwiftUI with modern syntax
        - Include accessibility modifiers
        - Support both light and dark mode
        - Add helpful comments
        
        RELEVANT HIG CONTEXT:
        \(higContext)
        
        If the question is not about UI/UX or Apple development, politely redirect \
        to HIG-related topics while still being helpful.
        """
    }
    
    private func buildHIGContext(from topics: [HIGTopic]) -> String {
        guard !topics.isEmpty else {
            return "No specific HIG topics found for this query."
        }
        
        return topics.map { topic in
            var context = """
            ## \(topic.title)
            Category: \(topic.displayCategory)
            URL: \(topic.url)
            
            \(topic.abstract)
            """
            
            // Add key sections
            for section in topic.sections.prefix(2) {
                guard !section.heading.isEmpty else { continue }
                
                let content = section.content
                    .compactMap { $0.text }
                    .prefix(3)
                    .joined(separator: "\n")
                
                if !content.isEmpty {
                    context += "\n\n### \(section.heading)\n\(String(content.prefix(500)))"
                }
            }
            
            return context
        }.joined(separator: "\n\n---\n\n")
    }
    
    private func buildSuggestedActions(from topics: [HIGTopic]) -> [AIAction] {
        topics.prefix(3).map { topic in
            AIAction(
                id: "view_topic",
                label: "View: \(topic.title)",
                icon: "doc.text",
                metadata: ["topicId": topic.id, "url": topic.url]
            )
        }
    }
    
    // MARK: - Ollama Integration
    
    private func callOllama(prompt: String, query: String) async throws -> String {
        let url = URL(string: "\(ollamaURL)/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false,
            "options": [
                "temperature": 0.7,
                "num_predict": 2048
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw HIGAIError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseText = json?["response"] as? String else {
            throw HIGAIError.invalidResponse
        }
        
        return responseText
    }
    
    private func streamFromOllama(
        systemPrompt: String,
        query: String,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let url = URL(string: "\(ollamaURL)/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let fullPrompt = "\(systemPrompt)\n\nUser Question: \(query)"
        
        let body: [String: Any] = [
            "model": model,
            "prompt": fullPrompt,
            "stream": true,
            "options": [
                "temperature": 0.7,
                "num_predict": 2048
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw HIGAIError.requestFailed
        }
        
        for try await line in bytes.lines {
            if let data = line.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseChunk = json["response"] as? String {
                continuation.yield(responseChunk)
            }
        }
        
        continuation.finish()
    }
    
    // MARK: - Code Extraction
    
    private func extractCodeBlocks(from text: String) -> [CodeBlock] {
        var blocks: [CodeBlock] = []
        
        let pattern = #"```(\w*)\n([\s\S]*?)```"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return blocks
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            var language = "swift"
            var code = ""
            
            if let langRange = Range(match.range(at: 1), in: text) {
                let lang = String(text[langRange])
                if !lang.isEmpty {
                    language = lang
                }
            }
            
            if let codeRange = Range(match.range(at: 2), in: text) {
                code = String(text[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if !code.isEmpty {
                blocks.append(CodeBlock( code: code))
            }
        }
        
        return blocks
    }
}

// MARK: - Errors

enum HIGAIError: LocalizedError {
    case requestFailed
    case invalidResponse
    case ollamaNotRunning
    
    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Failed to connect to AI service. Make sure Ollama is running."
        case .invalidResponse:
            return "Received invalid response from AI service."
        case .ollamaNotRunning:
            return "Ollama is not running. Start it with: ollama serve"
        }
    }
}

