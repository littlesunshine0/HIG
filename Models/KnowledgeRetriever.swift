//
//  KnowledgeRetriever.swift
//  HIG
//
//  Hybrid knowledge retrieval system
//  Combines local documentation with web-based sources
//

import Foundation

// MARK: - Knowledge Source

enum KnowledgeSource {
    case local(path: String)
    case apple(url: String)
    case swift(url: String)
    case github(repo: String, path: String)
    case web(url: String)
}

// MARK: - Retrieved Knowledge

struct RetrievedKnowledge {
    let source: KnowledgeSource
    let title: String
    let content: String
    let relevanceScore: Double
    let url: String?
    
    var sourceLabel: String {
        switch source {
        case .local: return "📁 Local"
        case .apple: return "🍎 Apple Docs"
        case .swift: return "🔶 Swift.org"
        case .github: return "🐙 GitHub"
        case .web: return "🌐 Web"
        }
    }
}

// MARK: - Knowledge Retriever

@MainActor
@Observable
class KnowledgeRetriever {
    
    // Configuration
    var enableWebSearch = true
    var enableAppleDocs = true
    var enableSwiftDocs = true
    var enableGitHub = true
    
    // State
    private(set) var isRetrieving = false
    private(set) var lastQuery: String?
    
    // MARK: - Main Retrieval
    
    /// Retrieve knowledge from all available sources based on query intent
    func retrieve(query: String, limit: Int = 5) async -> [RetrievedKnowledge] {
        isRetrieving = true
        lastQuery = query
        defer { isRetrieving = false }
        
        var results: [RetrievedKnowledge] = []
        
        // 1. ALWAYS search local documentation first (user's context)
        let localResults = await searchLocal(query: query, limit: limit)
        results.append(contentsOf: localResults)
        
        // 2. Determine query intent
        let intent = determineIntent(query: query)
        
        // 3. Fetch knowledge based on intent
        switch intent {
        case .swiftLanguage:
            // Swift-specific questions → Swift.org + Swift Evolution + Apple
            if enableSwiftDocs {
                let swiftResults = await searchSwiftDocs(query: query, limit: 2)
                results.append(contentsOf: swiftResults)
                
                let evolutionResults = await searchSwiftEvolution(query: query, limit: 1)
                results.append(contentsOf: evolutionResults)
            }
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 2)
                results.append(contentsOf: appleResults)
            }
            
