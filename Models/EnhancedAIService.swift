//
//  EnhancedAIService.swift
//  HIG
//
//  AI service with knowledge base integration
//  Enhances prompts with offline knowledge for better responses
//

import Foundation
import SwiftUI

extension AIService {
    /// Send message with knowledge base enhancement
    func sendEnhancedMessage(_ message: String, context: [ChatMessage] = []) async throws -> String {
        let knowledgeBase = AIKnowledgeBase.shared
        
        // Enhance prompt with relevant context
        var enhancedMessage = message
        var additionalContext: [String] = []
        
        // 1. Check for error patterns
        if message.lowercased().contains("error") || 
           message.lowercased().contains("crash") ||
           message.lowercased().contains("failed") {
            
            if let solution = knowledgeBase.findErrorSolution(error: message) {
                additionalContext.append("""
                [Known Error Solution]
                Error: \(solution.error)
                Cause: \(solution.cause)
                Solution: \(solution.solution)
                Example:
                \(solution.example)
                """)
            }
        }
        
        // 2. Check for code example requests
        let codeKeywords = ["how to", "example", "show me", "code for"]
        if codeKeywords.contains(where: { message.lowercased().contains($0) }) {
            let examples = knowledgeBase.searchCodeExamples(query: message)
            if !examples.isEmpty {
                let topExamples = examples.prefix(2)
                let examplesText = topExamples.map { example in
                    """
                    \(example.title):
                    \(example.code)
                    // \(example.explanation)
                    """
                }.joined(separator: "\n\n")
                
                additionalContext.append("""
                [Relevant Code Examples]
                \(examplesText)
                """)
            }
        }
        
        // 3. Check for API reference requests
        let apiKeywords = ["what is", "how does", "api", "method", "function"]
        if apiKeywords.contains(where: { message.lowercased().contains($0) }) {
            // Extract potential API names (simplified)
            let words = message.components(separatedBy: .whitespaces)
            for word in words {
                if let apiRef = knowledgeBase.getAPIReference(api: word) {
                    additionalContext.append("""
                    [API Reference]
                    \(apiRef.api): \(apiRef.description)
                    Example: \(apiRef.example)
                    Returns: \(apiRef.returns ?? "N/A")
                    """)
                    break
                }
            }
        }
        
        // 4. Check for design pattern requests
        let patternKeywords = ["pattern", "architecture", "mvvm", "mvc", "viper", 
                              "singleton", "factory", "observer", "strategy"]
        for keyword in patternKeywords {
            if message.lowercased().contains(keyword) {
                if let pattern = knowledgeBase.getDesignPattern(name: keyword) {
                    additionalContext.append("""
                    [Design Pattern]
                    \(pattern.name) (\(pattern.category))
                    Description: \(pattern.description)
                    When to use: \(pattern.whenToUse)
                    Pros: \(pattern.pros?.joined(separator: ", ") ?? "N/A")
                    Example:
                    \(pattern.example)
                    """)
                    break
                }
            }
        }
        
        // 5. Add context to message
        if !additionalContext.isEmpty {
            enhancedMessage = """
            \(message)
            
            ---
            [Context from Offline Knowledge Base]
            \(additionalContext.joined(separator: "\n\n---\n\n"))
            ---
            
            Please use the above context to provide a more accurate and helpful response.
            """
        }
        
        // Send enhanced message to AI
        let response = await chat(messages: context, query: enhancedMessage)
        return response?.content ?? "Unable to generate response"
    }
    
    /// Get suggestions based on partial input
    func getSuggestions(for partialInput: String) -> [String] {
        let knowledgeBase = AIKnowledgeBase.shared
        var suggestions: [String] = []
        
        // Search code examples
        let examples = knowledgeBase.searchCodeExamples(query: partialInput)
        suggestions.append(contentsOf: examples.prefix(3).map { "Example: \($0.title)" })
        
        // Search by tags
        let words = partialInput.lowercased().components(separatedBy: .whitespaces)
        for word in words {
            let results = knowledgeBase.searchByTag(word)
            if !results.isEmpty {
                suggestions.append("Show \(word) examples")
                break
            }
        }
        
        return Array(suggestions.prefix(5))
    }
    
    /// Get quick help for common topics
    func getQuickHelp(topic: String) -> String? {
        let knowledgeBase = AIKnowledgeBase.shared
        
        // Try to find relevant information
        if let pattern = knowledgeBase.getDesignPattern(name: topic) {
            return """
            \(pattern.name)
            
            \(pattern.description)
            
            When to use: \(pattern.whenToUse)
            
            Example:
            \(pattern.example)
            """
        }
        
        if let solution = knowledgeBase.findErrorSolution(error: topic) {
            return """
            \(solution.error)
            
            Cause: \(solution.cause)
            
            Solution: \(solution.solution)
            
            Example:
            \(solution.example)
            """
        }
        
        let examples = knowledgeBase.searchCodeExamples(query: topic)
        if let first = examples.first {
            return """
            \(first.title)
            
            \(first.explanation)
            
            \(first.code)
            """
        }
        
        return nil
    }
}

// MARK: - Knowledge-Enhanced Chat View

extension View {
    /// Add knowledge base suggestions to chat
    func withKnowledgeSuggestions() -> some View {
        self.modifier(KnowledgeSuggestionsModifier())
    }
}

struct KnowledgeSuggestionsModifier: ViewModifier {
    @Environment(\.aiKnowledgeBase) private var knowledgeBase
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if knowledgeBase.isLoaded {
                    QuickHelpBar()
                }
            }
    }
}

struct QuickHelpBar: View {
    @Environment(\.aiKnowledgeBase) private var knowledgeBase
    
    private let quickTopics = [
        ("MVVM", "square.grid.2x2"),
        ("Async", "arrow.triangle.2.circlepath"),
        ("Errors", "exclamationmark.triangle"),
        ("SwiftUI", "swift")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(quickTopics, id: \.0) { topic, icon in
                    Button {
                        // Handle quick help
                    } label: {
                        Label(topic, systemImage: icon)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }
}
