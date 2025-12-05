//
//  AutomationOrchestrator.swift
//  HIG
//
//  Central automation system that coordinates all automated tasks
//  Documentation generation, code analysis, cloud sync, and more
//

import Foundation
import Combine

@MainActor
class AutomationOrchestrator: ObservableObject {
    
    static let shared = AutomationOrchestrator()
    
    // MARK: - Published State
    
    @Published var isRunning = false
    @Published var currentTask = ""
    @Published var progress: Double = 0.0
    @Published var automationLog: [AutomationLogEntry] = []
    @Published var schedule: AutomationSchedule = AutomationSchedule.load()
    
    // MARK: - Services
    
    private let docCrawler = DocumentationCrawler.shared
    private let github = GitHubService.shared
    private let fileIndexing = FileIndexingService.shared
    private let aiContext = AIContextService.shared
    private let boilerplate = BoilerplateIdeaMachine.shared
    private let cloudSync = CloudDataManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAutomation()
    }
    
    // MARK: - Automation Setup
    
    private func setupAutomation() {
        // Daily full automation
        if schedule.enableDailyAutomation {
            Timer.publish(every: 86400, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task {
                        await self?.runFullAutomation()
                    }
                }
                .store(in: &cancellables)
        }
        
        // Hourly cloud sync
        if schedule.enableHourlySync {
            Timer.publish(every: 3600, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task {
                        await self?.cloudSync.syncAllData()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Full Automation Pipeline
    
    /// Run complete automation pipeline
    func runFullAutomation() async {
        guard !isRunning else { return }
        
        isRunning = true
        progress = 0.0
        logEntry("🚀 Starting full automation pipeline")
        
        // 1. Crawl Documentation
        currentTask = "Crawling documentation..."
        await crawlDocumentation()
        progress = 0.15
        
        // 2. Index GitHub Repositories
        currentTask = "Indexing GitHub repositories..."
        await indexGitHubRepos()
        progress = 0.30
        
        // 3. Index Local Files
        currentTask = "Indexing local files..."
        await indexLocalFiles()
        progress = 0.45
        
        // 4. Build AI Context
        currentTask = "Building AI context..."
        await buildAIContext()
        progress = 0.60
        
        // 5. Generate Boilerplates & Tutorials
        currentTask = "Generating templates and tutorials..."
        await generateBoilerplates()
        progress = 0.75
        
        // 6. Generate Documentation
        currentTask = "Generating documentation..."
        await generateDocumentation()
        progress = 0.85
        
        // 7. Sync to Cloud
        currentTask = "Syncing to cloud..."
        await syncToCloud()
        progress = 0.95
        
        // 8. Generate Scripts
        currentTask = "Generating automation scripts..."
        await generateScripts()
        progress = 1.0
        
        currentTask = "Complete!"
        logEntry("✅ Full automation pipeline complete")
        isRunning = false
    }
    
    // MARK: - Individual Automation Tasks
    
    private func crawlDocumentation() async {
        logEntry("📚 Crawling Apple Developer and Swift.org documentation")
        await docCrawler.crawlAndGenerateJSON()
        logEntry("✅ Documentation crawl complete")
    }
    
    private func indexGitHubRepos() async {
        guard github.isAuthenticated else {
            logEntry("⚠️ GitHub not authenticated, skipping")
            return
        }
        
        logEntry("🐙 Indexing GitHub repositories")
        await github.generateCombinedDocumentation()
        logEntry("✅ GitHub indexing complete")
    }
    
    private func indexLocalFiles() async {
        logEntry("📁 Indexing local file system")
        await fileIndexing.startAutomaticIndexing()
        logEntry("✅ File indexing complete")
    }
    
    private func buildAIContext() async {
        logEntry("🤖 Building AI context from all sources")
        await aiContext.buildAIContext()
        logEntry("✅ AI context built")
    }
    
    private func generateBoilerplates() async {
        logEntry("🎨 Generating project templates and tutorials")
        await boilerplate.indexAndGenerateTemplates()
        logEntry("✅ Generated \(boilerplate.templates.count) templates, \(boilerplate.tutorials.count) tutorials")
    }
    
    private func generateDocumentation() async {
        logEntry("📝 Generating comprehensive documentation")
        
        // Generate README files
        await generateReadmeFiles()
        
        // Generate API documentation
        await generateAPIDocumentation()
        
        // Generate architecture diagrams
        await generateArchitectureDiagrams()
        
        logEntry("✅ Documentation generation complete")
    }
    
    private func syncToCloud() async {
        logEntry("☁️ Syncing all data to cloud")
        await cloudSync.syncAllData()
        logEntry("✅ Cloud sync complete")
    }
    
    private func generateScripts() async {
        logEntry("📜 Generating automation scripts")
        
        // Generate shell scripts
        generateShellScripts()
        
        // Generate Python scripts
        generatePythonScripts()
        
        // Generate Swift scripts
        generateSwiftScripts()
        
        logEntry("✅ Scripts generated")
    }
    
    // MARK: - Documentation Generation
    
    private func generateReadmeFiles() async {
        let readmeGenerator = ReadmeGenerator()
        
        // Main README
        let mainReadme = readmeGenerator.generateMainReadme(
            projectName: "HIG",
            description: "Human Interface Guidelines Knowledge System",
            features: [
                "Documentation crawling and indexing",
                "GitHub repository analysis",
                "AI-powered code generation",
                "Automated boilerplate generation",
                "Cloud-based data management"
            ]
        )
        
        saveFile(content: mainReadme, path: "README.md")
        
        // Service READMEs
        for service in ["Authentication", "Authorization", "Billing", "Database", "FileStorage", "API"] {
            let serviceReadme = readmeGenerator.generateServiceReadme(serviceName: service)
            saveFile(content: serviceReadme, path: "HIG/Services/\(service)/README.md")
        }
    }
    
    private func generateAPIDocumentation() async {
        let apiDocGenerator = APIDocumentationGenerator()
        
        let apiDocs = apiDocGenerator.generateOpenAPISpec(
            title: "HIG API",
            version: "1.0.0",
            services: [
                "Authentication",
                "Authorization",
                "Billing",
                "Database",
                "FileStorage",
                "API Gateway"
            ]
        )
        
        saveFile(content: apiDocs, path: "docs/api/openapi.yaml")
    }
    
    private func generateArchitectureDiagrams() async {
        let diagramGenerator = DiagramGenerator()
        
        // System architecture
        let systemDiagram = diagramGenerator.generateMermaidDiagram(
            type: .systemArchitecture,
            components: [
                "Frontend",
                "API Gateway",
                "Authentication",
                "Authorization",
                "Database",
                "File Storage",
                "CDN"
            ]
        )
        
        saveFile(content: systemDiagram, path: "docs/architecture/system.mmd")
    }
    
    // MARK: - Script Generation
    
    private func generateShellScripts() {
        // Deployment script
        let deployScript = """
        #!/bin/bash
        # Auto-generated deployment script
        
        echo "🚀 Deploying HIG..."
        
        # Build
        swift build -c release
        
        # Run tests
        swift test
        
        # Deploy to cloud
        ./scripts/deploy_to_cloud.sh
        
        echo "✅ Deployment complete"
        """
        
        saveFile(content: deployScript, path: "scripts/deploy.sh", executable: true)
        
        // Backup script
        let backupScript = """
        #!/bin/bash
        # Auto-generated backup script
        
        echo "💾 Creating backup..."
        
        # Backup database
        pg_dump hig_knowledge_base > backup_$(date +%Y%m%d).sql
        
        # Backup files
        tar -czf files_backup_$(date +%Y%m%d).tar.gz ~/Library/Application\\ Support/HIG/
        
        echo "✅ Backup complete"
        """
        
        saveFile(content: backupScript, path: "scripts/backup.sh", executable: true)
    }
    
    private func generatePythonScripts() {
        // Data analysis script
        let analysisScript = """
        #!/usr/bin/env python3
        # Auto-generated data analysis script
        
        import json
        import pandas as pd
        from pathlib import Path
        
        def analyze_documentation():
            \"\"\"Analyze documentation statistics\"\"\"
            
            # Load data
            with open('developer_docs_combined.json') as f:
                docs = json.load(f)
            
            # Analyze
            total_topics = docs['topicCount']
            categories = {}
            
            for topic in docs['topics']:
                cat = topic['category']
                categories[cat] = categories.get(cat, 0) + 1
            
            print(f"Total topics: {total_topics}")
            print(f"Categories: {len(categories)}")
            
            # Create DataFrame
            df = pd.DataFrame(list(categories.items()), columns=['Category', 'Count'])
            df.to_csv('documentation_stats.csv', index=False)
            
            print("✅ Analysis complete")
        
        if __name__ == '__main__':
            analyze_documentation()
        """
        
        saveFile(content: analysisScript, path: "scripts/analyze_data.py", executable: true)
    }
    
    private func generateSwiftScripts() {
        // Code generation script
        let codeGenScript = """
        #!/usr/bin/swift
        // Auto-generated code generation script
        
        import Foundation
        
        struct CodeGenerator {
            func generateModel(name: String, properties: [String: String]) {
                var code = \"\"\"
                struct \\(name): Codable, Identifiable {
                    let id: UUID
                \"\"\"
                
                for (propName, propType) in properties {
                    code += "\\n    let \\(propName): \\(propType)"
                }
                
                code += "\\n}"
                
                print(code)
            }
        }
        
        let generator = CodeGenerator()
        generator.generateModel(
            name: "User",
            properties: [
                "name": "String",
                "email": "String",
                "age": "Int"
            ]
        )
        """
        
        saveFile(content: codeGenScript, path: "scripts/generate_code.swift", executable: true)
    }
    
    // MARK: - Utilities
    
    private func saveFile(content: String, path: String, executable: Bool = false) {
        let fileURL = URL(fileURLWithPath: path)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            if executable {
                try FileManager.default.setAttributes(
                    [.posixPermissions: 0o755],
                    ofItemAtPath: fileURL.path
                )
            }
            
            logEntry("✅ Generated: \(path)")
        } catch {
            logEntry("❌ Failed to save \(path): \(error)")
        }
    }
    
    private func logEntry(_ message: String) {
        let entry = AutomationLogEntry(
            timestamp: Date(),
            message: message
        )
        automationLog.append(entry)
        print(message)
    }
}

// MARK: - Models

struct AutomationLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
}

struct AutomationSchedule: Codable {
    var enableDailyAutomation: Bool = true
    var enableHourlySync: Bool = true
    var dailyRunTime: String = "02:00" // 2 AM
    var enableWeeklyReports: Bool = true
    
    static func load() -> AutomationSchedule {
        guard let data = UserDefaults.standard.data(forKey: "automationSchedule"),
              let schedule = try? JSONDecoder().decode(AutomationSchedule.self, from: data) else {
            return AutomationSchedule()
        }
        return schedule
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "automationSchedule")
        }
    }
}

