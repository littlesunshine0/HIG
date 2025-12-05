//
//  CloudDataManager.swift
//  HIG
//
//  Cloud-based data management system
//  Syncs all documentation, code, and generated content to cloud storage
//  No local storage - everything is cloud-first
//

import Foundation
import Combine

@MainActor
class CloudDataManager: ObservableObject {
    
    static let shared = CloudDataManager()
    
    // MARK: - Published State
    
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var cloudStatistics: CloudStatistics = CloudStatistics()
    
    // MARK: - Services
    
    private let database = DatabaseService.shared
    private let fileStorage = FileStorageService.shared
    private let billing = BillingService.shared
    
    // MARK: - Configuration
    
    private let cloudConfig = CloudConfig(
        databaseName: "hig_knowledge_base",
        storageBucket: "hig-documentation",
        cdnEndpoint: "https://cdn.hig.app"
    )
    
    private init() {
        setupAutomation()
    }
    
    // MARK: - Automated Sync System
    
    private func setupAutomation() {
        // Auto-sync every hour
        Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.syncAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Main Sync Function
    
    /// Sync all data to cloud storage
    func syncAllData() async {
        guard !isSyncing else { return }
        
        isSyncing = true
        syncStatus = .syncing
        syncProgress = 0.0
        
        do {
            // 1. Sync Documentation
            syncProgress = 0.1
            try await syncDocumentation()
            
            // 2. Sync Code Repositories
            syncProgress = 0.3
            try await syncRepositories()
            
            // 3. Sync Generated Content
            syncProgress = 0.5
            try await syncGeneratedContent()
            
            // 4. Sync AI Context
            syncProgress = 0.7
            try await syncAIContext()
            
            // 5. Sync Boilerplate Templates
            syncProgress = 0.9
            try await syncBoilerplates()
            
            // 6. Update Statistics
            try await updateCloudStatistics()
            
            lastSyncDate = Date()
            syncStatus = .complete
            syncProgress = 1.0
            
            print("✅ Cloud sync complete")
        } catch {
            syncStatus = .error(error.localizedDescription)
            print("❌ Sync failed: \(error)")
        }
        
        isSyncing = false
    }
    
    // MARK: - Documentation Sync
    
    private func syncDocumentation() async throws {
        let docs: [Any?] = [
            loadJSON(filename: "hig_combined.json", type: HIGDatabase.self) as HIGDatabase?,
            loadJSON(filename: "developer_docs_combined.json", type: DocumentationDatabase.self) as DocumentationDatabase?,
            loadJSON(filename: "github_repos_combined.json", type: GitHubDocumentationDatabase.self) as GitHubDocumentationDatabase?
        ]
        
        let higDB = docs.indices.contains(0) ? docs[0] as? HIGDatabase : nil
        let developerDB = docs.indices.contains(1) ? docs[1] as? DocumentationDatabase : nil
        let githubDB = docs.indices.contains(2) ? docs[2] as? GitHubDocumentationDatabase : nil

        let docStructure = DocumentationStructure(
            hig: higDB,
            developerDocs: developerDB,
            githubRepos: githubDB,
            lastUpdated: Date()
        )
        
        // Upload to database
        try await uploadToDatabase(
            table: "documentation",
            data: docStructure,
            key: "main"
        )
        
        if let hig = higDB {
            try await uploadToCDN(
                path: "documentation/hig_combined.json",
                data: hig
            )
        }
        if let developerDocs = developerDB {
            try await uploadToCDN(
                path: "documentation/developer_docs_combined.json",
                data: developerDocs
            )
        }
        if let githubRepos = githubDB {
            try await uploadToCDN(
                path: "documentation/github_repos_combined.json",
                data: githubRepos
            )
        }
    }
    
    // MARK: - Repository Sync
    
    private func syncRepositories() async throws {
        let github = GitHubService.shared
        
        guard github.isAuthenticated else {
            print("⚠️ GitHub not authenticated, skipping repo sync")
            return
        }
        
        // Organize repositories by category
        let repoOrganization = RepositoryOrganization(
            personal: github.repositories.filter { $0.owner.login == github.currentUser?.login },
            starred: [], // Would fetch starred repos
            contributed: [], // Would fetch contributed repos
            watching: [], // Would fetch watched repos
            lastUpdated: Date()
        )
        
        // Upload to database
        try await uploadToDatabase(
            table: "repositories",
            data: repoOrganization,
            key: github.currentUser?.login ?? "user"
        )
        
        // Upload individual repo data
        for repo in github.repositories {
            try await uploadToDatabase(
                table: "repository_details",
                data: repo,
                key: "\(repo.owner.login)/\(repo.name)"
            )
        }
    }
    
    // MARK: - Generated Content Sync
    
    private func syncGeneratedContent() async throws {
        let boilerplate = BoilerplateIdeaMachine.shared
        
        let generatedContent = GeneratedContent(
            templates: boilerplate.templates,
            tutorials: boilerplate.tutorials,
            walkthroughs: boilerplate.walkthroughs,
            howTos: boilerplate.howTos,
            mvvmExamples: boilerplate.mvvmExamples,
            patterns: boilerplate.patterns,
            ideas: boilerplate.ideas,
            generatedAt: Date()
        )
        
        // Upload to database
        try await uploadToDatabase(
            table: "generated_content",
            data: generatedContent,
            key: "latest"
        )
        
        // Upload individual items for easy access
        for template in boilerplate.templates {
            try await uploadToDatabase(
                table: "templates",
                data: template,
                key: template.id
            )
        }
        
        for tutorial in boilerplate.tutorials {
            try await uploadToDatabase(
                table: "tutorials",
                data: tutorial,
                key: tutorial.id
            )
        }
    }
    
    // MARK: - AI Context Sync
    
    private func syncAIContext() async throws {
        let aiContext = AIContextService.shared
        
        guard let contextDB = aiContext.contextDatabase else {
            print("⚠️ No AI context to sync")
            return
        }
        
        // Upload full context
        try await uploadToDatabase(
            table: "ai_context",
            data: contextDB,
            key: "main"
        )
        
        // Upload prompts separately for easy access
        let promptsURL = promptsFileURL()
        if let promptsData = try? Data(contentsOf: promptsURL),
           let prompts = try? JSONDecoder().decode(AIPromptTemplates.self, from: promptsData) {
            try await uploadToDatabase(
                table: "ai_prompts",
                data: prompts,
                key: "templates"
            )
        }
    }
    
    private func promptsFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        return appFolder.appendingPathComponent("ai_prompts.json")
    }
    
