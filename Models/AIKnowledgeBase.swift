//
//  AIKnowledgeBase.swift
//  HIG
//
//  Offline AI knowledge base for improved communication
//  Loads code examples, API references, error solutions, and patterns
//

import Foundation
import SwiftUI

// MARK: - Knowledge Base Models

struct CodeExample: Codable, Identifiable {
    var id: String { title }
    let title: String
    let code: String
    let explanation: String
    let tags: [String]
}

struct APIReference: Codable, Identifiable {
    var id: String { api }
    let api: String
    let description: String
    let example: String
    let returns: String?
    let category: String?
}

struct ErrorSolution: Codable, Identifiable {
    var id: String { error }
    let error: String
    let type: String
    let cause: String
    let solution: String
    let example: String
    let tags: [String]
}

struct DesignPattern: Codable, Identifiable {
    var id: String { name }
    let name: String
    let category: String
    let description: String
    let whenToUse: String
    let pros: [String]?
    let cons: [String]?
    let example: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, category, description, example, tags, pros, cons
        case whenToUse = "when_to_use"
    }
}

struct ConversationTemplate: Codable {
    let structure: [String]
    let example: String?
}

struct KnowledgeMetadata: Codable {
    let version: String
    let buildDate: String
    let resources: [String: String]
    let updateInfo: UpdateInfo
    
    struct UpdateInfo: Codable {
        let canAutoUpdate: Bool
        let updateFrequency: String
        let lastUpdate: String
        
        enum CodingKeys: String, CodingKey {
            case canAutoUpdate = "can_auto_update"
            case updateFrequency = "update_frequency"
            case lastUpdate = "last_update"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case version, resources
        case buildDate = "build_date"
        case updateInfo = "update_info"
    }
}

// MARK: - AI Knowledge Base

@MainActor
@Observable
class AIKnowledgeBase {
    static let shared = AIKnowledgeBase()
    
    private(set) var isLoaded = false
    private(set) var metadata: KnowledgeMetadata?
    
    private var codeExamples: [String: [CodeExample]] = [:]
    private var apiReferences: [String: [APIReference]] = [:]
    private var errorSolutions: [ErrorSolution] = []
    private var designPatterns: [DesignPattern] = []
    private var conversationTemplates: [String: ConversationTemplate] = [:]
    private var searchIndex: [String: [[String: String]]] = [:]
    
    private let knowledgeDir: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        knowledgeDir = appFolder.appendingPathComponent("Knowledge/AIKnowledge", isDirectory: true)
        
        // Try to load on init
        Task {
            await loadKnowledgeBase()
        }
    }
    
    // MARK: - Loading
    
    func loadKnowledgeBase() async {
        do {
            // Load metadata
            metadata = try loadJSON("metadata.json")
            
            // Load all resources
            let codeExamplesData: [String: [String: [CodeExample]]] = try loadJSON("code_examples.json")
            codeExamples = codeExamplesData["categories"] ?? [:]
            
            let apiRefData: [String: [String: [APIReference]]] = try loadJSON("api_reference.json")
            apiReferences = apiRefData["categories"] ?? [:]
            
            let errorData: [String: [ErrorSolution]] = try loadJSON("error_solutions.json")
            errorSolutions = errorData["errors"] ?? []
            
            let patternData: [String: [DesignPattern]] = try loadJSON("design_patterns.json")
            designPatterns = patternData["patterns"] ?? []
            
            let templateData: [String: [String: ConversationTemplate]] = try loadJSON("conversation_templates.json")
            conversationTemplates = templateData["templates"] ?? [:]
            
            let indexData: [String: [String: [String: [[String: String]]]]] = try loadJSON("search_index.json")
            if let index = indexData["index"]?["tags"] {
                searchIndex = index
            }
            
            isLoaded = true
            print("✅ AI Knowledge Base loaded successfully")
            
        } catch {
            print("⚠️ Failed to load AI Knowledge Base: \(error)")
            isLoaded = false
        }
    }
    
