//
//  DocumentSourceManager.swift
//  HIG
//
//  Manages user-selected documentation sources
//  Allows users to add custom documentation folders
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Document Source

struct DocumentSource: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var path: String
    var isEnabled: Bool
    var lastIndexed: Date?
    var documentCount: Int
    var type: SourceType
    
    enum SourceType: String, Codable {
        case builtin = "Built-in"
        case userFolder = "User Folder"
        case git = "Git Repository"
    }
    
    init(id: UUID = UUID(), name: String, path: String, type: SourceType, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.path = path
        self.type = type
        self.isEnabled = isEnabled
        self.lastIndexed = nil
        self.documentCount = 0
    }
}

// MARK: - Document Source Manager

@MainActor
@Observable
class DocumentSourceManager {
    static let shared = DocumentSourceManager()
    
    private(set) var sources: [DocumentSource] = []
    private(set) var isIndexing = false
    private(set) var indexingProgress: Double = 0.0
    private(set) var indexingStatus: String = ""
    
    private let sourcesKey = "documentSources"
    private let bookmarksKey = "securityBookmarks"
    
    private init() {
        loadSources()
    }
    
    // MARK: - Source Management
    
    /// Add a new user-selected folder as a documentation source
    func addUserFolder() async -> Bool {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.title = "Select Documentation Folder"
        panel.message = "Choose a folder containing documentation files (Markdown, HTML, etc.)"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        
        guard panel.runModal() == .OK, let url = panel.url else {
            return false
        }
        
        // Request security-scoped bookmark
        guard let bookmark = try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            return false
        }
        
        // Save bookmark
        saveBookmark(bookmark, for: url.path)
        
        // Create source
        let source = DocumentSource(
            name: url.lastPathComponent,
            path: url.path,
            type: .userFolder
        )
        
        sources.append(source)
        saveSources()
        
        // Index the new source
        await indexSource(source)
        