    // MARK: - Boilerplate Sync
    
    private func syncBoilerplates() async throws {
        let boilerplate = BoilerplateIdeaMachine.shared
        
        // Create searchable index
        let boilerplateIndex = BoilerplateIndex(
            templatesByArchitecture: Dictionary(grouping: boilerplate.templates, by: { $0.architecture }),
            tutorialsByDifficulty: Dictionary(grouping: boilerplate.tutorials, by: { $0.difficulty }),
            howTosByTopic: [:], // Would group by topic
            examplesByComplexity: Dictionary(grouping: boilerplate.mvvmExamples, by: { $0.complexity }),
            lastUpdated: Date()
        )
        
        try await uploadToDatabase(
            table: "boilerplate_index",
            data: boilerplateIndex,
            key: "main"
        )
    }
    
    // MARK: - Database Operations
    
    private func uploadToDatabase<T: Encodable>(table: String, data: T, key: String) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(data)
        
        // Convert to SQL INSERT
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        let escaped = jsonString.replacingOccurrences(of: "'", with: "''")
        let query = """
        INSERT INTO \(table) (id, data, updated_at)
        VALUES ('\(key)', '\(escaped)', NOW())
        ON CONFLICT (id) DO UPDATE SET
            data = EXCLUDED.data,
            updated_at = NOW();
        """
        
        // Execute via DatabaseService
        if let connection = database.connections.values.first {
            _ = try await database.executeQuery(query, connectionId: connection.id)
            print("✅ Uploaded \(table)/\(key) to database")
        }
    }
    
    // MARK: - CDN Operations
    
    private func uploadToCDN<T: Encodable>(path: String, data: T) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(data)
        
        // Upload via FileStorageService
        let uploadRequest = UploadRequest(
            filename: (path as NSString).lastPathComponent,
            size: Int64(jsonData.count),
            ownerId: UUID(), // System user
            folderId: nil,
            isPublic: true
        )
        
        let file = try await fileStorage.uploadFile(uploadRequest)
        
        // Enable CDN
        if !file.cdnUrl.isEmpty {
            print("✅ Uploaded \(path) to CDN: \(file.cdnUrl)")
        }
    }
    
    // MARK: - Statistics
    
    private func updateCloudStatistics() async throws {
        cloudStatistics = CloudStatistics(
            totalDocuments: await countDocuments(),
            totalRepositories: await countRepositories(),
            totalTemplates: await countTemplates(),
            totalTutorials: await countTutorials(),
            totalSize: await calculateTotalSize(),
            lastUpdated: Date()
        )
        
        // Upload statistics
        try await uploadToDatabase(
            table: "statistics",
            data: cloudStatistics,
            key: "main"
        )
    }
    
    private func countDocuments() async -> Int {
        // Query database for count
        return 0 // Placeholder
    }
    
    private func countRepositories() async -> Int {
        return GitHubService.shared.repositories.count
    }
    
    private func countTemplates() async -> Int {
        return BoilerplateIdeaMachine.shared.templates.count
    }
    
    private func countTutorials() async -> Int {
        return BoilerplateIdeaMachine.shared.tutorials.count
    }
    
    private func calculateTotalSize() async -> Int64 {
        return fileStorage.getStorageStats(ownerId: UUID()).totalSize
    }
    
    // MARK: - Utilities
    
    private func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T? {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = appSupport.appendingPathComponent("HIG/\(filename)")
        
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        
        return decoded
    }
}

