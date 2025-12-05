//
//  DocumentationCrawler.swift
//  HIG
//
//  Advanced documentation crawler that produces structured JSON
//  Similar to hig_combined.json format
//

import Foundation
import Combine

@MainActor
class DocumentationCrawler: ObservableObject {
    
    static let shared = DocumentationCrawler()
    
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var currentTask = ""
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.httpAdditionalHeaders = [
            "User-Agent": "HIG-DocCrawler/1.0 (macOS; Educational Purpose)"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Main Crawl Function
    
    func crawlAndGenerateJSON() async {
        isProcessing = true
        progress = 0.0
        
        var allTopics: [DocumentationTopic] = []
        
        // Crawl Apple Developer Documentation
        currentTask = "Crawling Apple Developer Documentation..."
        let appleTopics = await crawlAppleDeveloperDocs()
        allTopics.append(contentsOf: appleTopics)
        progress = 0.33
        
        // Crawl Swift.org Documentation
        currentTask = "Crawling Swift.org Documentation..."
        let swiftTopics = await crawlSwiftOrgDocs()
        allTopics.append(contentsOf: swiftTopics)
        progress = 0.66
        
        // Generate combined JSON
        currentTask = "Generating combined JSON..."
        let database = DocumentationDatabase(
            version: "1.0.0",
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            source: "Apple Developer + Swift.org",
            topicCount: allTopics.count,
            topics: allTopics
        )
        
        // Save to file
        await saveDatabase(database, filename: "developer_docs_combined.json")
        
        progress = 1.0
        currentTask = "Complete!"
        isProcessing = false
        
        print("✅ Generated documentation JSON with \(allTopics.count) topics")
    }
    
    // MARK: - Apple Developer Documentation
    
    private func crawlAppleDeveloperDocs() async -> [DocumentationTopic] {
        var topics: [DocumentationTopic] = []
        
        // Key Apple documentation areas
        let sections = [
            ("SwiftUI", "https://developer.apple.com/documentation/swiftui"),
            ("UIKit", "https://developer.apple.com/documentation/uikit"),
            ("Foundation", "https://developer.apple.com/documentation/foundation"),
            ("Combine", "https://developer.apple.com/documentation/combine"),
            ("Swift", "https://developer.apple.com/documentation/swift"),
            ("Xcode", "https://developer.apple.com/documentation/xcode")
        ]
        
        for (category, urlString) in sections {
            guard let url = URL(string: urlString) else { continue }
            
            if let html = await fetchHTML(from: url) {
                let sectionTopics = parseAppleDocPage(html: html, category: category, url: urlString)
                topics.append(contentsOf: sectionTopics)
            }
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return topics
    }
    
    private func parseAppleDocPage(html: String, category: String, url: String) -> [DocumentationTopic] {
        var topics: [DocumentationTopic] = []
        
        // Extract main content
        let title = extractTitle(from: html) ?? category
        let abstract = extractMetaDescription(from: html) ?? "Apple Developer Documentation for \(category)"
        let content = extractTextContent(from: html)
        
        // Parse into sections
        let sections = parseHTMLSections(from: html)
        
        // Extract code examples
        let codeExamples = extractCodeBlocks(from: html)
        
        // Create main topic
        let topic = DocumentationTopic(
            id: generateID(from: url),
            title: title,
            category: "Apple Developer",
            subcategory: category,
            abstract: abstract,
            url: url,
            sections: sections,
            relatedTopics: [],
            platforms: detectPlatforms(from: content),
            availability: extractAvailability(from: html),
            codeExamples: codeExamples
        )
        
        topics.append(topic)
        
        return topics
    }
    
    // MARK: - Swift.org Documentation
    
    private func crawlSwiftOrgDocs() async -> [DocumentationTopic] {
        var topics: [DocumentationTopic] = []
        
        let sections = [
            ("Swift Language Guide", "https://docs.swift.org/swift-book/documentation/the-swift-programming-language/"),
            ("Swift Standard Library", "https://developer.apple.com/documentation/swift/swift-standard-library"),
            ("Swift Evolution", "https://www.swift.org/swift-evolution/"),
            ("Getting Started", "https://www.swift.org/getting-started/")
        ]
        
        for (category, urlString) in sections {
            guard let url = URL(string: urlString) else { continue }
            
            if let html = await fetchHTML(from: url) {
                let sectionTopics = parseSwiftDocPage(html: html, category: category, url: urlString)
                topics.append(contentsOf: sectionTopics)
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return topics
    }
    
    private func parseSwiftDocPage(html: String, category: String, url: String) -> [DocumentationTopic] {
        var topics: [DocumentationTopic] = []
        
        let title = extractTitle(from: html) ?? category
        let abstract = extractMetaDescription(from: html) ?? "Swift.org Documentation for \(category)"
        let _ = extractTextContent(from: html) // Content for processing
        let sections = parseHTMLSections(from: html)
        let codeExamples = extractCodeBlocks(from: html)
        
        let topic = DocumentationTopic(
            id: generateID(from: url),
            title: title,
            category: "Swift.org",
            subcategory: category,
            abstract: abstract,
            url: url,
            sections: sections,
            relatedTopics: [],
            platforms: ["iOS", "macOS", "watchOS", "tvOS", "visionOS"],
            availability: "Swift 5.0+",
            codeExamples: codeExamples
        )
        
        topics.append(topic)
        
        return topics
    }
    
    // MARK: - HTML Parsing Utilities
    
    private func fetchHTML(from url: URL) async -> String? {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            print("❌ Failed to fetch \(url): \(error)")
            return nil
        }
    }
    
    private func extractTitle(from html: String) -> String? {
        if let range = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
            let titleTag = String(html[range])
            return titleTag
                .replacingOccurrences(of: "<title>", with: "")
                .replacingOccurrences(of: "</title>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    
    private func extractMetaDescription(from html: String) -> String? {
        let pattern = "<meta\\s+name=[\"']description[\"']\\s+content=[\"'](.*?)[\"']"
        if let range = html.range(of: pattern, options: .regularExpression) {
            let metaTag = String(html[range])
            if let contentRange = metaTag.range(of: "content=[\"'](.*?)[\"']", options: .regularExpression) {
                let content = String(metaTag[contentRange])
                return content
                    .replacingOccurrences(of: "content=[\"']", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "[\"']", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
    
    private func extractTextContent(from html: String) -> String {
        var text = html
        
        // Remove script and style tags
        text = text.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Remove HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Decode HTML entities
        text = decodeHTMLEntities(text)
        
        // Clean whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseHTMLSections(from html: String) -> [DocumentationSection] {
        var sections: [DocumentationSection] = []
        
        // Find h2, h3 headings and their content
        let headingPattern = "<h[23][^>]*>(.*?)</h[23]>"
        guard let regex = try? NSRegularExpression(pattern: headingPattern) else { return [] }
        
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: html) {
                let heading = String(html[range])
                let cleanHeading = extractTextContent(from: heading)
                
                // Extract content after heading (simplified)
                let section = DocumentationSection(
                    heading: cleanHeading,
                    content: [
                        DocumentationContent(
                            type: "paragraph",
                            text: "Content for \(cleanHeading)",
                            code: nil,
                            language: nil
                        )
                    ]
                )
                sections.append(section)
            }
        }
        
        return sections
    }
    
    private func extractCodeBlocks(from html: String) -> [DocCodeExample] {
        var examples: [DocCodeExample] = []
        
        // Find code blocks
        let codePattern = "<code[^>]*>(.*?)</code>"
        guard let regex = try? NSRegularExpression(pattern: codePattern, options: .dotMatchesLineSeparators) else {
            return []
        }
        
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)
        
        for (index, match) in matches.prefix(10).enumerated() {
            if let range = Range(match.range(at: 1), in: html) {
                let code = String(html[range])
                let cleanCode = decodeHTMLEntities(code)
                
                let example = DocCodeExample(
                    title: "Example \(index + 1)",
                    code: cleanCode,
                    language: "swift",
                    description: nil
                )
                examples.append(example)
            }
        }
        
        return examples
    }
    
    private func detectPlatforms(from text: String) -> [String] {
        var platforms: [String] = []
        let lowercased = text.lowercased()
        
        if lowercased.contains("ios") { platforms.append("iOS") }
        if lowercased.contains("macos") { platforms.append("macOS") }
        if lowercased.contains("watchos") { platforms.append("watchOS") }
        if lowercased.contains("tvos") { platforms.append("tvOS") }
        if lowercased.contains("visionos") { platforms.append("visionOS") }
        
        return platforms.isEmpty ? ["iOS", "macOS"] : platforms
    }
    
    private func extractAvailability(from html: String) -> String {
        // Look for availability information
        if html.contains("iOS 17") || html.contains("macOS 14") {
            return "iOS 17.0+, macOS 14.0+"
        }
        return "iOS 13.0+, macOS 10.15+"
    }
    
    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        return result
    }
    
    private func generateID(from url: String) -> String {
        url.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "-", options: .regularExpression)
            .lowercased()
    }
    
    // MARK: - Save Database
    
    private func saveDatabase(_ database: DocumentationDatabase, filename: String) async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(database)
            
            // Save to app support directory
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
            try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
            let fileURL = appFolder.appendingPathComponent(filename)
            
            try data.write(to: fileURL)
            print("✅ Saved documentation database to: \(fileURL.path)")
            
            // Also save to project directory for bundling
            if let projectURL = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent() {
                let projectFile = projectURL.appendingPathComponent("HIG").appendingPathComponent(filename)
                try? data.write(to: projectFile)
                print("✅ Also saved to project: \(projectFile.path)")
            }
        } catch {
            print("❌ Failed to save database: \(error)")
        }
    }
}

// MARK: - Models (HIG-compatible format)

struct DocumentationDatabase: Codable {
    let version: String
    let generatedAt: String
    let source: String
    let topicCount: Int
    let topics: [DocumentationTopic]
}

struct DocumentationTopic: Codable {
    let id: String
    let title: String
    let category: String
    let subcategory: String?
    let abstract: String
    let url: String
    let sections: [DocumentationSection]
    let relatedTopics: [RelatedTopic]
    let platforms: [String]
    let availability: String
    let codeExamples: [DocCodeExample]
}

struct DocumentationSection: Codable {
    let heading: String
    let content: [DocumentationContent]
}

struct DocumentationContent: Codable {
    let type: String // "paragraph", "code", "list", "image"
    let text: String?
    let code: String?
    let language: String?
}

struct RelatedTopic: Codable {
    let title: String
    let url: String
}

struct DocCodeExample: Codable {
    let title: String
    let code: String
    let language: String
    let description: String?
}
