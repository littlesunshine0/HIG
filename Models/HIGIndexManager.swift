//
//  HIGIndexManager.swift
//  HIG
//
//  Manages HIG documentation indexing and persistent storage
//  100% HIG-Compliant with Liquid Glass Design System
//
//  HIG Topics Implemented:
//  [launching] - Fast launch with cached data
//  [loading] - Progressive loading with status updates
//  [privacy] - All data stored locally
//  [feedback] - Clear progress indication
//

import Foundation
import SwiftUI

// MARK: - Index State

enum HIGIndexState: Equatable {
    case notStarted
    case checking
    case indexing(progress: Double, stage: String)
    case complete
    case error(String)
    
    var isComplete: Bool {
        if case .complete = self { return true }
        return false
    }
    
    var progress: Double {
        switch self {
        case .notStarted: return 0
        case .checking: return 0.05
        case .indexing(let progress, _): return progress
        case .complete: return 1.0
        case .error: return 0
        }
    }
    
    var statusMessage: String {
        switch self {
        case .notStarted: return "Preparing..."
        case .checking: return "Checking existing index..."
        case .indexing(_, let stage): return stage
        case .complete: return "Ready"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

// MARK: - Indexed Topic (Optimized for fast retrieval)

struct IndexedTopic: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    let subcategory: String?
    let abstract: String
    let url: String
    let keywords: [String]           // Extracted keywords for fast search
    let concepts: [String]           // Bold/emphasized concepts
    let relatedTopicIds: [String]    // Pre-computed related topics
    let contentHash: String          // For cache invalidation
    let platforms: [String]          // Detected platforms
    
    // Computed display properties
    var displayCategory: String {
        if let sub = subcategory {
            return "\(category) › \(sub)"
        }
        return category
    }
}

// MARK: - Persistent Index

struct HIGPersistentIndex: Codable {
    let version: String
    let createdAt: Date
    let sourceHash: String           // Hash of source JSON for invalidation
    let topicCount: Int
    let topics: [IndexedTopic]
    let searchIndex: [String: [String]]  // word -> topic IDs
    let conceptIndex: [String: [String]] // concept -> topic IDs
    let categoryIndex: [String: [String]] // category -> topic IDs
    
    static let currentVersion = "1.0.0"
}

// MARK: - Index Manager

@MainActor
@Observable
class HIGIndexManager {
    static let shared = HIGIndexManager()
    
    // State
    private(set) var state: HIGIndexState = .notStarted
    private(set) var persistentIndex: HIGPersistentIndex?
    
    // Computed
    var isReady: Bool { state.isComplete && persistentIndex != nil }
    var topicCount: Int { persistentIndex?.topicCount ?? 0 }
    
    // Storage
    private let indexFileName = "hig_index.json"
    private var indexFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        
        return appFolder.appendingPathComponent(indexFileName)
    }
    
    private init() {}
    
    // MARK: - Public API
    
    /// Initialize the index - checks cache first, builds if needed
    func initialize() async {
        state = .checking
        
        // Try to load cached index
        if let cached = loadCachedIndex() {
            // Verify it's still valid
            if await verifyCacheValidity(cached) {
                persistentIndex = cached
                state = .complete
                print("✓ Loaded cached HIG index (\(cached.topicCount) topics)")
                return
            }
        }
        
        // Build fresh index
        await buildIndex()
    }
    
    /// Force rebuild the index
    func rebuildIndex() async {
        // Clear cache
        try? FileManager.default.removeItem(at: indexFileURL)
        persistentIndex = nil
        
        await buildIndex()
    }
    
    // MARK: - Search API
    
    func search(query: String, limit: Int = 10) -> [IndexedTopic] {
        guard let index = persistentIndex else { return [] }
        
        let queryWords = tokenize(query)
        var scores: [String: Int] = [:]
        
        // Score by word matches
        for word in queryWords {
            if let topicIds = index.searchIndex[word] {
                for id in topicIds {
                    scores[id, default: 0] += 1
                }
            }
            
            // Partial matches
            for (indexWord, topicIds) in index.searchIndex {
                if indexWord.contains(word) || word.contains(indexWord) {
                    for id in topicIds {
                        scores[id, default: 0] += 1
                    }
                }
            }
        }
        
        // Score by concept matches (weighted higher)
        for word in queryWords {
            if let topicIds = index.conceptIndex[word] {
                for id in topicIds {
                    scores[id, default: 0] += 3
                }
            }
        }
        
        // Sort and return
        let sortedIds = scores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
        return sortedIds.compactMap { id in index.topics.first { $0.id == id } }
    }
    
    func topic(byId id: String) -> IndexedTopic? {
        persistentIndex?.topics.first { $0.id == id }
    }
    
    func topics(in category: String) -> [IndexedTopic] {
        guard let index = persistentIndex,
              let ids = index.categoryIndex[category] else { return [] }
        return ids.compactMap { id in index.topics.first { $0.id == id } }
    }
    
    var allTopics: [IndexedTopic] {
        persistentIndex?.topics ?? []
    }
    
    var categories: [String] {
        guard let index = persistentIndex else { return [] }
        return Array(index.categoryIndex.keys).sorted()
    }
    
    // MARK: - Private: Cache Management
    
    private func loadCachedIndex() -> HIGPersistentIndex? {
        guard FileManager.default.fileExists(atPath: indexFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: indexFileURL)
            let index = try JSONDecoder().decode(HIGPersistentIndex.self, from: data)
            
            // Check version compatibility
            guard index.version == HIGPersistentIndex.currentVersion else {
                print("⚠ Index version mismatch, rebuilding...")
                return nil
            }
            
            return index
        } catch {
            print("⚠ Failed to load cached index: \(error)")
            return nil
        }
    }
    
