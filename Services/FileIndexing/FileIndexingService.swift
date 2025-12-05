//
//  FileIndexingService.swift
//  HIG
//
//  Comprehensive file system indexing service
//  Indexes home directory, developer docs, and GitHub repos
//

import Foundation
import Combine
import UniformTypeIdentifiers

@MainActor
class FileIndexingService: ObservableObject {
    
    static let shared = FileIndexingService()
    
    // MARK: - Published State
    
    @Published var indexingState: IndexingState = .idle
    @Published var indexedFiles: [IndexedFile] = []
    @Published var indexedRepositories: [GitHubRepository] = []
    @Published var statistics: IndexStatistics = IndexStatistics()
    @Published var isIndexing: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentOperation: String = ""
    
    // MARK: - Configuration
    
    @Published var config: IndexingConfig = IndexingConfig.load()
    
    // MARK: - Private State
    
    private var fileIndex: [String: IndexedFile] = [:]
    private var searchIndex: [String: Set<String>] = [:] // word -> file paths
    private var cancellables = Set<AnyCancellable>()
    private let indexQueue = DispatchQueue(label: "com.hig.fileindexing", qos: .utility)
    
    private init() {
        loadPersistedIndex()
    }
    
    // MARK: - Public API
    
    /// Start automatic indexing of configured directories
    func startAutomaticIndexing() async {
        guard !isIndexing else { return }
        
        isIndexing = true
        indexingState = .indexing
        progress = 0.0
        
        var totalProgress = 0.0
        let tasks = 4 // home, developer, swift, github
        
        // Index home directory
        if config.indexHomeDirectory {
            currentOperation = "Indexing home directory..."
            await indexHomeDirectory()
            totalProgress += 1.0 / Double(tasks)
            progress = totalProgress
        }
        
        // Index Apple developer documentation
        if config.indexAppleDocs {
            currentOperation = "Indexing Apple documentation..."
            await indexAppleDeveloperDocs()
            totalProgress += 1.0 / Double(tasks)
            progress = totalProgress
        }
        
        // Index Swift documentation
        if config.indexSwiftDocs {
            currentOperation = "Indexing Swift documentation..."
            await indexSwiftDocs()
            totalProgress += 1.0 / Double(tasks)
            progress = totalProgress
        }
        
        // Index GitHub repositories
        if config.indexGitHubRepos {
            currentOperation = "Indexing GitHub repositories..."
            await indexGitHubRepositories()
            totalProgress += 1.0 / Double(tasks)
            progress = totalProgress
        }
        
        // Build search index
        currentOperation = "Building search index..."
        await buildSearchIndex()
        
        // Save to disk
        currentOperation = "Saving index..."
        saveIndex()
        
        isIndexing = false
        indexingState = .complete
        progress = 1.0
        currentOperation = "Complete"
        
        print("✅ Indexing complete: \(statistics.totalFiles) files indexed")
    }
    
    /// Search indexed files
    func search(query: String, limit: Int = 50) -> [IndexedFile] {
        let words = tokenize(query)
        var scores: [String: Int] = [:]
        
        for word in words {
            if let paths = searchIndex[word] {
                for path in paths {
                    scores[path, default: 0] += 1
                }
            }
            
            // Partial matches
            for (indexWord, paths) in searchIndex {
                if indexWord.contains(word) || word.contains(indexWord) {
                    for path in paths {
                        scores[path, default: 0] += 1
                    }
                }
            }
        }
        
        let sortedPaths = scores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
        return sortedPaths.compactMap { fileIndex[$0] }
    }
    
    /// Get files by type
    func files(ofType type: FileType) -> [IndexedFile] {
        indexedFiles.filter { $0.type == type }
    }
    
    /// Get recently modified files
    func recentFiles(limit: Int = 20) -> [IndexedFile] {
        indexedFiles.sorted { $0.modifiedDate > $1.modifiedDate }.prefix(limit).map { $0 }
    }
    
    // MARK: - Home Directory Indexing
    
    private func indexHomeDirectory() async {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        
        let excludedPaths = [
            ".Trash",
            "Library/Caches",
            "Library/Logs",
            ".cache",
            "node_modules",
            ".git"
        ]
        
        await indexDirectory(homeURL, excludedPaths: excludedPaths, maxDepth: config.maxDepth)
    }
    
    // MARK: - Apple Developer Documentation
    
