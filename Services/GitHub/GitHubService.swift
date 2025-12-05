//
//  GitHubService.swift
//  HIG
//
//  GitHub API integration for accessing user repositories
//  Indexes repos, files, and generates structured documentation
//

import Foundation
import Combine

@MainActor
class GitHubService: ObservableObject {
    
    static let shared = GitHubService()
    
    // MARK: - Published State
    
    @Published var isAuthenticated = false
    @Published var currentUser: GitHubUser?
    @Published var repositories: [GitHubRepo] = []
    @Published var isLoading = false
    @Published var progress: Double = 0.0
    @Published var currentTask = ""
    
    // MARK: - Configuration
    
    @Published var accessToken: String = "" {
        didSet {
            saveAccessToken()
            if !accessToken.isEmpty {
                Task { await authenticate() }
            }
        }
    }
    
    private let session: URLSession
    private let baseURL = "https://api.github.com"
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        
        loadAccessToken()
    }
    
    // MARK: - Authentication
    
    func authenticate() async {
        guard !accessToken.isEmpty else {
            isAuthenticated = false
            return
        }
        
        isLoading = true
        currentTask = "Authenticating with GitHub..."
        
        do {
            let user = try await fetchCurrentUser()
            currentUser = user
            isAuthenticated = true
            print("✅ Authenticated as \(user.login)")
            
            // Fetch repositories
            await fetchRepositories()
        } catch {
            print("❌ Authentication failed: \(error)")
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    private func fetchCurrentUser() async throws -> GitHubUser {
        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.authenticationFailed
        }
        
        return try JSONDecoder().decode(GitHubUser.self, from: data)
    }
    
    // MARK: - Repositories
    
    func fetchRepositories() async {
        guard isAuthenticated else { return }
        
        isLoading = true
        currentTask = "Fetching repositories..."
        
        do {
            let repos = try await fetchUserRepositories()
            repositories = repos
            print("✅ Fetched \(repos.count) repositories")
        } catch {
            print("❌ Failed to fetch repositories: \(error)")
        }
        
        isLoading = false
    }
    
    private func fetchUserRepositories() async throws -> [GitHubRepo] {
        var allRepos: [GitHubRepo] = []
        var page = 1
        let perPage = 100
        
        while true {
            let url = URL(string: "\(baseURL)/user/repos?page=\(page)&per_page=\(perPage)&sort=updated")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            
            let (data, _) = try await session.data(for: request)
            let repos = try JSONDecoder().decode([GitHubRepo].self, from: data)
            
            if repos.isEmpty {
                break
            }
            
            allRepos.append(contentsOf: repos)
            page += 1
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        return allRepos
    }
    
    // MARK: - Repository Content
    
    func fetchRepositoryContent(owner: String, repo: String, path: String = "") async throws -> [GitHubContent] {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/contents/\(encodedPath)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([GitHubContent].self, from: data)
    }
    
    func fetchFileContent(owner: String, repo: String, path: String) async throws -> String {
        let contents = try await fetchRepositoryContent(owner: owner, repo: repo, path: path)
        
        guard let file = contents.first,
              file.type == "file",
              let contentBase64 = file.content else {
            throw GitHubError.fileNotFound
        }
        
        // Decode base64 content
        let cleanedBase64 = contentBase64.replacingOccurrences(of: "\\n", with: "")
        guard let data = Data(base64Encoded: cleanedBase64),
              let text = String(data: data, encoding: .utf8) else {
            throw GitHubError.decodingFailed
        }
        
        return text
    }
    
    // MARK: - Generate Documentation JSON
    
    func generateRepositoryDocumentation(for repo: GitHubRepo) async throws -> RepositoryDocumentation {
        currentTask = "Generating documentation for \(repo.name)..."
        
        // Fetch README
        var readme: String?
        do {
            readme = try await fetchFileContent(owner: repo.owner.login, repo: repo.name, path: "README.md")
        } catch {
            print("⚠️ No README found for \(repo.name)")
        }
        
        // Fetch repository structure
        let structure = try await buildRepositoryStructure(owner: repo.owner.login, repo: repo.name)
        
        // Extract code files
        let codeFiles = try await extractCodeFiles(owner: repo.owner.login, repo: repo.name, structure: structure)
        
        return RepositoryDocumentation(
            id: "\(repo.owner.login)-\(repo.name)",
            name: repo.name,
            fullName: repo.fullName,
            description: repo.description ?? "No description",
            url: repo.htmlUrl,
            owner: repo.owner.login,
            language: repo.language,
            stars: repo.stargazersCount,
            forks: repo.forksCount,
            readme: readme,
            structure: structure,
            codeFiles: codeFiles,
            topics: repo.topics ?? [],
            createdAt: repo.createdAt,
            updatedAt: repo.updatedAt
        )
    }
    
    private func buildRepositoryStructure(owner: String, repo: String, path: String = "", depth: Int = 0) async throws -> [FileNode] {
        guard depth < 5 else { return [] } // Limit depth
        
        let contents = try await fetchRepositoryContent(owner: owner, repo: repo, path: path)
        var nodes: [FileNode] = []
        
        for item in contents {
            let node = FileNode(
                name: item.name,
                path: item.path,
                type: item.type,
                size: item.size,
                children: nil
            )
            
            // Recursively fetch directory contents
            if item.type == "dir" && depth < 3 {
                let children = try? await buildRepositoryStructure(owner: owner, repo: repo, path: item.path, depth: depth + 1)
                var nodeWithChildren = node
                nodeWithChildren.children = children
                nodes.append(nodeWithChildren)
            } else {
                nodes.append(node)
            }
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
        
        return nodes
    }
    
    private func extractCodeFiles(owner: String, repo: String, structure: [FileNode]) async throws -> [CodeFile] {
        var codeFiles: [CodeFile] = []
        
        for node in structure {
            if node.type == "file" && isCodeFile(node.name) {
                do {
                    let content = try await fetchFileContent(owner: owner, repo: repo, path: node.path)
                    let codeFile = CodeFile(
                        path: node.path,
                        name: node.name,
                        language: detectLanguage(from: node.name),
                        content: content,
                        size: node.size ?? 0
                    )
                    codeFiles.append(codeFile)
                } catch {
                    print("⚠️ Failed to fetch \(node.path): \(error)")
                }
                
                // Limit to prevent rate limiting
                if codeFiles.count >= 50 {
                    break
                }
            }
            
            // Recursively process children
            if let children = node.children {
                let childFiles = try await extractCodeFiles(owner: owner, repo: repo, structure: children)
                codeFiles.append(contentsOf: childFiles)
            }
        }
        
        return codeFiles
    }
    
    // MARK: - Generate Combined JSON
    
    func generateCombinedDocumentation() async {
        guard isAuthenticated else { return }
        
        isLoading = true
        currentTask = "Generating combined documentation..."
        progress = 0.0
        
        var allDocs: [RepositoryDocumentation] = []
        
        for (index, repo) in repositories.enumerated() {
            do {
                let doc = try await generateRepositoryDocumentation(for: repo)
                allDocs.append(doc)
                progress = Double(index + 1) / Double(repositories.count)
            } catch {
                print("❌ Failed to generate docs for \(repo.name): \(error)")
            }
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        // Create combined database
        let database = GitHubDocumentationDatabase(
            version: "1.0.0",
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            user: currentUser?.login ?? "unknown",
            repositoryCount: allDocs.count,
            repositories: allDocs
        )
        
        // Save to JSON
        await saveDatabase(database)
        
        isLoading = false
        currentTask = "Complete!"
        progress = 1.0
        
        print("✅ Generated GitHub documentation for \(allDocs.count) repositories")
    }
    
    private func saveDatabase(_ database: GitHubDocumentationDatabase) async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(database)
            
            // Save to app support
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
            try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
            let fileURL = appFolder.appendingPathComponent("github_repos_combined.json")
            
            try data.write(to: fileURL)
            print("✅ Saved GitHub documentation to: \(fileURL.path)")
            
            // Also save to project
            if let projectURL = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent() {
                let projectFile = projectURL.appendingPathComponent("HIG").appendingPathComponent("github_repos_combined.json")
                try? data.write(to: projectFile)
                print("✅ Also saved to project: \(projectFile.path)")
            }
        } catch {
            print("❌ Failed to save database: \(error)")
        }
    }
    
    // MARK: - Utilities
    
    private func isCodeFile(_ filename: String) -> Bool {
        let codeExtensions = ["swift", "m", "mm", "h", "c", "cpp", "hpp", "py", "js", "ts", "java", "kt", "go", "rs"]
        let ext = (filename as NSString).pathExtension.lowercased()
        return codeExtensions.contains(ext)
    }
    
    private func detectLanguage(from filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        let languageMap: [String: String] = [
            "swift": "Swift",
            "m": "Objective-C",
            "mm": "Objective-C++",
            "h": "C/C++ Header",
            "c": "C",
            "cpp": "C++",
            "py": "Python",
            "js": "JavaScript",
            "ts": "TypeScript",
            "java": "Java",
            "kt": "Kotlin",
            "go": "Go",
            "rs": "Rust"
        ]
        return languageMap[ext] ?? "Unknown"
    }
    
    // MARK: - Token Persistence
    
    private func saveAccessToken() {
        UserDefaults.standard.set(accessToken, forKey: "githubAccessToken")
    }
    
    private func loadAccessToken() {
        if let token = UserDefaults.standard.string(forKey: "githubAccessToken") {
            accessToken = token
        }
    }
}

// MARK: - Models

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatarUrl: String
    let name: String?
    let email: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    
    enum CodingKeys: String, CodingKey {
        case login, id, name, email, bio, followers, following
        case avatarUrl = "avatar_url"
        case publicRepos = "public_repos"
    }
}

