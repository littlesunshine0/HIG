//
//  ResourceUpdateManager.swift
//  HIG
//
//  Automatic update system for developer resources
//  Checks for updates, archives old data, and fetches new content
//

import Foundation
import SwiftUI

// MARK: - Update Configuration

struct UpdateConfig: Codable {
    var autoUpdateEnabled: Bool = true
    var updateFrequency: UpdateFrequency = .weekly
    var lastUpdateCheck: Date?
    var lastSuccessfulUpdate: Date?
    var currentVersion: String?
    
    enum UpdateFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case manual = "Manual Only"
        
        var interval: TimeInterval {
            switch self {
            case .daily: return 86400 // 24 hours
            case .weekly: return 604800 // 7 days
            case .monthly: return 2592000 // 30 days
            case .manual: return .infinity
            }
        }
    }
    
    // MARK: - Persistence
    
    private static let configKey = "resourceUpdateConfig"
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.configKey)
        }
    }
    
    static func load() -> UpdateConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(UpdateConfig.self, from: data) else {
            return UpdateConfig()
        }
        return config
    }
}

// MARK: - Update Status

enum UpdateStatus: Equatable {
    case idle
    case checking
    case updateAvailable(version: String)
    case downloading
    case installing
    case complete
    case error(String)
    
    var message: String {
        switch self {
        case .idle: return "Up to date"
        case .checking: return "Checking for updates..."
        case .updateAvailable(let version): return "Update available: \(version)"
        case .downloading: return "Downloading updates..."
        case .installing: return "Installing updates..."
        case .complete: return "Update complete"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

// MARK: - Resource Update Manager

@MainActor
@Observable
class ResourceUpdateManager {
    static let shared = ResourceUpdateManager()
    
    var config = UpdateConfig.load()
    private(set) var status: UpdateStatus = .idle
    private(set) var progress: Double = 0.0
    private(set) var updateAvailable = false
    
    private let fileManager = FileManager.default
    private let knowledgeDir: URL
    private let archiveDir: URL
    
    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        
        knowledgeDir = appFolder.appendingPathComponent("Knowledge", isDirectory: true)
        archiveDir = appFolder.appendingPathComponent("Archives", isDirectory: true)
        
        // Create directories
        try? fileManager.createDirectory(at: knowledgeDir, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: archiveDir, withIntermediateDirectories: true)
    }
    
    // MARK: - Update Check
    
    /// Check if updates are needed based on configuration
    func checkForUpdatesIfNeeded() async {
        guard config.autoUpdateEnabled else { return }
        
        // Check if enough time has passed
        if let lastCheck = config.lastUpdateCheck {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
            if timeSinceLastCheck < config.updateFrequency.interval {
                return // Too soon
            }
        }
        
        await checkForUpdates()
    }
    
    /// Manually check for updates
    func checkForUpdates() async {
        status = .checking
        config.lastUpdateCheck = Date()
        config.save()
        
        do {
            // Check HIG version
            let latestVersion = try await fetchLatestHIGVersion()
            
            if let currentVersion = config.currentVersion {
                if latestVersion != currentVersion {
                    updateAvailable = true
                    status = .updateAvailable(version: latestVersion)
                } else {
                    status = .idle
                }
            } else {
                // First time, consider update available
                updateAvailable = true
                status = .updateAvailable(version: latestVersion)
            }
        } catch {
            status = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Update Execution
    
    /// Perform the update
    func performUpdate() async {
        guard updateAvailable else { return }
        
        status = .downloading
        progress = 0.0
        
        do {
            // 1. Archive current data
            try await archiveCurrentData()
            progress = 0.2
            
            // 2. Fetch HIG updates
            try await updateHIGData()
            progress = 0.5
            
            // 3. Fetch developer resources
            try await updateDeveloperResources()
            progress = 0.8
            
            // 4. Rebuild indexes
            try await rebuildIndexes()
            progress = 1.0
            
            // 5. Update version
            if let latestVersion = try? await fetchLatestHIGVersion() {
                config.currentVersion = latestVersion
            }
            config.lastSuccessfulUpdate = Date()
            config.save()
            
            status = .complete
            updateAvailable = false
            
            // Post notification
            NotificationCenter.default.post(name: .resourcesUpdated, object: nil)
            
        } catch {
            status = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Archive Management
    
    private func archiveCurrentData() async throws {
        status = .installing
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let archiveName = "knowledge_\(timestamp)"
        let archiveURL = archiveDir.appendingPathComponent(archiveName, isDirectory: true)
        
        // Copy current knowledge directory to archive
        if fileManager.fileExists(atPath: knowledgeDir.path) {
            try fileManager.copyItem(at: knowledgeDir, to: archiveURL)
        }
        
        // Keep only last 5 archives
        try cleanOldArchives(keepCount: 5)
    }
    
    private func cleanOldArchives(keepCount: Int) throws {
        let archives = try fileManager.contentsOfDirectory(
            at: archiveDir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        // Sort by creation date (newest first)
        let sortedArchives = archives.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            return date1 > date2
        }
        
        // Remove old archives
        for archive in sortedArchives.dropFirst(keepCount) {
            try fileManager.removeItem(at: archive)
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchLatestHIGVersion() async throws -> String {
        // Check Apple's HIG for version/last modified date
        let url = URL(string: "https://developer.apple.com/design/human-interface-guidelines/")!
        let (_, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse,
           let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified") {
            return lastModified
        }
        
        // Fallback to current date
        return ISO8601DateFormatter().string(from: Date())
    }
    
    private func updateHIGData() async throws {
        // Run Python script to fetch HIG content
        let scriptPath = Bundle.main.resourcePath! + "/scripts/fetch_hig_content.py"
        
        // Note: In production, you'd run this via Process
        // For now, we'll simulate
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    private func updateDeveloperResources() async throws {
        // Run Python script to fetch developer resources
        try await runPythonScript("fetch_developer_resources.py")
    }
    
    private func rebuildIndexes() async throws {
        // Run Python scripts to rebuild indexes
        try await runPythonScript("build_resource_index.py")
        try await runPythonScript("update_ai_knowledge.py", args: ["--force"])
        
        // Reload AI knowledge base
        await AIKnowledgeBase.shared.loadKnowledgeBase()
    }
    
    private func runPythonScript(_ scriptName: String, args: [String] = []) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        // Find script in bundle or workspace
        var scriptPath: String?
        if let bundlePath = Bundle.main.resourcePath {
            scriptPath = bundlePath + "/scripts/" + scriptName
        }
        
        // Fallback to workspace relative path
        if scriptPath == nil || !FileManager.default.fileExists(atPath: scriptPath!) {
            let workspacePath = FileManager.default.currentDirectoryPath
            scriptPath = workspacePath + "/scripts/" + scriptName
        }
        
        guard let finalPath = scriptPath, FileManager.default.fileExists(atPath: finalPath) else {
            throw NSError(domain: "ResourceUpdateManager", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Script not found: \(scriptName)"
            ])
        }
        
        process.arguments = ["python3", finalPath] + args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ResourceUpdateManager", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Script failed: \(output)"
            ])
        }
    }
    
    // MARK: - Restore from Archive
    
    func restoreFromArchive(archiveName: String) async throws {
        let archiveURL = archiveDir.appendingPathComponent(archiveName, isDirectory: true)
        
        guard fileManager.fileExists(atPath: archiveURL.path) else {
            throw NSError(domain: "ResourceUpdateManager", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Archive not found"
            ])
        }
        
        // Remove current knowledge directory
        if fileManager.fileExists(atPath: knowledgeDir.path) {
            try fileManager.removeItem(at: knowledgeDir)
        }
        
        // Restore from archive
        try fileManager.copyItem(at: archiveURL, to: knowledgeDir)
        
        // Post notification
        NotificationCenter.default.post(name: .resourcesUpdated, object: nil)
    }
    
    func listArchives() -> [String] {
        guard let archives = try? fileManager.contentsOfDirectory(
            at: archiveDir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        return archives
            .sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 > date2
            }
            .map { $0.lastPathComponent }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let resourcesUpdated = Notification.Name("resourcesUpdated")
}