    private func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        let fileURL = knowledgeDir.appendingPathComponent(filename)
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Search & Retrieval
    
    func searchCodeExamples(query: String) -> [CodeExample] {
        let lowercaseQuery = query.lowercased()
        var results: [CodeExample] = []
        
        for (_, examples) in codeExamples {
            for example in examples {
                if example.title.lowercased().contains(lowercaseQuery) ||
                   example.explanation.lowercased().contains(lowercaseQuery) ||
                   example.tags.contains(where: { $0.lowercased().contains(lowercaseQuery) }) {
                    results.append(example)
                }
            }
        }
        
        return results
    }
    
    func findErrorSolution(error: String) -> ErrorSolution? {
        let lowercaseError = error.lowercased()
        
        // Try exact match first
        if let solution = errorSolutions.first(where: { $0.error.lowercased() == lowercaseError }) {
            return solution
        }
        
        // Try partial match
        return errorSolutions.first { solution in
            lowercaseError.contains(solution.error.lowercased()) ||
            solution.error.lowercased().contains(lowercaseError)
        }
    }
    
    func getDesignPattern(name: String) -> DesignPattern? {
        designPatterns.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func getDesignPatterns(category: String) -> [DesignPattern] {
        designPatterns.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    func getAPIReference(api: String) -> APIReference? {
        for (_, refs) in apiReferences {
            if let ref = refs.first(where: { $0.api.lowercased() == api.lowercased() }) {
                return ref
            }
        }
        return nil
    }
    
    func searchByTag(_ tag: String) -> [Any] {
        var results: [Any] = []
        
        // Search code examples
        for (_, examples) in codeExamples {
            results.append(contentsOf: examples.filter { $0.tags.contains(tag) })
        }
        
        // Search error solutions
        results.append(contentsOf: errorSolutions.filter { $0.tags.contains(tag) })
        
        // Search design patterns
        results.append(contentsOf: designPatterns.filter { $0.tags.contains(tag) })
        
        return results
    }
    
    // MARK: - Context Enhancement
    
    /// Enhance AI prompt with relevant context
    func enhancePrompt(_ userPrompt: String) -> String {
        var enhancedPrompt = userPrompt
        var context: [String] = []
        
        // Check for error keywords
        if userPrompt.lowercased().contains("error") || userPrompt.lowercased().contains("crash") {
            if let solution = findErrorSolution(error: userPrompt) {
                context.append("Known Error: \(solution.error)")
                context.append("Solution: \(solution.solution)")
            }
        }
        
        // Check for pattern keywords
        let patternKeywords = ["mvvm", "mvc", "viper", "singleton", "factory", "observer"]
        for keyword in patternKeywords {
            if userPrompt.lowercased().contains(keyword) {
                if let pattern = getDesignPattern(name: keyword) {
                    context.append("Pattern: \(pattern.name) - \(pattern.description)")
                }
            }
        }
        
        // Add context if found
        if !context.isEmpty {
            enhancedPrompt += "\n\n[Context from Knowledge Base]:\n" + context.joined(separator: "\n")
        }
        
        return enhancedPrompt
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> [String: Int] {
        [
            "Code Examples": codeExamples.values.reduce(0) { $0 + $1.count },
            "API References": apiReferences.values.reduce(0) { $0 + $1.count },
            "Error Solutions": errorSolutions.count,
            "Design Patterns": designPatterns.count,
            "Conversation Templates": conversationTemplates.count
        ]
    }
}

// MARK: - View Extension

extension View {
    /// Inject AI knowledge base into environment
    func withAIKnowledge() -> some View {
        self.environment(\.aiKnowledgeBase, AIKnowledgeBase.shared)
    }
}

// MARK: - Environment Key

private struct AIKnowledgeBaseKey: EnvironmentKey {
    static let defaultValue = AIKnowledgeBase.shared
}

extension EnvironmentValues {
    var aiKnowledgeBase: AIKnowledgeBase {
        get { self[AIKnowledgeBaseKey.self] }
        set { self[AIKnowledgeBaseKey.self] = newValue }
    }
}