// MARK: - Helper Classes

class ReadmeGenerator {
    func generateMainReadme(projectName: String, description: String, features: [String]) -> String {
        """
        # \(projectName)
        
        \(description)
        
        ## Features
        
        \(features.map { "- \($0)" }.joined(separator: "\n"))
        
        ## Installation
        
        ```bash
        git clone https://github.com/user/\(projectName).git
        cd \(projectName)
        swift build
        ```
        
        ## Usage
        
        ```swift
        import \(projectName)
        
        // Your code here
        ```
        
        ## Documentation
        
        See [docs/](docs/) for comprehensive documentation.
        
        ## License
        
        MIT License
        """
    }
    
    func generateServiceReadme(serviceName: String) -> String {
        """
        # \(serviceName) Service
        
        ## Overview
        
        The \(serviceName) service provides...
        
        ## API
        
        ### Methods
        
        - `method1()` - Description
        - `method2()` - Description
        
        ## Examples
        
        ```swift
        let service = \(serviceName)Service.shared
        await service.method1()
        ```
        """
    }
}

class APIDocumentationGenerator {
    func generateOpenAPISpec(title: String, version: String, services: [String]) -> String {
        """
        openapi: 3.0.0
        info:
          title: \(title)
          version: \(version)
          description: Auto-generated API documentation
        
        servers:
          - url: https://api.hig.app/v1
            description: Production server
        
        paths:
          /health:
            get:
              summary: Health check
              responses:
                '200':
                  description: Service is healthy
        """
    }
}

class DiagramGenerator {
    enum DiagramType {
        case systemArchitecture
        case dataFlow
        case sequenceDiagram
    }
    
    func generateMermaidDiagram(type: DiagramType, components: [String]) -> String {
        switch type {
        case .systemArchitecture:
            return """
            graph TD
                \(components.enumerated().map { "A\($0) [\($1)]" }.joined(separator: "\n    "))
                \(components.indices.dropLast().map { "A\($0) --> A\($0 + 1)" }.joined(separator: "\n    "))
            """
        default:
            return "graph TD\n    A[Start] --> B[End]"
        }
    }
}
