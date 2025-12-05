//
//  HIGKnowledgeBase.swift
//  HIG
//
//  Knowledge base for semantic search and context retrieval
//

import Foundation

@MainActor
@Observable
class HIGKnowledgeBase {
    static let shared = HIGKnowledgeBase()
    
    private var topics: [HIGTopic] = []
    private var conceptIndex: [String: Set<String>] = [:] // concept -> topic IDs
    private var searchIndex: [String: Set<String>] = [:] // word -> topic IDs
    
    var isLoaded: Bool { !topics.isEmpty }
    
    private init() {}
    
    // MARK: - Loading
    
    func load(from database: HIGDatabase) {
        self.topics = database.topics
        buildIndices()
    }
    
    private func buildIndices() {
        conceptIndex.removeAll()
        searchIndex.removeAll()
        
        for topic in topics {
            // Index by words in title and abstract
            let words = tokenize(topic.title + " " + topic.abstract)
            for word in words {
                searchIndex[word, default: []].insert(topic.id)
            }
            
            // Index by category
            let categoryWords = tokenize(topic.category + " " + (topic.subcategory ?? ""))
            for word in categoryWords {
                searchIndex[word, default: []].insert(topic.id)
            }
            
            // Index section content
            for section in topic.sections {
                let sectionWords = tokenize(section.heading)
                for word in sectionWords {
                    searchIndex[word, default: []].insert(topic.id)
                }
                
                for content in section.content {
                    if let text = content.text {
                        // Extract concepts (bold text)
                        let concepts = extractConcepts(from: text)
                        for concept in concepts {
                            conceptIndex[concept.lowercased(), default: []].insert(topic.id)
                        }
                    }
                }
            }
        }
    }
    
    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }
    
    private func extractConcepts(from text: String) -> [String] {
        // Extract bold text as concepts
        let pattern = #"\*\*([^*]+)\*\*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
    }
    
    // MARK: - Search
    
    func search(query: String, limit: Int = 5) -> [HIGTopic] {
        let queryWords = tokenize(query)
        var scores: [String: Int] = [:]
        
        // Score by word matches
        for word in queryWords {
            if let topicIds = searchIndex[word] {
                for id in topicIds {
                    scores[id, default: 0] += 1
                }
            }
            
            // Partial matches
            for (indexWord, topicIds) in searchIndex {
                if indexWord.contains(word) || word.contains(indexWord) {
                    for id in topicIds {
                        scores[id, default: 0] += 1
                    }
                }
            }
        }
        
        // Score by concept matches
        for word in queryWords {
            if let topicIds = conceptIndex[word] {
                for id in topicIds {
                    scores[id, default: 0] += 2 // Concepts weighted higher
                }
            }
        }
        
        // Sort by score and return top results
        let sortedIds = scores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
        return sortedIds.compactMap { id in topics.first { $0.id == id } }
    }
    
    func topic(byId id: String) -> HIGTopic? {
        topics.first { $0.id == id }
    }
    
    /// All topics in the knowledge base
    var allTopics: [HIGTopic] {
        topics
    }
    
    func topics(inCategory category: String) -> [HIGTopic] {
        topics.filter { $0.category == category }
    }
    
    /// Get topics in a specific category (case-insensitive)
    func topics(in category: String) -> [HIGTopic] {
        topics.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    func relatedTopics(to topic: HIGTopic, limit: Int = 5) -> [HIGTopic] {
        // Find topics that share concepts
        var scores: [String: Int] = [:]
        
        // Get concepts from this topic
        let topicText = topic.abstract + topic.sections.flatMap { $0.content.compactMap { $0.text } }.joined()
        let concepts = extractConcepts(from: topicText)
        
        for concept in concepts {
            if let relatedIds = conceptIndex[concept.lowercased()] {
                for id in relatedIds where id != topic.id {
                    scores[id, default: 0] += 1
                }
            }
        }
        
        // Also include explicitly related topics
        for related in topic.relatedTopics {
            let slug = related.url.split(separator: "/").last.map(String.init) ?? ""
            if let relatedTopic = topics.first(where: { $0.id == slug }) {
                scores[relatedTopic.id, default: 0] += 3
            }
        }
        
        let sortedIds = scores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
        return sortedIds.compactMap { id in topics.first { $0.id == id } }
    }
    
    // MARK: - Context for AI
    
    func contextForQuery(_ query: String, maxTokens: Int = 2000) -> String {
        let relevantTopics = search(query: query, limit: 5)
        var context = ""
        var estimatedTokens = 0
        
        for topic in relevantTopics {
            let topicContext = """
            ## \(topic.title)
            Category: \(topic.displayCategory)
            \(topic.abstract)
            
            """
            
            let tokens = topicContext.count / 4 // Rough estimate
            if estimatedTokens + tokens > maxTokens { break }
            
            context += topicContext
            estimatedTokens += tokens
            
            // Add key sections
            for section in topic.sections.prefix(2) {
                guard !section.heading.isEmpty else { continue }
                
                let sectionContent = section.content
                    .compactMap { $0.text }
                    .joined(separator: "\n")
                    .prefix(300)
                
                let sectionContext = "### \(section.heading)\n\(sectionContent)\n\n"
                let sectionTokens = sectionContext.count / 4
                
                if estimatedTokens + sectionTokens > maxTokens { break }
                context += sectionContext
                estimatedTokens += sectionTokens
            }
        }
        
        return context
    }
}