        case .appleFramework, .uiDesign:
            // Apple framework/UI questions → Apple Docs + WWDC + Sample Code
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 3)
                results.append(contentsOf: appleResults)
                
                let wwdcResults = await searchWWDC(query: query, limit: 1)
                results.append(contentsOf: wwdcResults)
                
                let sampleCodeResults = await searchAppleSampleCode(query: query, limit: 1)
                results.append(contentsOf: sampleCodeResults)
            }
            
        case .buildProject, .createComponent:
            // Building/creating → GitHub examples + Swift Package Index + Apple docs
            if enableGitHub {
                let githubResults = await searchGitHub(query: query, limit: 2)
                results.append(contentsOf: githubResults)
                
                let packageResults = await searchSwiftPackageIndex(query: query, limit: 1)
                results.append(contentsOf: packageResults)
            }
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 2)
                results.append(contentsOf: appleResults)
            }
            
        case .performance:
            // Performance questions → Apple docs + WWDC
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 3)
                results.append(contentsOf: appleResults)
                
                let wwdcResults = await searchWWDC(query: query, limit: 2)
                results.append(contentsOf: wwdcResults)
            }
            
        case .testing, .debugging:
            // Testing/debugging → Apple docs + Sample code
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 3)
                results.append(contentsOf: appleResults)
                
                let sampleCodeResults = await searchAppleSampleCode(query: query, limit: 2)
                results.append(contentsOf: sampleCodeResults)
            }
            
        case .general:
            // General questions → Apple docs only
            if enableAppleDocs {
                let appleResults = await searchAppleDocs(query: query, limit: 3)
                results.append(contentsOf: appleResults)
            }
        }
        
        // Sort by relevance and return top results
        return Array(results.sorted { $0.relevanceScore > $1.relevanceScore }.prefix(limit))
    }
    
    // MARK: - Intent Detection
    
    enum QueryIntent {
        case swiftLanguage      // Swift syntax, language features, proposals
        case appleFramework     // UIKit, SwiftUI, Foundation, etc.
        case uiDesign          // HIG, design patterns, UI/UX
        case buildProject      // Create, build, implement, scaffold
        case createComponent   // Make reusable component, package
        case performance       // Optimization, profiling, memory
        case testing           // Unit tests, UI tests, XCTest
        case debugging         // Troubleshooting, errors, crashes
        case general           // Everything else
    }
    
    private func determineIntent(query: String) -> QueryIntent {
        let lowercased = query.lowercased()
        
        // Check for build/create intent
        let buildKeywords = ["create", "build", "make", "implement", "scaffold", "generate", 
                            "blueprint", "template", "boilerplate", "starter", "setup"]
        if buildKeywords.contains(where: { lowercased.contains($0) }) {
            // Further check if it's about components/packages
            if lowercased.contains("component") || lowercased.contains("package") || 
               lowercased.contains("reusable") || lowercased.contains("library") {
                return .createComponent
            }
            return .buildProject
        }
        
        // Check for Swift language intent
        let swiftKeywords = ["swift", "syntax", "closure", "protocol", "generic", "async", 
                            "await", "actor", "concurrency", "property wrapper", "result builder"]
        if swiftKeywords.contains(where: { lowercased.contains($0) }) {
            return .swiftLanguage
        }
        
        // Check for UI/Design intent
        let designKeywords = ["design", "hig", "interface", "ux", "ui", "layout", "style",
                             "color", "typography", "accessibility", "animation"]
        if designKeywords.contains(where: { lowercased.contains($0) }) {
            return .uiDesign
        }
        
        // Check for Apple framework intent
        let frameworkKeywords = ["swiftui", "uikit", "appkit", "foundation", "combine",
                                "coredata", "cloudkit", "mapkit", "avfoundation", "webkit"]
        if frameworkKeywords.contains(where: { lowercased.contains($0) }) {
            return .appleFramework
        }
        
        // Check for performance intent
        let performanceKeywords = ["performance", "optimize", "slow", "memory", "leak",
                                  "profile", "instruments", "fps", "lag", "battery"]
        if performanceKeywords.contains(where: { lowercased.contains($0) }) {
            return .performance
        }
        
        // Check for testing intent
        let testingKeywords = ["test", "xctest", "unit test", "ui test", "mock", "stub",
                              "tdd", "testing", "assertion"]
        if testingKeywords.contains(where: { lowercased.contains($0) }) {
            return .testing
        }
        
        // Check for debugging intent
        let debugKeywords = ["debug", "error", "crash", "bug", "fix", "troubleshoot",
                            "breakpoint", "lldb", "exception", "issue"]
        if debugKeywords.contains(where: { lowercased.contains($0) }) {
            return .debugging
        }
        
        return .general
    }
    
    // MARK: - Local Search
    
    private func searchLocal(query: String, limit: Int) async -> [RetrievedKnowledge] {
        // Search through locally indexed documents
        let sourceManager = DocumentSourceManager.shared
        var results: [RetrievedKnowledge] = []
        
        // TODO: Implement actual search through indexed content
        // For now, return placeholder
        
        return results
    }
    
    // MARK: - Apple Documentation Search
    
    private func searchAppleDocs(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search Apple Developer Documentation
        // Using DuckDuckGo to search site:developer.apple.com
        let searchQuery = "\(query) site:developer.apple.com"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .apple(url: result.url),
                    title: result.title,
                    content: result.snippet,
                    relevanceScore: result.relevance,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Swift.org Documentation Search
    
    private func searchSwiftDocs(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search Swift.org documentation
        let searchQuery = "\(query) site:swift.org OR site:docs.swift.org"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .swift(url: result.url),
                    title: result.title,
                    content: result.snippet,
                    relevanceScore: result.relevance,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - GitHub Search
    
    private func searchGitHub(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search GitHub for code examples
        // Focus on popular Swift/iOS repositories
        let searchQuery = "\(query) language:swift stars:>100"
        
        if let githubResults = await searchGitHubAPI(query: searchQuery, limit: limit) {
            for result in githubResults {
                results.append(RetrievedKnowledge(
                    source: .github(repo: result.repo, path: result.path),
                    title: result.title,
                    content: result.content,
                    relevanceScore: result.relevance,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Web Search (DuckDuckGo)
    
    private func webSearch(query: String, limit: Int) async -> [WebSearchResult]? {
        // Use DuckDuckGo Instant Answer API (no API key required)
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.duckduckgo.com/?q=\(encodedQuery)&format=json&no_html=1"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let relatedTopics = json["RelatedTopics"] as? [[String: Any]] {
                
                var results: [WebSearchResult] = []
                
                for topic in relatedTopics.prefix(limit) {
                    if let text = topic["Text"] as? String,
                       let firstURL = topic["FirstURL"] as? String {
                        results.append(WebSearchResult(
                            title: String(text.prefix(100)),
                            snippet: text,
                            url: firstURL,
                            relevance: 0.7
                        ))
                    }
                }
                
                return results
            }
        } catch {
            print("Web search error: \(error)")
        }
        
        return nil
    }
    
    // MARK: - WWDC Search
    
    private func searchWWDC(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search WWDC sessions via ASCIIwwdc.com (searchable transcripts)
        let searchQuery = "\(query) site:asciiwwdc.com"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .apple(url: result.url),
                    title: "WWDC: \(result.title)",
                    content: result.snippet,
                    relevanceScore: result.relevance * 0.9, // Slightly lower than docs
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Apple Sample Code Search
    
    private func searchAppleSampleCode(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search Apple's sample code
        let searchQuery = "\(query) site:developer.apple.com/documentation/*/sample"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .apple(url: result.url),
                    title: "Sample: \(result.title)",
                    content: result.snippet,
                    relevanceScore: result.relevance * 0.85,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Swift Evolution Search
    
    private func searchSwiftEvolution(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search Swift Evolution proposals
        let searchQuery = "\(query) site:github.com/apple/swift-evolution"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .swift(url: result.url),
                    title: "Evolution: \(result.title)",
                    content: result.snippet,
                    relevanceScore: result.relevance * 0.8,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Swift Package Index Search
    
    private func searchSwiftPackageIndex(query: String, limit: Int) async -> [RetrievedKnowledge] {
        var results: [RetrievedKnowledge] = []
        
        // Search Swift Package Index
        let searchQuery = "\(query) site:swiftpackageindex.com"
        
        if let searchResults = await webSearch(query: searchQuery, limit: limit) {
            for result in searchResults {
                results.append(RetrievedKnowledge(
                    source: .swift(url: result.url),
                    title: "Package: \(result.title)",
                    content: result.snippet,
                    relevanceScore: result.relevance * 0.75,
                    url: result.url
                ))
            }
        }
        
        return results
    }
    
    // MARK: - GitHub API Search
    
    private func searchGitHubAPI(query: String, limit: Int) async -> [GitHubSearchResult]? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.github.com/search/code?q=\(encodedQuery)&per_page=\(limit)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let items = json["items"] as? [[String: Any]] {
                
                var results: [GitHubSearchResult] = []
                
                for item in items.prefix(limit) {
                    if let name = item["name"] as? String,
                       let path = item["path"] as? String,
                       let htmlURL = item["html_url"] as? String,
                       let repo = item["repository"] as? [String: Any],
                       let repoName = repo["full_name"] as? String {
                        
                        // Fetch file content
                        if let content = await fetchGitHubFileContent(htmlURL: htmlURL) {
                            results.append(GitHubSearchResult(
                                title: name,
                                content: content,
                                repo: repoName,
                                path: path,
                                url: htmlURL,
                                relevance: 0.6
                            ))
                        }
                    }
                }
                
                return results
            }
        } catch {
            print("GitHub search error: \(error)")
        }
        
        return nil
    }
    
    private func fetchGitHubFileContent(htmlURL: String) async -> String? {
        // Convert HTML URL to raw content URL
        let rawURL = htmlURL
            .replacingOccurrences(of: "github.com", with: "raw.githubusercontent.com")
            .replacingOccurrences(of: "/blob/", with: "/")
        
        guard let url = URL(string: rawURL) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    

}

// MARK: - Search Result Types

struct WebSearchResult {
    let title: String
    let snippet: String
    let url: String
    let relevance: Double
}

struct GitHubSearchResult {
    let title: String
    let content: String
    let repo: String
    let path: String
    let url: String
    let relevance: Double
}
