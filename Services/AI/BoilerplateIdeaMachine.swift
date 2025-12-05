//
//  BoilerplateIdeaMachine.swift
//  HIG
//
//  AI-powered boilerplate generator that learns from Apple, Swift, and any GitHub repos
//  Generates production-quality project templates and code scaffolding
//

import Foundation
import Combine

@MainActor
class BoilerplateIdeaMachine: ObservableObject {
    
    static let shared = BoilerplateIdeaMachine()
    
    // MARK: - Published State
    
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var currentTask = ""
    @Published var templates: [ProjectTemplate] = []
    @Published var patterns: [ArchitecturePattern] = []
    @Published var ideas: [ProjectIdea] = []
    @Published var tutorials: [Tutorial] = []
    @Published var walkthroughs: [Walkthrough] = []
    @Published var howTos: [HowTo] = []
    @Published var mvvmExamples: [MVVMExample] = []
    
    // MARK: - Configuration
    
    @Published var config: BoilerplateConfig = BoilerplateConfig.load()
    
    // MARK: - Services
    
    private let github = GitHubService.shared
    private let aiContext = AIContextService.shared
    
    // MARK: - Curated Repository Lists
    
    private let appleRepos = [
        "apple/swift",
        "apple/swift-evolution",
        "apple/swift-package-manager",
        "apple/swift-nio",
        "apple/swift-algorithms",
        "apple/swift-collections",
        "apple/swift-async-algorithms",
        "apple/swift-argument-parser",
        "apple/swift-log",
        "apple/swift-metrics",
        "apple/swift-crypto",
        "apple/swift-protobuf",
        "apple/swift-format",
        "apple/swift-syntax",
        "apple/swift-testing",
        "apple/swift-foundation",
        "apple/swift-corelibs-foundation",
        "apple/swift-corelibs-libdispatch",
        "apple/swift-corelibs-xctest"
    ]
    
    private let swiftServerRepos = [
        "vapor/vapor",
        "hummingbird-project/hummingbird",
        "swift-server/async-http-client",
        "swift-server/swift-aws-lambda-runtime"
    ]
    
    private let communityRepos = [
        "Alamofire/Alamofire",
        "realm/realm-swift",
        "onevcat/Kingfisher",
        "SnapKit/SnapKit",
        "ReactiveX/RxSwift",
        "pointfreeco/swift-composable-architecture"
    ]
    
    // MARK: - Popular Swift Developers & Their Repos
    
    private let popularDevelopers: [String: [String]] = [
        // Point-Free (Brandon Williams & Stephen Celis)
        "pointfreeco": [
            "swift-composable-architecture",
            "swift-dependencies",
            "swift-snapshot-testing",
            "swift-parsing",
            "swift-case-paths",
            "swift-identified-collections"
        ],
        
        // John Sundell
        "JohnSundell": [
            "Publish",
            "Plot",
            "Ink",
            "Splash",
            "Files",
            "ShellOut"
        ],
        
        // Paul Hudson (Hacking with Swift)
        "twostraws": [
            "HackingWithSwift",
            "Ignite",
            "Vortex",
            "SimpleSwiftUI"
        ],
        
        // Mattt (NSHipster)
        "mattt": [
            "Surge",
            "Alamofire",
            "SwiftDoc.org"
        ],
        
        // Krzysztof Zabłocki
        "krzysztofzablocki": [
            "Sourcery",
            "LifetimeTracker",
            "KZFileWatchers"
        ],
        
        // Vadim Shpakovski
        "vadymmarkov": [
            "Beethoven",
            "Pitchy",
            "Spots"
        ],
        
        // Marin Todorov
        "icanzilb": [
            "RxSwift",
            "EasyAnimation"
        ],
        
        // Ash Furrow
        "ashfurrow": [
            "Moya",
            "Artsy"
        ],
        
        // Sindre Sorhus
        "sindresorhus": [
            "Defaults",
            "KeyboardShortcuts",
            "LaunchAtLogin",
            "Preferences"
        ],
        
        // Vincent Pradeilles
        "vincent-pradeilles": [
            "swift-tips"
        ],
        
        // Antoine van der Lee
        "AvdLee": [
            "Diagnostics",
            "RocketSimApp"
        ],
        
        // Donny Wals
        "donnywals": [
            "practical-combine",
            "practical-core-data"
        ],
        
        // Sean Allen
        "SAllen0400": [
            "swift-tutorials"
        ],
        
        // Stewart Lynch
        "StewartLynch": [
            "SwiftUI-Tutorials"
        ],
        
        // Majid Jabrayilov
        "mecid": [
            "swiftui-recipes"
        ]
    ]
    
    private init() {
        loadPersistedData()
    }
    
    // MARK: - Main Processing
    