struct GitHubRepo: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlUrl: String
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let topics: [String]?
    let createdAt: String
    let updatedAt: String
    let owner: GitHubOwner
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language, topics, owner
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GitHubRepo, rhs: GitHubRepo) -> Bool {
        lhs.id == rhs.id
    }
}

struct GitHubOwner: Codable {
    let login: String
    let id: Int
}

struct GitHubContent: Codable {
    let name: String
    let path: String
    let type: String
    let size: Int?
    let content: String?
}

struct RepositoryDocumentation: Codable {
    let id: String
    let name: String
    let fullName: String
    let description: String
    let url: String
    let owner: String
    let language: String?
    let stars: Int
    let forks: Int
    let readme: String?
    let structure: [FileNode]
    let codeFiles: [CodeFile]
    let topics: [String]
    let createdAt: String
    let updatedAt: String
}

struct FileNode: Codable {
    let name: String
    let path: String
    let type: String
    let size: Int?
    var children: [FileNode]?
}

struct CodeFile: Codable {
    let path: String
    let name: String
    let language: String
    let content: String
    let size: Int
}

struct GitHubDocumentationDatabase: Codable {
    let version: String
    let generatedAt: String
    let user: String
    let repositoryCount: Int
    let repositories: [RepositoryDocumentation]
}

enum GitHubError: LocalizedError {
    case authenticationFailed
    case fileNotFound
    case decodingFailed
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed: return "GitHub authentication failed"
        case .fileNotFound: return "File not found"
        case .decodingFailed: return "Failed to decode content"
        case .rateLimitExceeded: return "GitHub API rate limit exceeded"
        }
    }
}
