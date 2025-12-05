//
//  DocumentationImporter.swift
//  HIG
//
//  Service for importing external documentation from websites
//

import Foundation
import Combine

#if canImport(WebKit)
import WebKit
#endif

// MARK: - Import Configuration

struct DocumentationImportConfig: Codable {
    var name: String
    var baseURL: String
    var mode: ImportMode
    var maxDepth: Int = 3
    var includePatterns: [String] = []
    var excludePatterns: [String] = []
    var selectors: ContentSelectors
    
    enum ImportMode: String, Codable {
        case singlePage = "Single Page"
        case entireSite = "Entire Site"
        case sitemap = "From Sitemap"
    }
    
    struct ContentSelectors: Codable {
        var title: String = "h1, title"
        var content: String = "article, main, .content"
        var navigation: String = "nav a"
        var exclude: [String] = ["script", "style", "nav", "footer", "header"]
    }
}

// MARK: - Imported Documentation

struct ImportedDocumentation: Codable, Identifiable {
    let id: UUID
    var name: String
    var sourceURL: String
    var importDate: Date
    var pages: [ImportedPage]
    var categories: [String]
    
    struct ImportedPage: Codable, Identifiable {
        let id: UUID
        var url: String
        var title: String
        var content: String
        var abstract: String
        var sections: [Section]
        var category: String
        var subcategory: String?
        var metadata: PageMetadata
        
        struct Section: Codable, Identifiable {
            let id: UUID
            var heading: String
            var content: [ContentBlock]
            
            struct ContentBlock: Codable {
                var type: BlockType
                var text: String?
                var code: String?
                var language: String?
                
                enum BlockType: String, Codable {
                    case text, code, list, quote
                }
            }
        }
        
        struct PageMetadata: Codable {
            var author: String?
            var lastModified: Date?
            var tags: [String]
            var depth: Int
        }
    }
}

// MARK: - Documentation Importer Service

@MainActor
class DocumentationImporter: ObservableObject {
    @Published var isImporting = false
    @Published var progress: ImportProgress?
    @Published var error: ImportError?
    @Published var importedDocs: [ImportedDocumentation] = []
    
    struct ImportProgress {
        var currentPage: String
        var pagesProcessed: Int
        var totalPages: Int
        var percentage: Double {
            guard totalPages > 0 else { return 0 }
            return Double(pagesProcessed) / Double(totalPages) * 100
        }
    }
    
