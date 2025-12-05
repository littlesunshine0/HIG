//
//  AIContextService.swift
//  HIG
//
//  AI Context Service that feeds codebase to AI for better code generation
//  Integrates with GitHub, local files, and documentation
//

import Foundation
import Combine

@MainActor
class AIContextService: ObservableObject {
    
    static let shared = AIContextService()
    
    // MARK: - Published State
    
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var currentTask = ""
    @Published var contextDatabase: AIContextDatabase?
    @Published var statistics: ContextStatistics = ContextStatistics()
    
    // MARK: - Configuration
    
    @Published var config: AIContextConfig = AIContextConfig.load()
    
    // MARK: - Services
    
    private let github = GitHubService.shared
    private let fileIndexing = FileIndexingService.shared
    private let docCrawler = DocumentationCrawler.shared
    
    private init() {
        loadPersistedContext()
    }
    
    // MARK: - Build AI Context
    
    /// Build comprehensive AI context from all sources
    func buildAIContext() async {
        isProcessing = true
        progress = 0.0
        currentTask = "Building AI context..."
        
        var contexts: [CodeContext] = []
        
        // 1. GitHub Repositories
        if config.includeGitHubRepos {
            currentTask = "Processing GitHub repositories..."
            let githubContexts = await buildGitHubContext()
            contexts.append(contentsOf: githubContexts)
            progress = 0.25
        }
        
        // 2. Local Files
        if config.includeLocalFiles {
            currentTask = "Processing local files..."
            let localContexts = await buildLocalFileContext()
            contexts.append(contentsOf: localContexts)
            progress = 0.50
        }
        
        // 3. Documentation
        if config.includeDocumentation {
            currentTask = "Processing documentation..."
            let docContexts = await buildDocumentationContext()
            contexts.append(contentsOf: docContexts)
            progress = 0.75
        }
        
        // 4. Extract patterns and best practices
        let patterns = extractCodePatterns(from: contexts)
        let bestPractices = extractBestPractices(from: contexts)
        let _ = extractFrameworks(from: contexts) // Frameworks for analysis
        
        // 5. Build context database
        let database = AIContextDatabase(
            contexts: contexts,
            patterns: patterns,
            bestPractices: bestPractices,
            statistics: ContextStatistics()
        )
        
        contextDatabase = database
        statistics = ContextStatistics()
        
        // 6. Save to disk
        currentTask = "Saving AI context..."
        await saveContext(database)
        
        // 7. Generate AI prompt templates
        currentTask = "Generating AI prompts..."
        await generateAIPrompts(from: database)
        
        progress = 1.0
        currentTask = "Complete!"
        isProcessing = false
        
        print("✅ Built AI context: \(contexts.count) files, \(patterns.count) patterns")
    }
    
    // MARK: - GitHub Context
    
    private func buildGitHubContext() async -> [CodeContext] {
        var contexts: [CodeContext] = []
        
        guard github.isAuthenticated else {
            print("⚠️ GitHub not authenticated, skipping")
            return []
        }
        
        for repo in github.repositories {
            do {
                let repoDoc = try await github.generateRepositoryDocumentation(for: repo)
                
                // Process code files
                for codeFile in repoDoc.codeFiles {
                    let context = CodeContext(
                        id: UUID().uuidString,
                        source: .github(repo: repo.name),
                        filePath: codeFile.path,
                        fileName: codeFile.name,
                        language: codeFile.language,
                        content: codeFile.content,
                        lineCount: codeFile.content.components(separatedBy: CharacterSet.newlines).count,
                        imports: extractImports(from: codeFile.content, language: codeFile.language),
                        classes: extractClasses(from: codeFile.content, language: codeFile.language),
                        functions: extractFunctions(from: codeFile.content, language: codeFile.language),
                        comments: extractComments(from: codeFile.content, language: codeFile.language),
                        metadata: [
                            "repo": repo.name,
                            "stars": "\(repo.stargazersCount)",
                            "language": repo.language ?? "Unknown"
                        ]
                    )
                    contexts.append(context)
                }
                
                // Add README as documentation context
                if let readme = repoDoc.readme {
                    let readmeContext = CodeContext(
                        id: UUID().uuidString,
                        source: .github(repo: repo.name),
                        filePath: "README.md",
                        fileName: "README.md",
                        language: "Markdown",
                        content: readme,
                        lineCount: readme.components(separatedBy: CharacterSet.newlines).count,
                        imports: [],
                        classes: [],
                        functions: [],
                        comments: [],
                        metadata: ["type": "documentation"]
                    )
                    contexts.append(readmeContext)
                }
            } catch {
                print("⚠️ Failed to process repo \(repo.name): \(error)")
            }
        }
        
        return contexts
    }
    
    // MARK: - Local File Context
    
