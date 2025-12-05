//
//  WebCrawlerService.swift
//  HIG
//
//  Web crawler for Apple Developer and Swift documentation websites
//  Indexes online documentation for offline access and search
//

import Foundation
import Combine

@MainActor
class WebCrawlerService: ObservableObject {
    
    static let shared = WebCrawlerService()
    
    // MARK: - Published State
    
    @Published var crawlState: CrawlState = .idle
    @Published var crawledPages: [CrawledPage] = []
    @Published var statistics: CrawlStatistics = CrawlStatistics()
    @Published var isCrawling: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentURL: String = ""
    
    // MARK: - Configuration
    
    @Published var config: CrawlerConfig = CrawlerConfig.load()
    
    // MARK: - Private State
    
    private var pageIndex: [String: CrawledPage] = [:]
    private var visitedURLs: Set<String> = []
    private var urlQueue: [URL] = []
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = [
            "User-Agent": "HIG-DocCrawler/1.0 (macOS; Educational Purpose)"
        ]
        self.session = URLSession(configuration: configuration)
        
        loadPersistedIndex()
    }
    
    // MARK: - Public API
    
    /// Start crawling configured documentation sites
    func startCrawling() async {
        guard !isCrawling else { return }
        
        isCrawling = true
        crawlState = .crawling
        progress = 0.0
        
        // Crawl Apple Developer Documentation
        if config.crawlAppleDocs {
            currentURL = "Crawling Apple Developer Documentation..."
            await crawlAppleDeveloperDocs()
        }
        
        // Crawl Swift.org Documentation
        if config.crawlSwiftDocs {
            currentURL = "Crawling Swift.org Documentation..."
            await crawlSwiftOrgDocs()
        }
        
        // Save index
        currentURL = "Saving index..."
        saveIndex()
        
        isCrawling = false
        crawlState = .complete
        progress = 1.0
        currentURL = "Complete"
        
        print("✅ Web crawling complete: \(statistics.totalPages) pages indexed")
    }
    
    /// Search crawled pages
    func search(query: String, limit: Int = 50) -> [CrawledPage] {
        let words = tokenize(query)
        var scores: [String: Int] = [:]
        
        for page in crawledPages {
            var score = 0
            let searchableText = "\(page.title) \(page.content)".lowercased()
            
            for word in words {
                if searchableText.contains(word) {
                    score += searchableText.components(separatedBy: word).count - 1
                }
            }
            
            if score > 0 {
                scores[page.url] = score
            }
        }
        
        let sortedURLs = scores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
        return sortedURLs.compactMap { url in crawledPages.first { $0.url == url } }
    }
    
    // MARK: - Apple Developer Documentation Crawling
    
    private func crawlAppleDeveloperDocs() async {
        let startURLs = [
            "https://developer.apple.com/documentation/",
            "https://developer.apple.com/documentation/swiftui",
            "https://developer.apple.com/documentation/uikit",
            "https://developer.apple.com/documentation/foundation",
            "https://developer.apple.com/documentation/combine",
            "https://developer.apple.com/design/human-interface-guidelines/"
        ]
        
        for urlString in startURLs {
            guard let url = URL(string: urlString) else { continue }
            await crawlSite(startURL: url, maxPages: config.maxPagesPerSite, domain: "developer.apple.com")
        }
    }
    
    // MARK: - Swift.org Documentation Crawling
    
    private func crawlSwiftOrgDocs() async {
        let startURLs = [
            "https://www.swift.org/documentation/",
            "https://docs.swift.org/swift-book/",
            "https://www.swift.org/getting-started/",
            "https://www.swift.org/swift-evolution/"
        ]
        
        for urlString in startURLs {
            guard let url = URL(string: urlString) else { continue }
            await crawlSite(startURL: url, maxPages: config.maxPagesPerSite, domain: "swift.org")
        }
    }
    
    // MARK: - Core Crawling Logic
    
    private func crawlSite(startURL: URL, maxPages: Int, domain: String) async {
        urlQueue = [startURL]
        var pagesProcessed = 0
        
        while !urlQueue.isEmpty && pagesProcessed < maxPages {
            let url = urlQueue.removeFirst()
            let urlString = url.absoluteString
            
            // Skip if already visited
            guard !visitedURLs.contains(urlString) else { continue }
            visitedURLs.insert(urlString)
            
            currentURL = urlString
            
            // Fetch and parse page
            if let page = await fetchPage(url: url, domain: domain) {
                pageIndex[urlString] = page
                crawledPages.append(page)
                statistics.totalPages += 1
                statistics.totalSize += Int64(page.content.count)
                
                // Extract and queue links
                let links = extractLinks(from: page.content, baseURL: url, domain: domain)
                urlQueue.append(contentsOf: links)
            }
            
            pagesProcessed += 1
            progress = Double(pagesProcessed) / Double(maxPages)
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: UInt64(config.delayBetweenRequests * 1_000_000_000))
        }
    }
    
    private func fetchPage(url: URL, domain: String) async -> CrawledPage? {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let html = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            // Parse HTML
            let title = extractTitle(from: html)
            let content = extractTextContent(from: html)
            let keywords = extractKeywords(from: content)
            
            return CrawledPage(
                id: UUID(),
                url: url.absoluteString,
                title: title,
                content: content,
                keywords: keywords,
                domain: domain,
                crawledAt: Date()
            )
        } catch {
            print("❌ Failed to fetch \(url): \(error)")
            return nil
        }
    }
    
    // MARK: - HTML Parsing
    
    private func extractTitle(from html: String) -> String {
        // Simple regex to extract title
        if let range = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
            let titleTag = String(html[range])
            return titleTag
                .replacingOccurrences(of: "<title>", with: "")
                .replacingOccurrences(of: "</title>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Untitled"
    }
    
    private func extractTextContent(from html: String) -> String {
        // Remove script and style tags
        var text = html
        text = text.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Remove HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Decode HTML entities
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        
        // Clean up whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text
    }
    
    private func extractLinks(from html: String, baseURL: URL, domain: String) -> [URL] {
        var links: [URL] = []
        
        // Simple regex to find href attributes
        let pattern = "href=[\"'](.*?)[\"']"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: html) {
                let href = String(html[range])
                
                // Convert relative URLs to absolute
                if let url = URL(string: href, relativeTo: baseURL)?.absoluteURL {
                    // Only include URLs from the same domain
                    if url.host?.contains(domain) == true {
                        links.append(url)
                    }
                }
            }
        }
        
        return Array(Set(links)) // Remove duplicates
    }
    
    // MARK: - Utilities
    
    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }
    
    private func extractKeywords(from text: String) -> [String] {
        let words = tokenize(text)
        let wordFrequency = Dictionary(grouping: words, by: { $0 }).mapValues { $0.count }
        return wordFrequency.sorted { $0.value > $1.value }.prefix(30).map { $0.key }
    }
    
    // MARK: - Persistence
    
    private func saveIndex() {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(CrawlSnapshot(
                pages: crawledPages,
                statistics: statistics,
                lastUpdated: Date()
            ))
            
            let url = indexFileURL()
            try data.write(to: url)
            print("✅ Saved crawl index to \(url.path)")
        } catch {
            print("❌ Failed to save crawl index: \(error)")
        }
    }
    
    private func loadPersistedIndex() {
        let url = indexFileURL()
        
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(CrawlSnapshot.self, from: data) else {
            return
        }
        
        crawledPages = snapshot.pages
        statistics = snapshot.statistics
        
        // Rebuild page index
        for page in crawledPages {
            pageIndex[page.url] = page
            visitedURLs.insert(page.url)
        }
        
        print("✅ Loaded persisted crawl index: \(crawledPages.count) pages")
    }
    
    private func indexFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        return appFolder.appendingPathComponent("web_crawl_index.json")
    }
}

// MARK: - Models

enum CrawlState {
    case idle
    case crawling
    case complete
    case error(String)
}

struct CrawledPage: Codable, Identifiable {
    let id: UUID
    let url: String
    let title: String
    let content: String
    let keywords: [String]
    let domain: String
    let crawledAt: Date
}

struct CrawlStatistics: Codable {
    var totalPages: Int = 0
    var totalSize: Int64 = 0
    var lastCrawled: Date?
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

struct CrawlerConfig: Codable {
    var crawlAppleDocs: Bool = true
    var crawlSwiftDocs: Bool = true
    var maxPagesPerSite: Int = 500
    var delayBetweenRequests: Double = 0.5 // seconds
    var respectRobotsTxt: Bool = true
    
    static func load() -> CrawlerConfig {
        guard let data = UserDefaults.standard.data(forKey: "crawlerConfig"),
              let config = try? JSONDecoder().decode(CrawlerConfig.self, from: data) else {
            return CrawlerConfig()
        }
        return config
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "crawlerConfig")
        }
    }
}

struct CrawlSnapshot: Codable {
    let pages: [CrawledPage]
    let statistics: CrawlStatistics
    let lastUpdated: Date
}