    private func saveCachedIndex(_ index: HIGPersistentIndex) {
        do {
            let data = try JSONEncoder().encode(index)
            try data.write(to: indexFileURL)
            print("✓ Saved index to \(indexFileURL.path)")
        } catch {
            print("⚠ Failed to save index: \(error)")
        }
    }
    
    private func verifyCacheValidity(_ cached: HIGPersistentIndex) async -> Bool {
        // Load source and compare hash
        guard let sourceData = loadSourceData() else { return false }
        let currentHash = sourceData.hashValue.description
        return cached.sourceHash == currentHash
    }
    
    // MARK: - Private: Index Building
    
    private func buildIndex() async {
        state = .indexing(progress: 0.1, stage: "Loading HIG documentation...")
        
        // Load source data
        guard let sourceData = loadSourceData(),
              let database = parseDatabase(sourceData) else {
            state = .error("Failed to load HIG documentation")
            return
        }
        
        let sourceHash = sourceData.hashValue.description
        let totalTopics = database.topics.count
        
        state = .indexing(progress: 0.2, stage: "Processing \(totalTopics) topics...")
        
        // Build indexed topics
        var indexedTopics: [IndexedTopic] = []
        var searchIndex: [String: [String]] = [:]
        var conceptIndex: [String: [String]] = [:]
        var categoryIndex: [String: [String]] = [:]
        
        for (i, topic) in database.topics.enumerated() {
            // Update progress
            let progress = 0.2 + (Double(i) / Double(totalTopics)) * 0.6
            if i % 10 == 0 {
                state = .indexing(progress: progress, stage: "Indexing: \(topic.title)...")
                // Allow UI to update
                try? await Task.sleep(for: .milliseconds(10))
            }
            
            // Extract keywords
            let keywords = extractKeywords(from: topic)
            
            // Extract concepts
            let concepts = extractConcepts(from: topic)
            
            // Detect platforms
            let platforms = detectPlatforms(from: topic)
            
            // Create indexed topic
            let indexed = IndexedTopic(
                id: topic.id,
                title: topic.title,
                category: topic.category,
                subcategory: topic.subcategory,
                abstract: topic.abstract,
                url: topic.url,
                keywords: keywords,
                concepts: concepts,
                relatedTopicIds: topic.relatedTopics.compactMap { extractTopicId(from: $0.url) },
                contentHash: topic.abstract.hashValue.description,
                platforms: platforms
            )
            indexedTopics.append(indexed)
            
            // Build search index
            for keyword in keywords {
                searchIndex[keyword, default: []].append(topic.id)
            }
            
            // Build concept index
            for concept in concepts {
                conceptIndex[concept.lowercased(), default: []].append(topic.id)
            }
            
            // Build category index
            categoryIndex[topic.category, default: []].append(topic.id)
        }
        
        state = .indexing(progress: 0.9, stage: "Saving index...")
        
        // Create persistent index
        let index = HIGPersistentIndex(
            version: HIGPersistentIndex.currentVersion,
            createdAt: Date(),
            sourceHash: sourceHash,
            topicCount: indexedTopics.count,
            topics: indexedTopics,
            searchIndex: searchIndex,
            conceptIndex: conceptIndex,
            categoryIndex: categoryIndex
        )
        
        // Save to disk
        saveCachedIndex(index)
        
        persistentIndex = index
        state = .complete
        
        print("✓ Built HIG index: \(indexedTopics.count) topics, \(searchIndex.count) keywords, \(conceptIndex.count) concepts")
    }
    