// MARK: - Models

enum SyncStatus {
    case idle
    case syncing
    case complete
    case error(String)
}

struct CloudConfig {
    let databaseName: String
    let storageBucket: String
    let cdnEndpoint: String
}

struct CloudStatistics: Codable {
    var totalDocuments: Int = 0
    var totalRepositories: Int = 0
    var totalTemplates: Int = 0
    var totalTutorials: Int = 0
    var totalSize: Int64 = 0
    var lastUpdated: Date = Date()
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

struct DocumentationStructure: Codable {
    let hig: HIGDatabase?
    let developerDocs: DocumentationDatabase?
    let githubRepos: GitHubDocumentationDatabase?
    let lastUpdated: Date
}

struct RepositoryOrganization: Codable {
    let personal: [GitHubRepo]
    let starred: [GitHubRepo]
    let contributed: [GitHubRepo]
    let watching: [GitHubRepo]
    let lastUpdated: Date
}

struct GeneratedContent: Codable {
    let templates: [ProjectTemplate]
    let tutorials: [Tutorial]
    let walkthroughs: [Walkthrough]
    let howTos: [HowTo]
    let mvvmExamples: [MVVMExample]
    let patterns: [ArchitecturePattern]
    let ideas: [ProjectIdea]
    let generatedAt: Date
}

struct BoilerplateIndex: Codable {
    let templatesByArchitecture: [String: [ProjectTemplate]]
    let tutorialsByDifficulty: [String: [Tutorial]]
    let howTosByTopic: [String: [HowTo]]
    let examplesByComplexity: [String: [MVVMExample]]
    let lastUpdated: Date
}

// MARK: - Database Schema

extension CloudDataManager {
    
    /// Generate SQL schema for cloud database
    func generateDatabaseSchema() -> String {
        """
        -- HIG Knowledge Base Schema
        
        -- Documentation table
        CREATE TABLE IF NOT EXISTS documentation (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE INDEX idx_documentation_updated ON documentation(updated_at);
        
        -- Repositories table
        CREATE TABLE IF NOT EXISTS repositories (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE INDEX idx_repositories_updated ON repositories(updated_at);
        
        -- Repository details table
        CREATE TABLE IF NOT EXISTS repository_details (
            id VARCHAR(255) PRIMARY KEY,
            owner VARCHAR(255) NOT NULL,
            name VARCHAR(255) NOT NULL,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE INDEX idx_repo_details_owner ON repository_details(owner);
        CREATE INDEX idx_repo_details_name ON repository_details(name);
        
        -- Generated content table
        CREATE TABLE IF NOT EXISTS generated_content (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- Templates table
        CREATE TABLE IF NOT EXISTS templates (
            id VARCHAR(255) PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            architecture VARCHAR(100),
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE INDEX idx_templates_architecture ON templates(architecture);
        
        -- Tutorials table
        CREATE TABLE IF NOT EXISTS tutorials (
            id VARCHAR(255) PRIMARY KEY,
            title VARCHAR(500) NOT NULL,
            difficulty VARCHAR(50),
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE INDEX idx_tutorials_difficulty ON tutorials(difficulty);
        
        -- AI Context table
        CREATE TABLE IF NOT EXISTS ai_context (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- AI Prompts table
        CREATE TABLE IF NOT EXISTS ai_prompts (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- Boilerplate Index table
        CREATE TABLE IF NOT EXISTS boilerplate_index (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- Statistics table
        CREATE TABLE IF NOT EXISTS statistics (
            id VARCHAR(255) PRIMARY KEY,
            data JSONB NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW(),
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- Full-text search indexes
        CREATE INDEX idx_templates_search ON templates USING GIN(to_tsvector('english', data::text));
        CREATE INDEX idx_tutorials_search ON tutorials USING GIN(to_tsvector('english', data::text));
        CREATE INDEX idx_documentation_search ON documentation USING GIN(to_tsvector('english', data::text));
        """
    }
    
    /// Initialize cloud database with schema
    func initializeCloudDatabase() async throws {
        let schema = generateDatabaseSchema()
        
        if let connection = database.connections.values.first {
            _ = try await database.executeQuery(schema, connectionId: connection.id)
            print("✅ Cloud database schema initialized")
        }
    }
}