    private func buildLocalFileContext() async -> [CodeContext] {
        var contexts: [CodeContext] = []
        
        // Get code files from file indexing service
        let codeFiles = fileIndexing.files(ofType: .code)
        
        for file in codeFiles.prefix(config.maxLocalFiles) {
            guard let content = file.content else { continue }
            
            let context = CodeContext(
                id: UUID().uuidString,
                source: .local,
                filePath: file.path,
                fileName: file.name,
                language: detectLanguage(from: file.name),
                content: content,
                lineCount: content.components(separatedBy: CharacterSet.newlines).count,
                imports: extractImports(from: content, language: detectLanguage(from: file.name)),
                classes: extractClasses(from: content, language: detectLanguage(from: file.name)),
                functions: extractFunctions(from: content, language: detectLanguage(from: file.name)),
                comments: extractComments(from: content, language: detectLanguage(from: file.name)),
                metadata: [
                    "size": "\(file.size)",
                    "modified": file.modifiedDate.ISO8601Format()
                ],
                general: []
            )
            contexts.append(context)
        }
        
        return contexts
    }
    
    // MARK: - Documentation Context
    
    private func buildDocumentationContext() async -> [CodeContext] {
        var contexts: [CodeContext] = []
        
        // Load documentation database if available
        if let docDB = loadDocumentationDatabase() {
            for topic in docDB.topics.prefix(config.maxDocTopics) {
                let content = """
                # \(topic.title)
                
                \(topic.abstract)
                
                ## Sections
                \(topic.sections.map { section in
                    "### \(section.heading)\n" + section.content.compactMap { $0.text }.joined(separator: "\n")
                }.joined(separator: "\n\n"))
                
                ## Code Examples
                \(topic.codeExamples.map { example in
                    "### \(example.title)\n```\(example.language)\n\(example.code)\n```"
                }.joined(separator: "\n\n"))
                """
                
                let context = CodeContext(
                    id: topic.id,
                    source: .documentation,
                    filePath: topic.url,
                    fileName: topic.title,
                    language: "Documentation",
                    content: content,
                    lineCount: content.components(separatedBy: CharacterSet.newlines).count,
                    imports: [],
                    classes: [],
                    functions: [],
                    comments: [],
                    metadata: [
                        "category": topic.category,
                        "platforms": topic.platforms.joined(separator: ", ")
                    ]
                )
                contexts.append(context)
            }
        }
        
        return contexts
    }
    
    // MARK: - Code Analysis
    