    enum ImportError: LocalizedError {
        case invalidURL
        case networkError(String)
        case parsingError(String)
        case cancelled
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL provided"
            case .networkError(let msg): return "Network error: \(msg)"
            case .parsingError(let msg): return "Parsing error: \(msg)"
            case .cancelled: return "Import cancelled"
            }
        }
    }
    
    private var importTask: Task<Void, Never>?
    
    // MARK: - Import Methods
    
    func importDocumentation(config: DocumentationImportConfig) async {
        isImporting = true
        error = nil
        
        importTask = Task {
            do {
                let documentation = try await performImport(config: config)
                importedDocs.append(documentation)
                await saveImportedDocs()
            } catch {
                self.error = error as? ImportError ?? .parsingError(error.localizedDescription)
            }
            isImporting = false
            progress = nil
        }
        
        await importTask?.value
    }
    
    func cancelImport() {
        importTask?.cancel()
        isImporting = false
        error = .cancelled
    }
    
    private func performImport(config: DocumentationImportConfig) async throws -> ImportedDocumentation {
        switch config.mode {
        case .singlePage:
            return try await importSinglePage(config: config)
        case .entireSite:
            return try await importEntireSite(config: config)
        case .sitemap:
            return try await importFromSitemap(config: config)
        }
    }
    
    // MARK: - Single Page Import
    
    private func importSinglePage(config: DocumentationImportConfig) async throws -> ImportedDocumentation {
        guard let url = URL(string: config.baseURL) else {
            throw ImportError.invalidURL
        }
        
        progress = ImportProgress(currentPage: config.baseURL, pagesProcessed: 0, totalPages: 1)
        
        let page = try await fetchAndParsePage(url: url, config: config, depth: 0)
        
        progress?.pagesProcessed = 1
        
        return ImportedDocumentation(
            id: UUID(),
            name: config.name,
            sourceURL: config.baseURL,
            importDate: Date(),
            pages: [page],
            categories: [page.category]
        )
    }
    
    // MARK: - Entire Site Import
    
    private func importEntireSite(config: DocumentationImportConfig) async throws -> ImportedDocumentation {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ImportError.invalidURL
        }
        
        var visitedURLs = Set<String>()
        var pagesToVisit = [baseURL]
        var importedPages: [ImportedDocumentation.ImportedPage] = []
        var depth = 0
        
        progress = ImportProgress(currentPage: config.baseURL, pagesProcessed: 0, totalPages: 1)
        
        while !pagesToVisit.isEmpty && depth <= config.maxDepth {
            guard !Task.isCancelled else { throw ImportError.cancelled }
            
            let currentBatch = pagesToVisit
            pagesToVisit.removeAll()
            
            for url in currentBatch {
                let urlString = url.absoluteString
                guard !visitedURLs.contains(urlString) else { continue }
                guard shouldIncludeURL(urlString, config: config) else { continue }
                
                visitedURLs.insert(urlString)
                progress?.currentPage = urlString
                
                do {
                    let page = try await fetchAndParsePage(url: url, config: config, depth: depth)
                    importedPages.append(page)
                    
                    // Extract links for next level
                    if depth < config.maxDepth {
                        let links = try await extractLinks(from: url, config: config)
                        pagesToVisit.append(contentsOf: links)
                    }
                    
                    progress?.pagesProcessed = importedPages.count
                    progress?.totalPages = visitedURLs.count + pagesToVisit.count
                } catch {
                    print("Failed to import \(urlString): \(error)")
                }
            }
            
            depth += 1
        }
        
        let categories = Set(importedPages.map { $0.category }).sorted()
        
        return ImportedDocumentation(
            id: UUID(),
            name: config.name,
            sourceURL: config.baseURL,
            importDate: Date(),
            pages: importedPages,
            categories: Array(categories)
        )
    }
    
    // MARK: - Sitemap Import
    
    private func importFromSitemap(config: DocumentationImportConfig) async throws -> ImportedDocumentation {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ImportError.invalidURL
        }
        
        // Try common sitemap locations
        let sitemapURLs = [
            baseURL.appendingPathComponent("sitemap.xml"),
            baseURL.appendingPathComponent("sitemap_index.xml"),
            baseURL.appendingPathComponent("sitemap/sitemap.xml")
        ]
        
        var urls: [URL] = []
        for sitemapURL in sitemapURLs {
            if let extractedURLs = try? await parseSitemap(url: sitemapURL) {
                urls = extractedURLs
                break
            }
        }
        
        guard !urls.isEmpty else {
            throw ImportError.parsingError("No sitemap found")
        }
        
        progress = ImportProgress(currentPage: "", pagesProcessed: 0, totalPages: urls.count)
        
        var importedPages: [ImportedDocumentation.ImportedPage] = []
        
        for (index, url) in urls.enumerated() {
            guard !Task.isCancelled else { throw ImportError.cancelled }
            guard shouldIncludeURL(url.absoluteString, config: config) else { continue }
            
            progress?.currentPage = url.absoluteString
            
            do {
                let page = try await fetchAndParsePage(url: url, config: config, depth: 0)
                importedPages.append(page)
            } catch {
                print("Failed to import \(url): \(error)")
            }
            
            progress?.pagesProcessed = index + 1
        }
        
        let categories = Set(importedPages.map { $0.category }).sorted()
        
        return ImportedDocumentation(
            id: UUID(),
            name: config.name,
            sourceURL: config.baseURL,
            importDate: Date(),
            pages: importedPages,
            categories: Array(categories)
        )
    }
    
    // MARK: - HTML Parsing
    
    private func fetchAndParsePage(url: URL, config: DocumentationImportConfig, depth: Int) async throws -> ImportedDocumentation.ImportedPage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ImportError.parsingError("Failed to decode HTML")
        }
        
        // Extract title
        let title = extractTitle(from: html)
        
        // Extract main content
        let content = extractContent(from: html)
        
        // Extract sections
        let sections = extractSections(from: html)
        
        // Generate abstract
        let abstract = generateAbstract(from: content)
        
        // Determine category from URL path
        let category = extractCategory(from: url)
        let subcategory = extractSubcategory(from: url)
        
        // Extract metadata
        let metadata = extractMetadata(from: html, depth: depth)
        
        return ImportedDocumentation.ImportedPage(
            id: UUID(),
            url: url.absoluteString,
            title: title,
            content: content,
            abstract: abstract,
            sections: sections,
            category: category,
            subcategory: subcategory,
            metadata: metadata
        )
    }
    
    private func extractTitle(from html: String) -> String {
        // Try to extract from <title> tag
        if let titleRange = html.range(of: "<title[^>]*>([^<]+)</title>", options: .regularExpression),
           let contentRange = html.range(of: ">([^<]+)<", options: .regularExpression, range: titleRange) {
            let titleText = String(html[contentRange])
            return titleText.replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "<", with: "")
        }
        
        // Try h1
        if let h1Range = html.range(of: "<h1[^>]*>([^<]+)</h1>", options: .regularExpression),
           let contentRange = html.range(of: ">([^<]+)<", options: .regularExpression, range: h1Range) {
            let h1Text = String(html[contentRange])
            return h1Text.replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "<", with: "")
        }
        
        return "Untitled"
    }
    
    private func extractContent(from html: String) -> String {
        // Remove script and style tags
        var cleanHTML = html
        cleanHTML = cleanHTML.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        cleanHTML = cleanHTML.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Remove HTML tags
        cleanHTML = cleanHTML.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Clean up whitespace
        cleanHTML = cleanHTML.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanHTML = cleanHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanHTML
    }
    
    private func extractSections(from html: String) -> [ImportedDocumentation.ImportedPage.Section] {
        var sections: [ImportedDocumentation.ImportedPage.Section] = []
        
        // Find all h2, h3, h4 headings
        let headingPattern = "<h[234][^>]*>([^<]+)</h[234]>"
        let regex = try? NSRegularExpression(pattern: headingPattern, options: [])
        let nsString = html as NSString
        let matches = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for match in matches {
            if match.numberOfRanges > 1 {
                let headingRange = match.range(at: 1)
                let headingText = nsString.substring(with: headingRange)
                
                // Create a simple text block for the section
                let contentBlock = ImportedDocumentation.ImportedPage.Section.ContentBlock(
                    type: .text,
                    text: headingText,
                    code: nil,
                    language: nil
                )
                
                sections.append(ImportedDocumentation.ImportedPage.Section(
                    id: UUID(),
                    heading: headingText,
                    content: [contentBlock]
                ))
            }
        }
        
        return sections
    }
    
    private func extractMetadata(from html: String, depth: Int) -> ImportedDocumentation.ImportedPage.PageMetadata {
        var tags: [String] = []
        
        // Extract meta keywords
        if let keywordsRange = html.range(of: "<meta[^>]*name=[\"']keywords[\"'][^>]*content=[\"']([^\"']+)[\"'][^>]*>", options: .regularExpression),
           let contentRange = html.range(of: "content=[\"']([^\"']+)[\"']", options: .regularExpression, range: keywordsRange) {
            let keywordsText = String(html[contentRange])
            let keywords = keywordsText.replacingOccurrences(of: "content=[\"']", with: "").replacingOccurrences(of: "[\"']", with: "")
            tags = keywords.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        
        return ImportedDocumentation.ImportedPage.PageMetadata(
            author: nil,
            lastModified: nil,
            tags: tags,
            depth: depth
        )
    }
    
    private func extractLinks(from url: URL, config: DocumentationImportConfig) async throws -> [URL] {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        
        // Extract all href attributes
        let linkPattern = "href=[\"']([^\"']+)[\"']"
        let regex = try? NSRegularExpression(pattern: linkPattern, options: [])
        let nsString = html as NSString
        let matches = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        var urls: [URL] = []
        for match in matches {
            if match.numberOfRanges > 1 {
                let hrefRange = match.range(at: 1)
                let href = nsString.substring(with: hrefRange)
                
                if let linkURL = URL(string: href, relativeTo: url)?.absoluteURL,
                   linkURL.host == url.host {
                    urls.append(linkURL)
                }
            }
        }
        
        return Array(Set(urls)) // Remove duplicates
    }
    
    private func parseSitemap(url: URL) async throws -> [URL] {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        
        // Extract all <loc> tags
        let locPattern = "<loc>([^<]+)</loc>"
        let regex = try? NSRegularExpression(pattern: locPattern, options: [])
        let nsString = xml as NSString
        let matches = regex?.matches(in: xml, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        return matches.compactMap { match in
            if match.numberOfRanges > 1 {
                let urlRange = match.range(at: 1)
                let urlString = nsString.substring(with: urlRange)
                return URL(string: urlString)
            }
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func shouldIncludeURL(_ urlString: String, config: DocumentationImportConfig) -> Bool {
        // Check exclude patterns
        for pattern in config.excludePatterns {
            if urlString.contains(pattern) {
                return false
            }
        }
        
        // Check include patterns (if any)
        if !config.includePatterns.isEmpty {
            return config.includePatterns.contains { urlString.contains($0) }
        }
        
        return true
    }
    
    private func extractCategory(from url: URL) -> String {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        return pathComponents.first?.capitalized ?? "General"
    }
    
    private func extractSubcategory(from url: URL) -> String? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        return pathComponents.count > 1 ? pathComponents[1].capitalized : nil
    }
    
    private func generateAbstract(from content: String) -> String {
        let sentences = content.split(separator: ".").map { String($0).trimmingCharacters(in: .whitespaces) }
        let firstSentences = sentences.prefix(2).joined(separator: ". ")
        return firstSentences.count > 200 ? String(firstSentences.prefix(200)) + "..." : firstSentences
    }
    
    // MARK: - Persistence
    
    private func saveImportedDocs() async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(importedDocs) {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("imported_docs.json")
            try? data.write(to: url)
        }
    }
    
    func loadImportedDocs() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("imported_docs.json")
        
        guard let data = try? Data(contentsOf: url) else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let docs = try? decoder.decode([ImportedDocumentation].self, from: data) {
            importedDocs = docs
        }
    }
    
    func deleteImportedDoc(_ doc: ImportedDocumentation) {
        importedDocs.removeAll { $0.id == doc.id }
        Task {
            await saveImportedDocs()
        }
    }
}