    private func indexAppleDeveloperDocs() async {
        let possiblePaths = [
            "/Applications/Xcode.app/Contents/Developer/Documentation",
            "/Library/Developer/Documentation",
            "~/Library/Developer/Xcode/Documentation"
        ]
        
        for pathString in possiblePaths {
            let expandedPath = NSString(string: pathString).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath)
            
            if FileManager.default.fileExists(atPath: url.path) {
                await indexDirectory(url, excludedPaths: [], maxDepth: 10)
            }
        }
    }
    
    // MARK: - Swift Documentation
    
    private func indexSwiftDocs() async {
        let possiblePaths = [
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/doc/swift",
            "/usr/share/doc/swift",
            "~/Library/Developer/Swift"
        ]
        
        for pathString in possiblePaths {
            let expandedPath = NSString(string: pathString).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath)
            
            if FileManager.default.fileExists(atPath: url.path) {
                await indexDirectory(url, excludedPaths: [], maxDepth: 10)
            }
        }
    }
    
    // MARK: - GitHub Repository Indexing
    
    private func indexGitHubRepositories() async {
        // Find all git repositories in common locations
        let searchPaths = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Projects"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Developer"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents")
        ]
        
        for searchPath in searchPaths {
            guard FileManager.default.fileExists(atPath: searchPath.path) else { continue }
            await findAndIndexGitRepositories(in: searchPath)
        }
    }
    
    private func findAndIndexGitRepositories(in directory: URL) async {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return }
        
        for case let url as URL in enumerator {
            // Check if this is a git repository
            let gitDir = url.appendingPathComponent(".git")
            if FileManager.default.fileExists(atPath: gitDir.path) {
                await indexGitRepository(at: url)
                enumerator.skipDescendants() // Don't go into subdirectories
            }
        }
    }
    
    private func indexGitRepository(at url: URL) async {
        // Extract repository info
        let repoName = url.lastPathComponent
        let gitConfig = url.appendingPathComponent(".git/config")
        
        var remoteURL: String?
        if let configData = try? String(contentsOf: gitConfig, encoding: .utf8) {
            // Parse git config for remote URL
            let lines = configData.components(separatedBy: .newlines)
            for (i, line) in lines.enumerated() {
                if line.contains("[remote \"origin\"]") && i + 1 < lines.count {
                    let nextLine = lines[i + 1]
                    if let urlRange = nextLine.range(of: "url = ") {
                        remoteURL = String(nextLine[urlRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        }
        
        let repo = GitHubRepository(
            id: UUID(),
            name: repoName,
            localPath: url.path,
            remoteURL: remoteURL,
            lastIndexed: Date()
        )
        
        indexedRepositories.append(repo)
        
        // Index repository files
        await indexDirectory(url, excludedPaths: [".git", "node_modules", "build", ".build"], maxDepth: 10)
    }
    
    // MARK: - Directory Indexing
    
    private func indexDirectory(_ url: URL, excludedPaths: [String], maxDepth: Int, currentDepth: Int = 0) async {
        guard currentDepth < maxDepth else { return }
        
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [
                .isDirectoryKey,
                .fileSizeKey,
                .contentModificationDateKey,
                .contentTypeKey
            ],
            options: [.skipsHiddenFiles]
        ) else { return }
        
        var processedCount = 0
        
        for case let fileURL as URL in enumerator {
            // Check if path should be excluded
            let relativePath = fileURL.path.replacingOccurrences(of: url.path, with: "")
            if excludedPaths.contains(where: { relativePath.contains($0) }) {
                enumerator.skipDescendants()
                continue
            }
            
            // Check file size limit
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize,
               fileSize > config.maxFileSizeBytes {
                continue
            }
            
            // Index the file
            if let indexedFile = await indexFile(at: fileURL) {
                fileIndex[fileURL.path] = indexedFile
                indexedFiles.append(indexedFile)
                statistics.totalFiles += 1
                statistics.totalSize += indexedFile.size
                
                processedCount += 1
                if processedCount % 100 == 0 {
                    // Update progress periodically
                    await MainActor.run {
                        currentOperation = "Indexed \(statistics.totalFiles) files..."
                    }
                }
            }
        }
    }
    
    private func indexFile(at url: URL) async -> IndexedFile? {
        let _ = FileManager.default // File manager for operations
        
        guard let resourceValues = try? url.resourceValues(forKeys: [
            .fileSizeKey,
            .contentModificationDateKey,
            .contentTypeKey,
            .isDirectoryKey
        ]) else { return nil }
        
        // Skip directories
        if resourceValues.isDirectory == true {
            return nil
        }
        
        let fileSize = resourceValues.fileSize ?? 0
        let modifiedDate = resourceValues.contentModificationDate ?? Date()
        let contentType = resourceValues.contentType
        
        // Determine file type
        let fileType = determineFileType(from: url, contentType: contentType)
        
        // Extract content for text files
        var content: String?
        var keywords: [String] = []
        
        if fileType.isTextBased && fileSize < 1_000_000 { // Only index text files under 1MB
            content = try? String(contentsOf: url, encoding: .utf8)
            if let text = content {
                keywords = extractKeywords(from: text)
            }
        }
        
        return IndexedFile(
            id: UUID(),
            path: url.path,
            name: url.lastPathComponent,
            type: fileType,
            size: Int64(fileSize),
            modifiedDate: modifiedDate,
            content: content,
            keywords: keywords
        )
    }
    
    // MARK: - Search Index Building
    
    private func buildSearchIndex() async {
        searchIndex.removeAll()
        
        for file in indexedFiles {
            // Index filename
            let nameWords = tokenize(file.name)
            for word in nameWords {
                searchIndex[word, default: []].insert(file.path)
            }
            
            // Index keywords
            for keyword in file.keywords {
                searchIndex[keyword, default: []].insert(file.path)
            }
            
            // Index path components
            let pathComponents = file.path.components(separatedBy: "/")
            for component in pathComponents {
                let words = tokenize(component)
                for word in words {
                    searchIndex[word, default: []].insert(file.path)
                }
            }
        }
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
        return wordFrequency.sorted { $0.value > $1.value }.prefix(20).map { $0.key }
    }
    
    private func determineFileType(from url: URL, contentType: UTType?) -> FileType {
        let ext = url.pathExtension.lowercased()
        
        // Code files
        if ["swift", "m", "mm", "h", "c", "cpp", "hpp"].contains(ext) {
            return .code
        }
        
        // Documentation
        if ["md", "markdown", "txt", "rtf", "pdf"].contains(ext) {
            return .documentation
        }
        
        // Configuration
        if ["json", "yaml", "yml", "plist", "xml", "toml"].contains(ext) {
            return .configuration
        }
        
        // Images
        if ["png", "jpg", "jpeg", "gif", "svg", "heic"].contains(ext) {
            return .image
        }
        
        // Videos
        if ["mp4", "mov", "avi", "mkv"].contains(ext) {
            return .video
        }
        
        // Audio
        if ["mp3", "m4a", "wav", "aiff"].contains(ext) {
            return .audio
        }
        
        return .other
    }
    
    // MARK: - Persistence
    
    private func saveIndex() {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(IndexSnapshot(
                files: indexedFiles,
                repositories: indexedRepositories,
                statistics: statistics,
                lastUpdated: Date()
            ))
            
            let url = indexFileURL()
            try data.write(to: url)
            print("✅ Saved index to \(url.path)")
        } catch {
            print("❌ Failed to save index: \(error)")
        }
    }
    
    private func loadPersistedIndex() {
        let url = indexFileURL()
        
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(IndexSnapshot.self, from: data) else {
            return
        }
        
        indexedFiles = snapshot.files
        indexedRepositories = snapshot.repositories
        statistics = snapshot.statistics
        
        // Rebuild file index
        for file in indexedFiles {
            fileIndex[file.path] = file
        }
        
        Task {
            await buildSearchIndex()
        }
        
        print("✅ Loaded persisted index: \(indexedFiles.count) files")
    }
    
    private func indexFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        return appFolder.appendingPathComponent("file_index.json")
    }
}

// MARK: - Models

enum IndexingState {
    case idle
    case indexing
    case complete
    case error(String)
}

struct IndexedFile: Codable, Identifiable {
    let id: UUID
    let path: String
    let name: String
    let type: FileType
    let size: Int64
    let modifiedDate: Date
    let content: String?
    let keywords: [String]
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

enum FileType: String, Codable {
    case code
    case documentation
    case configuration
    case image
    case video
    case audio
    case other
    
    var isTextBased: Bool {
        switch self {
        case .code, .documentation, .configuration:
            return true
        default:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .documentation: return "doc.text"
        case .configuration: return "gearshape"
        case .image: return "photo"
        case .video: return "video"
        case .audio: return "waveform"
        case .other: return "doc"
        }
    }
}

struct GitHubRepository: Codable, Identifiable {
    let id: UUID
    let name: String
    let localPath: String
    let remoteURL: String?
    let lastIndexed: Date
}

struct IndexStatistics: Codable {
    var totalFiles: Int = 0
    var totalSize: Int64 = 0
    var lastIndexed: Date?
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

struct IndexingConfig: Codable {
    var indexHomeDirectory: Bool = true
    var indexAppleDocs: Bool = true
    var indexSwiftDocs: Bool = true
    var indexGitHubRepos: Bool = true
    var maxDepth: Int = 10
    var maxFileSizeBytes: Int = 10_000_000 // 10MB
    var autoReindexInterval: TimeInterval = 86400 // 24 hours
    
    static func load() -> IndexingConfig {
        guard let data = UserDefaults.standard.data(forKey: "indexingConfig"),
              let config = try? JSONDecoder().decode(IndexingConfig.self, from: data) else {
            return IndexingConfig()
        }
        return config
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "indexingConfig")
        }
    }
}

struct IndexSnapshot: Codable {
    let files: [IndexedFile]
    let repositories: [GitHubRepository]
    let statistics: IndexStatistics
    let lastUpdated: Date
}