    private func extractImports(from code: String, language: String) -> [String] {
        var imports: [String] = []
        
        switch language.lowercased() {
        case "swift":
            let pattern = "import\\s+(\\w+)"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, range: range)
                for match in matches {
                    if let range = Range(match.range(at: 1), in: code) {
                        imports.append(String(code[range]))
                    }
                }
            }
        case "python":
            let patterns = ["import\\s+(\\w+)", "from\\s+(\\w+)\\s+import"]
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let range = NSRange(code.startIndex..., in: code)
                    let matches = regex.matches(in: code, range: range)
                    for match in matches {
                        if let range = Range(match.range(at: 1), in: code) {
                            imports.append(String(code[range]))
                        }
                    }
                }
            }
        default:
            break
        }
        
        return Array(Set(imports))
    }
    
    private func extractClasses(from code: String, language: String) -> [String] {
        var classes: [String] = []
        
        let patterns: [String: String] = [
            "swift": "class\\s+(\\w+)",
            "python": "class\\s+(\\w+)",
            "java": "class\\s+(\\w+)",
            "javascript": "class\\s+(\\w+)"
        ]
        
        guard let pattern = patterns[language.lowercased()],
              let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let range = NSRange(code.startIndex..., in: code)
        let matches = regex.matches(in: code, range: range)
        for match in matches {
            if let range = Range(match.range(at: 1), in: code) {
                classes.append(String(code[range]))
            }
        }
        
        return classes
    }
    
    private func extractFunctions(from code: String, language: String) -> [String] {
        var functions: [String] = []
        
        let patterns: [String: String] = [
            "swift": "func\\s+(\\w+)",
            "python": "def\\s+(\\w+)",
            "javascript": "function\\s+(\\w+)"
        ]
        
        guard let pattern = patterns[language.lowercased()],
              let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let range = NSRange(code.startIndex..., in: code)
        let matches = regex.matches(in: code, range: range)
        for match in matches {
            if let range = Range(match.range(at: 1), in: code) {
                functions.append(String(code[range]))
            }
        }
        
        return functions
    }
    
    private func extractComments(from code: String, language: String) -> [String] {
        var comments: [String] = []
        
        // Extract single-line comments
        let singleLinePattern = "//\\s*(.+)"
        if let regex = try? NSRegularExpression(pattern: singleLinePattern) {
            let range = NSRange(code.startIndex..., in: code)
            let matches = regex.matches(in: code, range: range)
            for match in matches {
                if let range = Range(match.range(at: 1), in: code) {
                    comments.append(String(code[range]).trimmingCharacters(in: .whitespaces))
                }
            }
        }
        
        return comments
    }
    
    private func extractCodePatterns(from contexts: [CodeContext]) -> [CodePattern] {
        var patterns: [CodePattern] = []
        
        // Analyze common patterns
        let swiftContexts = contexts.filter { $0.language == "Swift" }
        
        // Pattern: SwiftUI View structure
        if swiftContexts.contains(where: { $0.content.contains("struct") && $0.content.contains(": View") }) {
            patterns.append(CodePattern(
                name: "SwiftUI View Pattern",
                description: "Standard SwiftUI view structure with body property",
                example: """
                struct MyView: View {
                    var body: some View {
                        // View content
                    }
                }
                """,
                frequency: swiftContexts.filter { $0.content.contains(": View") }.count,
                language: "Swift"
            ))
        }
        
        // Pattern: Observable pattern
        if swiftContexts.contains(where: { $0.content.contains("@Published") }) {
            patterns.append(CodePattern(
                name: "Observable Pattern",
                description: "Using @Published for reactive state management",
                example: "@Published var property: Type",
                frequency: swiftContexts.filter { $0.content.contains("@Published") }.count,
                language: "Swift"
            ))
        }
        
        return patterns
    }
    
    private func extractBestPractices(from contexts: [CodeContext]) -> [BestPractice] {
        var practices: [BestPractice] = []
        
        // Analyze for best practices
        let swiftContexts = contexts.filter { $0.language == "Swift" }
        
        // Check for MARK comments
        let markedFiles = swiftContexts.filter { $0.content.contains("// MARK:") }
        if !markedFiles.isEmpty {
            practices.append(BestPractice(
                title: "Code Organization with MARK",
                description: "Use // MARK: comments to organize code sections",
                examples: markedFiles.prefix(3).compactMap { context in
                    context.comments.first { $0.contains("MARK") }
                },
                adherence: Double(markedFiles.count) / Double(swiftContexts.count)
            ))
        }
        
        // Check for documentation comments
        let documentedFiles = swiftContexts.filter { $0.content.contains("///") }
        if !documentedFiles.isEmpty {
            practices.append(BestPractice(
                title: "Documentation Comments",
                description: "Use /// for documentation comments",
                examples: ["/// Description of function or property"],
                adherence: Double(documentedFiles.count) / Double(swiftContexts.count)
            ))
        }
        
        return practices
    }
    
    private func extractFrameworks(from contexts: [CodeContext]) -> [String] {
        var frameworks = Set<String>()
        
        for context in contexts {
            frameworks.formUnion(context.imports)
        }
        
        return Array(frameworks).sorted()
    }
    
    // MARK: - AI Prompt Generation
    
    private func generateAIPrompts(from database: AIContextDatabase) async {
        let prompts = AIPromptTemplates(
            systemPrompt: generateSystemPrompt(from: database),
            codeGenerationPrompt: generateCodeGenerationPrompt(from: database),
            codeReviewPrompt: generateCodeReviewPrompt(from: database),
            architecturePrompt: generateArchitecturePrompt(from: database)
        )
        
        // Save prompts
        await savePrompts(prompts)
    }
    
    private func generateSystemPrompt(from database: AIContextDatabase) -> String {
        """
        You are an expert software engineer working on a \(database.statistics.languages.joined(separator: ", ")) project.
        
        ## Project Context
        - Total Files: \(database.statistics.totalFiles)
        - Total Lines: \(database.statistics.totalLines)
        - Languages: \(database.statistics.languages.joined(separator: ", "))
        - Frameworks: \(database.statistics.frameworks.joined(separator: ", "))
        
        ## Code Patterns
        \(database.patterns.map { "- \($0.name): \($0.description)" }.joined(separator: "\n"))
        
        ## Best Practices
        \(database.bestPractices.map { "- \($0.title): \($0.description) (Adherence: \(Int($0.adherence * 100))%)" }.joined(separator: "\n"))
        
        When generating code:
        1. Follow the established patterns in the codebase
        2. Adhere to the best practices listed above
        3. Use the same frameworks and libraries
        4. Match the coding style and conventions
        5. Include appropriate documentation comments
        """
    }
    
    private func generateCodeGenerationPrompt(from database: AIContextDatabase) -> String {
        """
        Generate code following these project-specific guidelines:
        
        ## Style Guide
        - Use MARK comments for organization
        - Add documentation comments (///) for public APIs
        - Follow Swift naming conventions
        - Use @Published for observable properties
        
        ## Common Patterns
        \(database.patterns.map { $0.example }.joined(separator: "\n\n"))
        
        ## Example Code Structure
        ```swift
        // MARK: - Section Name
        
        /// Documentation comment
        func exampleFunction() {
            // Implementation
        }
"""
    }}
