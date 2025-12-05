//
//  DocumentationHubView.swift
//  HIG
//
//  Unified hub for all documentation sources
//  Apple Docs, Swift.org, GitHub, and local files
//

import SwiftUI

struct DocumentationHubView: View {
    @StateObject private var crawler = DocumentationCrawler.shared
    @StateObject private var github = GitHubService.shared
    @StateObject private var fileIndexing = FileIndexingService.shared
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            mainContent
        } detail: {
            detailView
        }
        .navigationTitle("Documentation Hub")
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        List(selection: $selectedTab) {
            Section("Documentation Sources") {
                NavigationLink(value: 0) {
                    Label("Apple Developer", systemImage: "apple.logo")
                }
                
                NavigationLink(value: 1) {
                    Label("Swift.org", systemImage: "swift")
                }
                
                NavigationLink(value: 2) {
                    Label("GitHub Repositories", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                
                NavigationLink(value: 3) {
                    Label("Local Files", systemImage: "folder")
                }
            }
            
            Section("Actions") {
                Button(action: { Task { await crawlAll() } }) {
                    Label("Crawl All Sources", systemImage: "arrow.clockwise")
                }
                .disabled(crawler.isProcessing || github.isLoading || fileIndexing.isIndexing)
                
                Button(action: { Task { await generateCombinedJSON() } }) {
                    Label("Generate Combined JSON", systemImage: "doc.text")
                }
                .disabled(crawler.isProcessing || github.isLoading)
            }
            
            Section("Statistics") {
                DocHubStatRow(label: "Web Pages", value: String(format: "%.0f%%", crawler.progress * 100))
                DocHubStatRow(label: "GitHub Repos", value: "\(github.repositories.count)")
                DocHubStatRow(label: "Local Files", value: "\(fileIndexing.statistics.totalFiles)")
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Progress indicators
            if crawler.isProcessing || github.isLoading || fileIndexing.isIndexing {
                progressView
            }
            
            // Tab content
            TabView(selection: $selectedTab) {
                AppleDocsView()
                    .tag(0)
                
                SwiftDocsView()
                    .tag(1)
                
                GitHubReposView()
                    .tag(2)
                
                LocalFilesView()
                    .tag(3)
            }
        }
    }
    
    private var progressView: some View {
        VStack(spacing: DSSpacing.md) {
            if crawler.isProcessing {
                ProgressView(value: crawler.progress)
                Text(crawler.currentTask)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if github.isLoading {
                ProgressView(value: github.progress)
                Text(github.currentTask)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if fileIndexing.isIndexing {
                ProgressView(value: fileIndexing.progress)
                Text(fileIndexing.currentOperation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DSSpacing.md)
        .background(Color.accentColor.opacity(0.1))
    }
    
    // MARK: - Detail View
    
    private var detailView: some View {
        ContentUnavailableView(
            "Documentation Hub",
            systemImage: "book.fill",
            description: Text("Select a source to view documentation")
        )
    }
    
    // MARK: - Actions
    
    private func crawlAll() async {
        // Crawl web documentation
        await crawler.crawlAndGenerateJSON()
        
        // Fetch GitHub repos
        if github.isAuthenticated {
            await github.generateCombinedDocumentation()
        }
        
        // Index local files
        await fileIndexing.startAutomaticIndexing()
    }
    
    private func generateCombinedJSON() async {
        // This would combine all sources into one master JSON
        print("📦 Generating master documentation database...")
        
        // For now, each service generates its own JSON
        await crawler.crawlAndGenerateJSON()
        
        if github.isAuthenticated {
            await github.generateCombinedDocumentation()
        }
    }
}

// MARK: - Tab Views

struct AppleDocsView: View {
    @StateObject private var crawler = DocumentationCrawler.shared
    
    var body: some View {
        VStack {
            Text("Apple Developer Documentation")
                .font(.title)
            
            Button("Start Crawling") {
                Task {
                    await crawler.crawlAndGenerateJSON()
                }
            }
            .disabled(crawler.isProcessing)
            
            if crawler.isProcessing {
                ProgressView(value: crawler.progress)
                    .padding()
                Text(crawler.currentTask)
                    .font(.caption)
            }
        }
        .padding()
    }
}

struct SwiftDocsView: View {
    var body: some View {
        VStack {
            Text("Swift.org Documentation")
                .font(.title)
            
            Text("Included in Apple Docs crawl")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct GitHubReposView: View {
    @StateObject private var github = GitHubService.shared
    @State private var showTokenInput = false
    
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            if !github.isAuthenticated {
                // Authentication view
                VStack(spacing: DSSpacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    Text("Connect to GitHub")
                        .font(.title)
                    
                    Text("Enter your GitHub Personal Access Token to index your repositories")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Enter Token") {
                        showTokenInput = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Authenticated view
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if let user = github.currentUser {
                        HStack {
                            Text("Logged in as \(user.login)")
                                .font(.headline)
                            Spacer()
                            Button("Generate JSON") {
                                Task {
                                    await github.generateCombinedDocumentation()
                                }
                            }
                            .disabled(github.isLoading)
                        }
                    }
                    
                    List(github.repositories) { repo in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(repo.name)
                                .font(.headline)
                            if let desc = repo.description {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Label("\(repo.stargazersCount)", systemImage: "star")
                                Label("\(repo.forksCount)", systemImage: "tuningfork")
                                if let lang = repo.language {
                                    Text(lang)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showTokenInput) {
            GitHubTokenInputView()
        }
    }
}

struct GitHubTokenInputView: View {
    @StateObject private var github = GitHubService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var token = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Personal Access Token", text: $token)
                    
                    Text("Create a token at github.com/settings/tokens with 'repo' scope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("GitHub Authentication")
                }
            }
            .navigationTitle("Connect GitHub")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") {
                        github.accessToken = token
                        dismiss()
                    }
                    .disabled(token.isEmpty)
                }
            }
        }
    }
}

struct LocalFilesView: View {
    @StateObject private var fileIndexing = FileIndexingService.shared
    
    var body: some View {
        VStack {
            Text("Local File Index")
                .font(.title)
            
            Text("\(fileIndexing.statistics.totalFiles) files indexed")
                .foregroundStyle(.secondary)
            
            Button("Start Indexing") {
                Task {
                    await fileIndexing.startAutomaticIndexing()
                }
            }
            .disabled(fileIndexing.isIndexing)
        }
        .padding()
    }
}

struct DocHubStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    DocumentationHubView()
        .frame(width: 1400, height: 900)
}