        return true
        #else
        return false
        #endif
    }
    
    /// Remove a documentation source
    func removeSource(_ source: DocumentSource) {
        sources.removeAll { $0.id == source.id }
        removeBookmark(for: source.path)
        saveSources()
    }
    
    /// Toggle source enabled state
    func toggleSource(_ source: DocumentSource) {
        if let index = sources.firstIndex(where: { $0.id == source.id }) {
            sources[index].isEnabled.toggle()
            saveSources()
        }
    }
    
    /// Re-index a specific source
    func reindexSource(_ source: DocumentSource) async {
        await indexSource(source)
    }
    
    /// Re-index all enabled sources
    func reindexAll() async {
        for source in sources where source.isEnabled {
            await indexSource(source)
        }
    }
    
    // MARK: - Indexing
    
    private func indexSource(_ source: DocumentSource) async {
        isIndexing = true
        indexingProgress = 0.0
        indexingStatus = "Indexing \(source.name)..."
        
        defer {
            isIndexing = false
            indexingProgress = 1.0
        }
        
        // Access security-scoped resource
        guard let url = accessSecurityScopedResource(path: source.path) else {
            indexingStatus = "Failed to access \(source.name)"
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Scan for documentation files
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles] // Don't skip packages - we want to look inside bundles/frameworks
        ) else {
            return
        }
        
        var documentCount = 0
        
        // Comprehensive list of documentation file extensions
        let supportedExtensions = [
            // Markup languages
            "md", "markdown", "mdown", "mkd", "mkdn",
            "html", "htm", "xhtml",
            "txt", "text",
            "rst", "rest",
            "adoc", "asciidoc",
            "org",
            "textile",
            "rdoc",
            
            // Code documentation
            "swift", "h", "m", "mm", "c", "cpp", "cc", "cxx",
            "java", "kt", "kts",
            "js", "ts", "jsx", "tsx",
            "py", "rb", "go", "rs",
            "php", "pl", "sh", "bash",
            
            // Configuration & data
            "json", "yaml", "yml", "toml", "xml", "plist",
            "ini", "conf", "config",
            
            // Documentation formats
            "pdf", "rtf", "tex",
            
            // Shader files (for graphics documentation)
            "glsl", "hlsl", "metal", "vert", "frag", "comp",
            
            // Diagnostic & log files
            "log", "logs",
            "diag", "diagnostic",
            "hang", "hanglog",
            "spin", "spinlog",
            "crash", "crashlog",
            "cat", "catalog",
            "bom", "bill-of-materials",
            
            // Database files (for documentation/metadata)
            "db", "sqlite", "sqlite3",
            "sql", "dump",
            
            // Special files (no extension)
            "readme", "license", "changelog", "contributing",
            "authors", "todo", "makefile", "dockerfile"
        ]
        
        // Bundle/Framework types to look inside
        let bundleExtensions = ["bundle", "framework", "xcframework", "docc", "doccarchive"]
        
        for case let fileURL as URL in enumerator {
            // Check if it's a bundle/framework - look inside it
            if bundleExtensions.contains(fileURL.pathExtension.lowercased()) {
                // Don't skip this directory, continue enumerating inside
                continue
            }
            
            // Check if it's a supported file
            let ext = fileURL.pathExtension.lowercased()
            let filename = fileURL.lastPathComponent.lowercased()
            
            // Match by extension or by special filenames (README, LICENSE, etc.)
            let isSupported = supportedExtensions.contains(ext) ||
                             supportedExtensions.contains(where: { filename.hasPrefix($0) })
            
            // Also check for files without extensions that might be text
            let hasNoExtension = ext.isEmpty && !filename.starts(with: ".")
            
            if isSupported || hasNoExtension {
                // Verify it's actually a file we can read
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory),
                      !isDirectory.boolValue else {
                    continue
                }
                
                // Check if file is readable text (not binary)
                if isReadableTextFile(at: fileURL) {
                    documentCount += 1
                    indexingProgress = min(Double(documentCount) / 100.0, 0.9)
                    
                    // Extract structured content from the file
                    if let extracted = DocumentExtractor.extract(from: fileURL) {
                        // TODO: Store extracted content in search index
                        // For now, just count it
                        indexingStatus = "Indexing: \(extracted.title)"
                    }
                }
            }
        }
        
        // Update source
        if let index = sources.firstIndex(where: { $0.id == source.id }) {
            sources[index].lastIndexed = Date()
            sources[index].documentCount = documentCount
            saveSources()
        }
        
        indexingStatus = "Indexed \(documentCount) documents from \(source.name)"
        indexingProgress = 1.0
    }
    
    // MARK: - Security-Scoped Bookmarks
    
    private func saveBookmark(_ bookmark: Data, for path: String) {
        var bookmarks = loadBookmarks()
        bookmarks[path] = bookmark
        UserDefaults.standard.set(try? NSKeyedArchiver.archivedData(withRootObject: bookmarks, requiringSecureCoding: false), forKey: bookmarksKey)
    }
    
    private func removeBookmark(for path: String) {
        var bookmarks = loadBookmarks()
        bookmarks.removeValue(forKey: path)
        UserDefaults.standard.set(try? NSKeyedArchiver.archivedData(withRootObject: bookmarks, requiringSecureCoding: false), forKey: bookmarksKey)
    }
    
    private func loadBookmarks() -> [String: Data] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let bookmarks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Data] else {
            return [:]
        }
        return bookmarks
    }
    
    private func accessSecurityScopedResource(path: String) -> URL? {
        let bookmarks = loadBookmarks()
        guard let bookmark = bookmarks[path] else {
            return nil
        }
        
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }
        
        return url
    }
    
    // MARK: - File Type Detection
    
    /// Checks if a file is readable text (not binary)
    private func isReadableTextFile(at url: URL) -> Bool {
        // Known text extensions that are always safe
        let alwaysTextExtensions = [
            "md", "markdown", "txt", "html", "htm", "json", "yaml", "yml",
            "xml", "plist", "swift", "h", "m", "c", "cpp", "java", "py",
            "js", "ts", "sh", "bash", "rb", "go", "rs", "toml", "ini",
            "log", "diag", "hang", "spin", "crash", "cat", "sql"
        ]
        
        if alwaysTextExtensions.contains(url.pathExtension.lowercased()) {
            return true
        }
        
        // Special handling for database files - these need special parsing
        let databaseExtensions = ["db", "sqlite", "sqlite3", "bom"]
        if databaseExtensions.contains(url.pathExtension.lowercased()) {
            // For now, mark as readable - we'll need special handling to extract text
            // TODO: Implement SQLite query extraction for documentation
            return true
        }
        
        // For unknown extensions or no extension, check file content
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else {
            return false
        }
        
        defer {
            try? fileHandle.close()
        }
        
        // Read first 512 bytes to check for binary content
        guard let data = try? fileHandle.read(upToCount: 512), !data.isEmpty else {
            return false
        }
        
        // Check for null bytes (common in binary files)
        if data.contains(0) {
            return false
        }
        
        // Check if content is valid UTF-8
        if String(data: data, encoding: .utf8) != nil {
            return true
        }
        
        // Try other common encodings
        if String(data: data, encoding: .ascii) != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - Persistence
    
    private func saveSources() {
        if let encoded = try? JSONEncoder().encode(sources) {
            UserDefaults.standard.set(encoded, forKey: sourcesKey)
        }
    }
    
    private func loadSources() {
        // Load saved sources
        if let data = UserDefaults.standard.data(forKey: sourcesKey),
           let decoded = try? JSONDecoder().decode([DocumentSource].self, from: data) {
            sources = decoded
        }
        
        // Add built-in HIG source if not present
        if !sources.contains(where: { $0.type == .builtin }) {
            let higSource = DocumentSource(
                name: "Apple HIG",
                path: "builtin://hig",
                type: .builtin
            )
            sources.insert(higSource, at: 0)
            saveSources()
        }
    }
}