    /// Index all configured repositories and generate templates
    func indexAndGenerateTemplates() async {
        isProcessing = true
        progress = 0.0
        
        var allRepoData: [RepositoryAnalysis] = []
        
        // 1. Index Apple's repos
        if config.indexAppleRepos {
            currentTask = "Indexing Apple repositories..."
            let appleData = await indexRepositories(appleRepos)
            allRepoData.append(contentsOf: appleData)
            progress = 0.33
        }
        
        // 2. Index Swift Server repos
        if config.indexSwiftServerRepos {
            currentTask = "Indexing Swift Server repositories..."
            let serverData = await indexRepositories(swiftServerRepos)
            allRepoData.append(contentsOf: serverData)
            progress = 0.66
        }
        
        // 3. Index community repos
        if config.indexCommunityRepos {
            currentTask = "Indexing community repositories..."
            let communityData = await indexRepositories(communityRepos)
            allRepoData.append(contentsOf: communityData)
            progress = 0.80
        }
        
        // 4. Index custom repos
        if !config.customRepos.isEmpty {
            currentTask = "Indexing custom repositories..."
            let customData = await indexRepositories(config.customRepos)
            allRepoData.append(contentsOf: customData)
            progress = 0.90
        }
        
        // 5. Analyze and generate templates
        currentTask = "Analyzing patterns and generating templates..."
        patterns = extractArchitecturePatterns(from: allRepoData)
        templates = generateProjectTemplates(from: allRepoData, patterns: patterns)
        ideas = generateProjectIdeas(from: allRepoData, patterns: patterns)
        
        // 6. Generate learning content
        if config.generateTutorials {
            currentTask = "Generating tutorials..."
            tutorials = generateTutorials(from: allRepoData)
        }
        
        if config.generateWalkthroughs {
            currentTask = "Generating walkthroughs..."
            walkthroughs = generateWalkthroughs(from: allRepoData)
        }
        
        if config.generateHowTos {
            currentTask = "Generating how-tos..."
            howTos = generateHowTos(from: allRepoData)
        }
        
        // 7. Generate MVVM examples
        currentTask = "Generating MVVM examples..."
        mvvmExamples = generateMVVMExamples(from: allRepoData)
        
        // 6. Save everything
        currentTask = "Saving templates and patterns..."
        await saveData()
        
        progress = 1.0
        currentTask = "Complete!"
        isProcessing = false
        
        print("✅ Generated \(templates.count) templates, \(patterns.count) patterns, \(ideas.count) ideas")
    }
    
    // MARK: - Repository Indexing
    