    // MARK: - Private: Data Loading
    
    private func loadSourceData() -> Data? {
        let possiblePaths = [
            "HIGDocumentation.docc/hig_combined",
            "hig_combined"
        ]
        
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                return try? Data(contentsOf: url)
            }
        }
        
        // Try Resources directory
        let resourcesPath = Bundle.main.bundlePath + "/Contents/Resources/HIGDocumentation.docc/hig_combined.json"
        if FileManager.default.fileExists(atPath: resourcesPath) {
            return try? Data(contentsOf: URL(fileURLWithPath: resourcesPath))
        }
        
        return nil
    }
    
    private func parseDatabase(_ data: Data) -> HIGDatabase? {
        try? JSONDecoder().decode(HIGDatabase.self, from: data)
    }
    
    // MARK: - Private: Text Processing
    
    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }
    
    private func extractKeywords(from topic: HIGTopic) -> [String] {
        var words = Set<String>()
        
        // Title words
        words.formUnion(tokenize(topic.title))
        
        // Abstract words
        words.formUnion(tokenize(topic.abstract))
        
        // Category
        words.formUnion(tokenize(topic.category))
        
        // Section headings
        for section in topic.sections {
            words.formUnion(tokenize(section.heading))
        }
        
        return Array(words)
    }
    
    private func extractConcepts(from topic: HIGTopic) -> [String] {
        var concepts = Set<String>()
        
        let pattern = #"\*\*([^*]+)\*\*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        // Extract from abstract
        extractBoldText(from: topic.abstract, regex: regex, into: &concepts)
        
        // Extract from sections
        for section in topic.sections {
            for content in section.content {
                if let text = content.text {
                    extractBoldText(from: text, regex: regex, into: &concepts)
                }
            }
        }
        
        return Array(concepts)
    }
    
    private func extractBoldText(from text: String, regex: NSRegularExpression, into set: inout Set<String>) {
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: text) {
                set.insert(String(text[range]))
            }
        }
    }
    
    private func detectPlatforms(from topic: HIGTopic) -> [String] {
        var platforms: [String] = []
        let content = (topic.abstract + topic.sections.map { $0.heading }.joined()).lowercased()
        
        if content.contains("ios") || content.contains("iphone") { platforms.append("iOS") }
        if content.contains("ipados") || content.contains("ipad") { platforms.append("iPadOS") }
        if content.contains("macos") || content.contains("mac") { platforms.append("macOS") }
        if content.contains("watchos") || content.contains("watch") { platforms.append("watchOS") }
        if content.contains("tvos") || content.contains("apple tv") { platforms.append("tvOS") }
        if content.contains("visionos") || content.contains("vision") { platforms.append("visionOS") }
        
        return platforms.isEmpty ? ["iOS", "macOS"] : platforms
    }
    
    private func extractTopicId(from url: String) -> String? {
        url.split(separator: "/").last.map(String.init)
    }
}