    private func indexRepositories(_ repos: [String]) async -> [RepositoryAnalysis] {
        var analyses: [RepositoryAnalysis] = []
        
        for repoPath in repos {
            let components = repoPath.split(separator: "/")
            guard components.count == 2 else { continue }
            
            let owner = String(components[0])
            let repo = String(components[1])
            
            do {
                let analysis = try await analyzeRepository(owner: owner, repo: repo)
                analyses.append(analysis)
                print("✅ Analyzed \(repoPath)")
            } catch {
                print("⚠️ Failed to analyze \(repoPath): \(error)")
            }
            
            // Rate limiting
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return analyses
    }
    
    private func analyzeRepository(owner: String, repo: String) async throws -> RepositoryAnalysis {
        // Fetch repository structure
        let contents = try await github.fetchRepositoryContent(owner: owner, repo: repo)
        
        // Analyze project structure
        let structure = analyzeProjectStructure(contents)
        
        // Detect frameworks and dependencies
        let frameworks = try await detectFrameworks(owner: owner, repo: repo, contents: contents)
        
        // Extract architecture patterns
        let architectureType = detectArchitectureType(from: contents)
        
        // Analyze Package.swift if exists
        var dependencies: [String] = []
        if contents.contains(where: { $0.name == "Package.swift" }) {
            dependencies = try await extractDependencies(owner: owner, repo: repo)
        }
        
        return RepositoryAnalysis(
            owner: owner,
            repo: repo,
            structure: structure,
            frameworks: frameworks,
            dependencies: dependencies,
            architectureType: architectureType,
            fileTypes: analyzeFileTypes(contents),
            codeMetrics: CodeMetrics(
                totalFiles: contents.count,
                swiftFiles: contents.filter { $0.name.hasSuffix(".swift") }.count,
                testFiles: contents.filter { $0.path.contains("Tests") }.count
            )
        )
    }
    
    private func analyzeProjectStructure(_ contents: [GitHubContent]) -> ProjectStructure {
        var structure = ProjectStructure()
        
        for item in contents {
            if item.type == "dir" {
                structure.directories.append(item.name)
                
                // Categorize directories
                if item.name.contains("Test") {
                    structure.hasTests = true
                }
                if item.name == "Sources" || item.name == "src" {
                    structure.hasSources = true
                }
                if item.name == "Examples" {
                    structure.hasExamples = true
                }
                if item.name == "Documentation" || item.name == "Docs" {
                    structure.hasDocumentation = true
                }
            } else if item.type == "file" {
                structure.files.append(item.name)
                
                // Check for important files
                if item.name == "Package.swift" {
                    structure.isSwiftPackage = true
                }
                if item.name == "README.md" {
                    structure.hasReadme = true
                }
                if item.name.hasSuffix(".xcodeproj") {
                    structure.isXcodeProject = true
                }
            }
        }
        
        return structure
    }
    
    private func detectFrameworks(owner: String, repo: String, contents: [GitHubContent]) async throws -> [String] {
        var frameworks = Set<String>()
        
        // Sample a few Swift files to detect imports
        let swiftFiles = contents.filter { $0.name.hasSuffix(".swift") }.prefix(10)
        
        for file in swiftFiles {
            do {
                let content = try await github.fetchFileContent(owner: owner, repo: repo, path: file.path)
                
                // Extract imports
                let importPattern = "import\\s+(\\w+)"
                if let regex = try? NSRegularExpression(pattern: importPattern) {
                    let range = NSRange(content.startIndex..., in: content)
                    let matches = regex.matches(in: content, range: range)
                    for match in matches {
                        if let range = Range(match.range(at: 1), in: content) {
                            frameworks.insert(String(content[range]))
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        return Array(frameworks).sorted()
    }
    
    private func detectArchitectureType(from contents: [GitHubContent]) -> ArchitectureType {
        let fileNames = contents.map { $0.name.lowercased() }
        
        if fileNames.contains(where: { $0.contains("viewmodel") }) {
            return .mvvm
        }
        if fileNames.contains(where: { $0.contains("presenter") }) {
            return .mvp
        }
        if fileNames.contains(where: { $0.contains("coordinator") }) {
            return .coordinator
        }
        if fileNames.contains(where: { $0.contains("reducer") || $0.contains("store") }) {
            return .redux
        }
        if fileNames.contains(where: { $0.contains("viper") }) {
            return .viper
        }
        
        return .mvc
    }
    
    private func extractDependencies(owner: String, repo: String) async throws -> [String] {
        let packageContent = try await github.fetchFileContent(owner: owner, repo: repo, path: "Package.swift")
        
        var dependencies: [String] = []
        
        // Simple regex to extract package names
        let pattern = "\\.package\\(.*?url:\\s*\"https://github\\.com/([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) {
            let range = NSRange(packageContent.startIndex..., in: packageContent)
            let matches = regex.matches(in: packageContent, range: range)
            for match in matches {
                if let range = Range(match.range(at: 1), in: packageContent) {
                    dependencies.append(String(packageContent[range]))
                }
            }
        }
        
        return dependencies
    }
    
    private func analyzeFileTypes(_ contents: [GitHubContent]) -> [String: Int] {
        var fileTypes: [String: Int] = [:]
        
        for item in contents where item.type == "file" {
            let ext = (item.name as NSString).pathExtension
            if !ext.isEmpty {
                fileTypes[ext, default: 0] += 1
            }
        }
        
        return fileTypes
    }
    
    // MARK: - Pattern Extraction
    
    private func extractArchitecturePatterns(from analyses: [RepositoryAnalysis]) -> [ArchitecturePattern] {
        var patterns: [ArchitecturePattern] = []
        
        // Group by architecture type
        let architectureGroups = Dictionary(grouping: analyses, by: { $0.architectureType })
        
        for (archType, repos) in architectureGroups {
            let commonFrameworks = findCommonFrameworks(in: repos)
            let commonStructure = findCommonStructure(in: repos)
            
            let pattern = ArchitecturePattern(
                name: archType.rawValue,
                description: archType.description,
                frameworks: commonFrameworks,
                structure: commonStructure,
                examples: repos.map { "\($0.owner)/\($0.repo)" },
                frequency: repos.count
            )
            patterns.append(pattern)
        }
        
        return patterns.sorted { $0.frequency > $1.frequency }
    }
    
    private func findCommonFrameworks(in repos: [RepositoryAnalysis]) -> [String] {
        var frameworkCounts: [String: Int] = [:]
        
        for repo in repos {
            for framework in repo.frameworks {
                frameworkCounts[framework, default: 0] += 1
            }
        }
        
        // Return frameworks used in at least 50% of repos
        let threshold = repos.count / 2
        return frameworkCounts.filter { $0.value >= threshold }.map { $0.key }.sorted()
    }
    
    private func findCommonStructure(in repos: [RepositoryAnalysis]) -> [String] {
        var dirCounts: [String: Int] = [:]
        
        for repo in repos {
            for dir in repo.structure.directories {
                dirCounts[dir, default: 0] += 1
            }
        }
        
        let threshold = repos.count / 2
        return dirCounts.filter { $0.value >= threshold }.map { $0.key }.sorted()
    }
    
    // MARK: - Template Generation
    
    private func generateProjectTemplates(from analyses: [RepositoryAnalysis], patterns: [ArchitecturePattern]) -> [ProjectTemplate] {
        var templates: [ProjectTemplate] = []
        
        for pattern in patterns {
            let template = ProjectTemplate(
                id: UUID().uuidString,
                name: "\(pattern.name) Template",
                description: "Production-ready \(pattern.name) project template based on \(pattern.examples.count) real-world examples",
                architecture: pattern.name,
                frameworks: pattern.frameworks,
                structure: pattern.structure,
                files: generateTemplateFiles(for: pattern),
                dependencies: extractCommonDependencies(from: analyses.filter { $0.architectureType.rawValue == pattern.name }),
                examples: pattern.examples
            )
            templates.append(template)
        }
        
        return templates
    }
    
    private func generateTemplateFiles(for pattern: ArchitecturePattern) -> [TemplateFile] {
        var files: [TemplateFile] = []
        
        // Always include Package.swift
        files.append(TemplateFile(
            path: "Package.swift",
            content: generatePackageSwift(pattern: pattern),
            description: "Swift Package Manager manifest"
        ))
        
        // Add README
        files.append(TemplateFile(
            path: "README.md",
            content: generateReadme(pattern: pattern),
            description: "Project documentation"
        ))
        
        // Add architecture-specific files
        switch pattern.name {
        case "MVVM":
            files.append(contentsOf: generateMVVMFiles())
        case "MVC":
            files.append(contentsOf: generateMVCFiles())
        case "Redux":
            files.append(contentsOf: generateReduxFiles())
        default:
            files.append(contentsOf: generateBasicFiles())
        }
        
        return files
    }
    
    private func generatePackageSwift(pattern: ArchitecturePattern) -> String {
        """
        // swift-tools-version: 5.9
        import PackageDescription
        
        let package = Package(
            name: "MyProject",
            platforms: [
                .macOS(.v14),
                .iOS(.v17)
            ],
            products: [
                .library(name: "MyProject", targets: ["MyProject"])
            ],
            dependencies: [
                // Add dependencies here
            ],
            targets: [
                .target(
                    name: "MyProject",
                    dependencies: []
                ),
                .testTarget(
                    name: "MyProjectTests",
                    dependencies: ["MyProject"]
                )
            ]
        )
        """
    }
    
    private func generateReadme(pattern: ArchitecturePattern) -> String {
        """
        # MyProject
        
        A \(pattern.name) project template generated from real-world examples.
        
        ## Architecture
        
        This project follows the **\(pattern.name)** architecture pattern.
        
        \(pattern.description)
        
        ## Frameworks
        
        \(pattern.frameworks.map { "- \($0)" }.joined(separator: "\n"))
        
        ## Project Structure
        
        ```
        \(pattern.structure.map { "├── \($0)/" }.joined(separator: "\n"))
        ```
        
        ## Getting Started
        
        1. Clone the repository
        2. Open in Xcode
        3. Build and run
        
        ## Examples
        
        This template is based on these production projects:
        \(pattern.examples.prefix(5).map { "- https://github.com/\($0)" }.joined(separator: "\n"))
        """
    }
    
    private func generateMVVMFiles() -> [TemplateFile] {
        [
            TemplateFile(
                path: "Sources/MyProject/Views/ContentView.swift",
                content: """
                import SwiftUI
                
                struct ContentView: View {
                    @StateObject private var viewModel = ContentViewModel()
                    
                    var body: some View {
                        Text("Hello, MVVM!")
                    }
                }
                """,
                description: "Main view"
            ),
            TemplateFile(
                path: "Sources/MyProject/ViewModels/ContentViewModel.swift",
                content: """
                import Foundation
                import Combine
                
                @MainActor
                class ContentViewModel: ObservableObject {
                    @Published var data: String = ""
                    
                    func loadData() async {
                        // Load data
                    }
                }
                """,
                description: "View model"
            )
        ]
    }
    
    private func generateMVCFiles() -> [TemplateFile] {
        [
            TemplateFile(
                path: "Sources/MyProject/Views/ContentView.swift",
                content: """
                import SwiftUI
                
                struct ContentView: View {
                    var body: some View {
                        Text("Hello, MVC!")
                    }
                }
                """,
                description: "Main view"
            ),
            TemplateFile(
                path: "Sources/MyProject/Models/DataModel.swift",
                content: """
                import Foundation
                
                struct DataModel: Codable {
                    let id: UUID
                    let name: String
                }
                """,
                description: "Data model"
            )
        ]
    }
    
    private func generateReduxFiles() -> [TemplateFile] {
        [
            TemplateFile(
                path: "Sources/MyProject/Store/AppStore.swift",
                content: """
                import Foundation
                import Combine
                
                @MainActor
                class AppStore: ObservableObject {
                    @Published var state: AppState
                    
                    init(state: AppState = AppState()) {
                        self.state = state
                    }
                    
                    func dispatch(_ action: AppAction) {
                        state = reduce(state: state, action: action)
                    }
                }
                """,
                description: "Redux store"
            )
        ]
    }
    
    private func generateBasicFiles() -> [TemplateFile] {
        [
            TemplateFile(
                path: "Sources/MyProject/MyProject.swift",
                content: """
                import Foundation
                
                public struct MyProject {
                    public init() {}
                    
                    public func hello() -> String {
                        "Hello, World!"
                    }
                }
                """,
                description: "Main module"
            )
        ]
    }
    
    private func extractCommonDependencies(from analyses: [RepositoryAnalysis]) -> [String] {
        var depCounts: [String: Int] = [:]
        
        for analysis in analyses {
            for dep in analysis.dependencies {
                depCounts[dep, default: 0] += 1
            }
        }
        
        return depCounts.sorted { $0.value > $1.value }.prefix(10).map { $0.key }
    }
    
    // MARK: - Idea Generation
    
    private func generateProjectIdeas(from analyses: [RepositoryAnalysis], patterns: [ArchitecturePattern]) -> [ProjectIdea] {
        var ideas: [ProjectIdea] = []
        
        // Combine different patterns and frameworks to generate ideas
        for pattern in patterns {
            for framework in pattern.frameworks where !["Foundation", "Swift"].contains(framework) {
                let idea = ProjectIdea(
                    title: "\(framework) \(pattern.name) App",
                    description: "Build a production-ready app using \(framework) with \(pattern.name) architecture",
                    architecture: pattern.name,
                    frameworks: [framework] + pattern.frameworks.filter { $0 != framework }.prefix(3),
                    difficulty: calculateDifficulty(pattern: pattern, framework: framework),
                    estimatedTime: "2-4 weeks",
                    examples: pattern.examples.prefix(3).map { $0 }
                )
                ideas.append(idea)
            }
        }
        
        return ideas.prefix(20).map { $0 }
    }
    
    private func calculateDifficulty(pattern: ArchitecturePattern, framework: String) -> String {
        if pattern.name == "VIPER" || pattern.name == "Redux" {
            return "Advanced"
        }
        if pattern.name == "MVVM" || pattern.name == "Coordinator" {
            return "Intermediate"
        }
        return "Beginner"
    }
    
    // MARK: - Tutorial Generation
    
    /// Generate comprehensive tutorials from indexed code
    func generateTutorials(from analyses: [RepositoryAnalysis]) -> [Tutorial] {
        var tutorials: [Tutorial] = []
        
        // Group by topic
        let mvvmRepos = analyses.filter { $0.architectureType == .mvvm }
        _ = analyses.filter { $0.architectureType == .redux }
        
        // MVVM Tutorial
        if !mvvmRepos.isEmpty {
            tutorials.append(Tutorial(
                id: UUID().uuidString,
                title: "Complete MVVM Guide in Swift",
                description: "Learn MVVM architecture from \(mvvmRepos.count) production examples",
                difficulty: "Intermediate",
                duration: "2 hours",
                sections: generateMVVMTutorialSections(from: mvvmRepos),
                codeExamples: extractBestCodeExamples(from: mvvmRepos, count: 10),
                resources: mvvmRepos.map { "https://github.com/\($0.owner)/\($0.repo)" }
            ))
        }
        
        // SwiftUI Tutorial
        let swiftUIRepos = analyses.filter { $0.frameworks.contains("SwiftUI") }
        if !swiftUIRepos.isEmpty {
            tutorials.append(Tutorial(
                id: UUID().uuidString,
                title: "SwiftUI Best Practices",
                description: "Learn from \(swiftUIRepos.count) real SwiftUI projects",
                difficulty: "Beginner",
                duration: "1.5 hours",
                sections: generateSwiftUITutorialSections(from: swiftUIRepos),
                codeExamples: extractBestCodeExamples(from: swiftUIRepos, count: 15),
                resources: swiftUIRepos.prefix(10).map { "https://github.com/\($0.owner)/\($0.repo)" }
            ))
        }
        
        // Combine Tutorial
        let combineRepos = analyses.filter { $0.frameworks.contains("Combine") }
        if !combineRepos.isEmpty {
            tutorials.append(Tutorial(
                id: UUID().uuidString,
                title: "Mastering Combine Framework",
                description: "Reactive programming patterns from production code",
                difficulty: "Advanced",
                duration: "3 hours",
                sections: generateCombineTutorialSections(from: combineRepos),
                codeExamples: extractBestCodeExamples(from: combineRepos, count: 12),
                resources: combineRepos.prefix(8).map { "https://github.com/\($0.owner)/\($0.repo)" }
            ))
        }
        
        return tutorials
    }
    
    private func generateMVVMTutorialSections(from repos: [RepositoryAnalysis]) -> [TutorialSection] {
        [
            TutorialSection(
                title: "Introduction to MVVM",
                content: """
                MVVM (Model-View-ViewModel) is a design pattern that separates UI logic from business logic.
                
                Based on analysis of \(repos.count) production MVVM projects, here's what you need to know:
                
                ## Key Components
                
                1. **Model**: Data structures and business logic
                2. **View**: SwiftUI views that display data
                3. **ViewModel**: Mediator between Model and View, handles presentation logic
                
                ## Why MVVM?
                
                - Testable: ViewModels can be unit tested
                - Reusable: ViewModels can be shared across views
                - Maintainable: Clear separation of concerns
                """,
                codeExample: """
                // Model
                struct User: Codable {
                    let id: UUID
                    let name: String
                    let email: String
                }
                
                // ViewModel
                @MainActor
                class UserViewModel: ObservableObject {
                    @Published var user: User?
                    @Published var isLoading = false
                    
                    func loadUser() async {
                        isLoading = true
                        // Fetch user data
                        isLoading = false
                    }
                }
                
                // View
                struct UserView: View {
                    @StateObject private var viewModel = UserViewModel()
                    
                    var body: some View {
                        if viewModel.isLoading {
                            ProgressView()
                        } else if let user = viewModel.user {
                            Text(user.name)
                        }
                    }
                }
                """
            ),
            TutorialSection(
                title: "Setting Up Your First MVVM Project",
                content: """
                Let's create a production-ready MVVM project structure.
                
                ## Project Structure
                
                ```
                MyApp/
                ├── Models/
                │   └── User.swift
                ├── ViewModels/
                │   └── UserViewModel.swift
                ├── Views/
                │   └── UserView.swift
                └── Services/
                    └── APIService.swift
                ```
                
                ## Best Practices from Real Projects
                
                1. Use `@MainActor` for ViewModels
                2. Use `@Published` for observable properties
                3. Keep ViewModels testable (no UIKit/SwiftUI dependencies)
                4. Use dependency injection for services
                """,
                codeExample: """
                // Dependency Injection Example
                @MainActor
                class UserViewModel: ObservableObject {
                    @Published var users: [User] = []
                    
                    private let apiService: APIServiceProtocol
                    
                    init(apiService: APIServiceProtocol = APIService()) {
                        self.apiService = apiService
                    }
                    
                    func fetchUsers() async {
                        do {
                            users = try await apiService.fetchUsers()
                        } catch {
                            print("Error: \\(error)")
                        }
                    }
                }
                """
            )
        ]
    }
    
    private func generateSwiftUITutorialSections(from repos: [RepositoryAnalysis]) -> [TutorialSection] {
        [
            TutorialSection(
                title: "SwiftUI Fundamentals",
                content: """
                SwiftUI is Apple's declarative UI framework. Based on \(repos.count) real projects.
                
                ## Core Concepts
                
                - Views are structs
                - State management with @State, @Binding, @ObservedObject
                - Declarative syntax
                - Automatic updates
                """,
                codeExample: """
                struct ContentView: View {
                    @State private var count = 0
                    
                    var body: some View {
                        VStack {
                            Text("Count: \\(count)")
                            Button("Increment") {
                                count += 1
                            }
                        }
                    }
                }
                """
            )
        ]
    }
    
    private func generateCombineTutorialSections(from repos: [RepositoryAnalysis]) -> [TutorialSection] {
        [
            TutorialSection(
                title: "Combine Basics",
                content: """
                Combine is Apple's reactive programming framework.
                
                ## Publishers and Subscribers
                
                Learn from \(repos.count) production implementations.
                """,
                codeExample: """
                import Combine
                
                class DataService {
                    @Published var data: [String] = []
                    
                    func fetchData() -> AnyPublisher<[String], Error> {
                        URLSession.shared
                            .dataTaskPublisher(for: url)
                            .map { $0.data }
                            .decode(type: [String].self, decoder: JSONDecoder())
                            .eraseToAnyPublisher()
                    }
                }
                """
            )
        ]
    }
    
    private func extractBestCodeExamples(from repos: [RepositoryAnalysis], count: Int) -> [CodeSnippet] {
        // This would extract actual code from the repos
        // For now, return placeholder
        []
    }
    
    // MARK: - Walkthrough Generation
    
    func generateWalkthroughs(from analyses: [RepositoryAnalysis]) -> [Walkthrough] {
        var walkthroughs: [Walkthrough] = []
        
        // "Build a Complete App" Walkthrough
        walkthroughs.append(Walkthrough(
            id: UUID().uuidString,
            title: "Build a Complete SwiftUI + MVVM App",
            description: "Step-by-step guide to building a production-ready app",
            estimatedTime: "4 hours",
            steps: generateCompleteAppSteps(),
            finalProject: generateFinalProjectStructure(),
            learningOutcomes: [
                "Understand MVVM architecture",
                "Master SwiftUI layouts",
                "Implement networking with async/await",
                "Add proper error handling",
                "Write unit tests"
            ]
        ))
        
        return walkthroughs
    }
    
    private func generateCompleteAppSteps() -> [WalkthroughStep] {
        [
            WalkthroughStep(
                number: 1,
                title: "Project Setup",
                description: "Create a new Swift Package and set up the project structure",
                code: """
                // Create Package.swift
                // swift-tools-version: 5.9
                import PackageDescription
                
                let package = Package(
                    name: "MyApp",
                    platforms: [.iOS(.v17), .macOS(.v14)],
                    products: [
                        .library(name: "MyApp", targets: ["MyApp"])
                    ],
                    targets: [
                        .target(name: "MyApp"),
                        .testTarget(name: "MyAppTests", dependencies: ["MyApp"])
                    ]
                )
                """,
                explanation: "We're using Swift Package Manager for better modularity and testability"
            ),
            WalkthroughStep(
                number: 2,
                title: "Create the Model",
                description: "Define your data structures",
                code: """
                struct Article: Codable, Identifiable {
                    let id: UUID
                    let title: String
                    let content: String
                    let author: String
                    let publishedAt: Date
                }
                """,
                explanation: "Models should be simple, immutable structs that conform to Codable for easy serialization"
            ),
            WalkthroughStep(
                number: 3,
                title: "Build the ViewModel",
                description: "Create the ViewModel with @Published properties",
                code: """
                @MainActor
                class ArticleListViewModel: ObservableObject {
                    @Published var articles: [Article] = []
                    @Published var isLoading = false
                    @Published var error: Error?
                    
                    private let apiService: APIService
                    
                    init(apiService: APIService = .shared) {
                        self.apiService = apiService
                    }
                    
                    func loadArticles() async {
                        isLoading = true
                        defer { isLoading = false }
                        
                        do {
                            articles = try await apiService.fetchArticles()
                        } catch {
                            self.error = error
                        }
                    }
                }
                """,
                explanation: "@MainActor ensures all UI updates happen on the main thread"
            ),
            WalkthroughStep(
                number: 4,
                title: "Create the View",
                description: "Build the SwiftUI view",
                code: """
                struct ArticleListView: View {
                    @StateObject private var viewModel = ArticleListViewModel()
                    
                    var body: some View {
                        NavigationStack {
                            List(viewModel.articles) { article in
                                ArticleRow(article: article)
                            }
                            .navigationTitle("Articles")
                            .task {
                                await viewModel.loadArticles()
                            }
                            .overlay {
                                if viewModel.isLoading {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
                """,
                explanation: "Use .task for async operations that should run when the view appears"
            )
        ]
    }
    
    private func generateFinalProjectStructure() -> String {
        """
        MyApp/
        ├── Sources/
        │   └── MyApp/
        │       ├── Models/
        │       │   └── Article.swift
        │       ├── ViewModels/
        │       │   └── ArticleListViewModel.swift
        │       ├── Views/
        │       │   ├── ArticleListView.swift
        │       │   └── ArticleRow.swift
        │       └── Services/
        │           └── APIService.swift
        └── Tests/
            └── MyAppTests/
                └── ArticleListViewModelTests.swift
        """
    }
    
    // MARK: - How-To Generation
    
    func generateHowTos(from analyses: [RepositoryAnalysis]) -> [HowTo] {
        [
            HowTo(
                id: UUID().uuidString,
                title: "How to Implement MVVM in SwiftUI",
                problem: "You want to separate business logic from UI code",
                solution: "Use the MVVM pattern with ObservableObject",
                steps: [
                    "Create a Model struct",
                    "Create a ViewModel class conforming to ObservableObject",
                    "Use @Published for properties that trigger UI updates",
                    "Create a View that observes the ViewModel with @StateObject"
                ],
                codeExample: """
                // Complete MVVM Example
                
                // 1. Model
                struct User: Codable {
                    let id: UUID
                    let name: String
                }
                
                // 2. ViewModel
                @MainActor
                class UserViewModel: ObservableObject {
                    @Published var users: [User] = []
                    
                    func loadUsers() async {
                        // Load data
                    }
                }
                
                // 3. View
                struct UserListView: View {
                    @StateObject private var viewModel = UserViewModel()
                    
                    var body: some View {
                        List(viewModel.users, id: \\.id) { user in
                            Text(user.name)
                        }
                        .task {
                            await viewModel.loadUsers()
                        }
                    }
                }
                """,
                relatedTopics: ["SwiftUI", "Combine", "Architecture Patterns"],
                difficulty: "Intermediate"
            ),
            HowTo(
                id: UUID().uuidString,
                title: "How to Handle Async/Await in SwiftUI",
                problem: "You need to perform async operations in SwiftUI views",
                solution: "Use .task modifier and @MainActor",
                steps: [
                    "Mark your ViewModel with @MainActor",
                    "Use async functions in ViewModel",
                    "Call async functions using .task modifier in View",
                    "Handle loading states with @Published properties"
                ],
                codeExample: """
                @MainActor
                class DataViewModel: ObservableObject {
                    @Published var data: [String] = []
                    @Published var isLoading = false
                    
                    func fetchData() async {
                        isLoading = true
                        defer { isLoading = false }
                        
                        // Async operation
                        data = try? await URLSession.shared.data(from: url)
                    }
                }
                
                struct DataView: View {
                    @StateObject private var viewModel = DataViewModel()
                    
                    var body: some View {
                        List(viewModel.data, id: \\.self) { item in
                            Text(item)
                        }
                        .task {
                            await viewModel.fetchData()
                        }
                        .overlay {
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                    }
                }
                """,
                relatedTopics: ["Async/Await", "Concurrency", "SwiftUI"],
                difficulty: "Intermediate"
            )
        ]
    }
    
    // MARK: - MVVM Examples Generation
    
    func generateMVVMExamples(from analyses: [RepositoryAnalysis]) -> [MVVMExample] {
        let mvvmRepos = analyses.filter { $0.architectureType == .mvvm }
        
        return [
            MVVMExample(
                id: UUID().uuidString,
                title: "Simple List with MVVM",
                description: "Basic list view with data fetching",
                complexity: "Simple",
                model: """
                struct Item: Identifiable, Codable {
                    let id: UUID
                    let title: String
                    let description: String
                }
                """,
                viewModel: """
                @MainActor
                class ItemListViewModel: ObservableObject {
                    @Published var items: [Item] = []
                    @Published var isLoading = false
                    @Published var errorMessage: String?
                    
                    func loadItems() async {
                        isLoading = true
                        errorMessage = nil
                        
                        do {
                            // Simulate API call
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            items = [
                                Item(id: UUID(), title: "Item 1", description: "Description 1"),
                                Item(id: UUID(), title: "Item 2", description: "Description 2")
                            ]
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        
                        isLoading = false
                    }
                }
                """,
                view: """
                struct ItemListView: View {
                    @StateObject private var viewModel = ItemListViewModel()
                    
                    var body: some View {
                        NavigationStack {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView("Loading...")
                                } else if let error = viewModel.errorMessage {
                                    Text("Error: \\(error)")
                                        .foregroundStyle(.red)
                                } else {
                                    List(viewModel.items) { item in
                                        VStack(alignment: .leading) {
                                            Text(item.title)
                                                .font(.headline)
                                            Text(item.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .navigationTitle("Items")
                            .task {
                                await viewModel.loadItems()
                            }
                        }
                    }
                }
                """,
                testExample: """
                @MainActor
                class ItemListViewModelTests: XCTestCase {
                    func testLoadItems() async {
                        let viewModel = ItemListViewModel()
                        
                        await viewModel.loadItems()
                        
                        XCTAssertFalse(viewModel.isLoading)
                        XCTAssertEqual(viewModel.items.count, 2)
                        XCTAssertNil(viewModel.errorMessage)
                    }
                }
                """,
                realWorldExamples: mvvmRepos.prefix(3).map { "https://github.com/\($0.owner)/\($0.repo)" }
            )
        ]
    }
    
    // MARK: - Persistence
    
    private func saveData() async {
        let data = BoilerplateDatabase(
            templates: templates,
            patterns: patterns,
            ideas: ideas,
            tutorials: tutorials,
            walkthroughs: walkthroughs,
            howTos: howTos,
            mvvmExamples: mvvmExamples,
            generatedAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(data)
            let url = dataFileURL()
            try jsonData.write(to: url)
            print("✅ Saved boilerplate data to: \(url.path)")
        } catch {
            print("❌ Failed to save data: \(error)")
        }
    }
    
    private func loadPersistedData() {
        let url = dataFileURL()
        guard let data = try? Data(contentsOf: url),
              let database = try? JSONDecoder().decode(BoilerplateDatabase.self, from: data) else {
            return
        }
        
        templates = database.templates
        patterns = database.patterns
        ideas = database.ideas
        tutorials = database.tutorials
        walkthroughs = database.walkthroughs
        howTos = database.howTos
        mvvmExamples = database.mvvmExamples
        print("✅ Loaded \(templates.count) templates, \(tutorials.count) tutorials, \(howTos.count) how-tos")
    }
    
    private func dataFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("HIG", isDirectory: true)
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        return appFolder.appendingPathComponent("boilerplate_machine.json")
    }
}

// MARK: - Models

struct RepositoryAnalysis: Codable {
    let owner: String
    let repo: String
    let structure: ProjectStructure
    let frameworks: [String]
    let dependencies: [String]
    let architectureType: ArchitectureType
    let fileTypes: [String: Int]
    let codeMetrics: CodeMetrics
}

struct ProjectStructure: Codable {
    var directories: [String] = []
    var files: [String] = []
    var hasTests: Bool = false
    var hasSources: Bool = false
    var hasExamples: Bool = false
    var hasDocumentation: Bool = false
    var isSwiftPackage: Bool = false
    var isXcodeProject: Bool = false
    var hasReadme: Bool = false
}

enum ArchitectureType: String, Codable {
    case mvc = "MVC"
    case mvvm = "MVVM"
    case mvp = "MVP"
    case viper = "VIPER"
    case redux = "Redux"
    case coordinator = "Coordinator"
    
    var description: String {
        switch self {
        case .mvc: return "Model-View-Controller pattern"
        case .mvvm: return "Model-View-ViewModel pattern with reactive bindings"
        case .mvp: return "Model-View-Presenter pattern"
        case .viper: return "View-Interactor-Presenter-Entity-Router pattern"
        case .redux: return "Unidirectional data flow with centralized state"
        case .coordinator: return "Coordinator pattern for navigation flow"
        }
    }
}

struct CodeMetrics: Codable {
    let totalFiles: Int
    let swiftFiles: Int
    let testFiles: Int
}

struct ArchitecturePattern: Codable {
    let name: String
    let description: String
    let frameworks: [String]
    let structure: [String]
    let examples: [String]
    let frequency: Int
}

struct ProjectTemplate: Codable {
    let id: String
    let name: String
    let description: String
    let architecture: String
    let frameworks: [String]
    let structure: [String]
    let files: [TemplateFile]
    let dependencies: [String]
    let examples: [String]
}

struct TemplateFile: Codable {
    let path: String
    let content: String
    let description: String
}

struct ProjectIdea: Codable {
    let title: String
    let description: String
    let architecture: String
    let frameworks: [String]
    let difficulty: String
    let estimatedTime: String
    let examples: [String]
}

struct BoilerplateDatabase: Codable {
    let templates: [ProjectTemplate]
    let patterns: [ArchitecturePattern]
    let ideas: [ProjectIdea]
    let tutorials: [Tutorial]
    let walkthroughs: [Walkthrough]
    let howTos: [HowTo]
    let mvvmExamples: [MVVMExample]
    let generatedAt: Date
}

struct BoilerplateConfig: Codable {
    var indexAppleRepos: Bool = true
    var indexSwiftServerRepos: Bool = true
    var indexCommunityRepos: Bool = true
    var indexPopularDevelopers: Bool = true
    var customRepos: [String] = []
    var autoUpdate: Bool = false
    var updateInterval: TimeInterval = 604800 // 1 week
    var generateTutorials: Bool = true
    var generateWalkthroughs: Bool = true
    var generateHowTos: Bool = true
    
    static func load() -> BoilerplateConfig {
        guard let data = UserDefaults.standard.data(forKey: "boilerplateConfig"),
              let config = try? JSONDecoder().decode(BoilerplateConfig.self, from: data) else {
            return BoilerplateConfig()
        }
        return config
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "boilerplateConfig")
        }
    }
}

// MARK: - Tutorial Models

struct Tutorial: Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let duration: String
    let sections: [TutorialSection]
    let codeExamples: [CodeSnippet]
    let resources: [String]
}

struct TutorialSection: Codable {
    let title: String
    let content: String
    let codeExample: String
}

struct CodeSnippet: Codable {
    let title: String
    let code: String
    let language: String
    let explanation: String
}

// MARK: - Walkthrough Models

struct Walkthrough: Codable {
    let id: String
    let title: String
    let description: String
    let estimatedTime: String
    let steps: [WalkthroughStep]
    let finalProject: String
    let learningOutcomes: [String]
}

struct WalkthroughStep: Codable {
    let number: Int
    let title: String
    let description: String
    let code: String
    let explanation: String
}

// MARK: - How-To Models

struct HowTo: Codable {
    let id: String
    let title: String
    let problem: String
    let solution: String
    let steps: [String]
    let codeExample: String
    let relatedTopics: [String]
    let difficulty: String
}

// MARK: - MVVM Example Models

struct MVVMExample: Codable {
    let id: String
    let title: String
    let description: String
    let complexity: String
    let model: String
    let viewModel: String
    let view: String
    let testExample: String
    let realWorldExamples: [String]
}
