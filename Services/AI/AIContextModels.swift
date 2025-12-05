import Foundation

public struct ContextStatistics: Codable, Equatable {
    public var totalFiles: Int
    public var totalLines: Int
    public var languages: [String]
    public var frameworks: [String]
    
    public init() {
        self.totalFiles = 0
        self.totalLines = 0
        self.languages = []
        self.frameworks = []
    }
}

public struct CodePattern: Codable, Equatable {
    public var name: String
    public var description: String
    public var example: String
    public var frequency: Int
    public var language: String
    
    public init(name: String = "", description: String = "", example: String = "", frequency: Int = 0, language: String = "") {
        self.name = name
        self.description = description
        self.example = example
        self.frequency = frequency
        self.language = language
    }
}

public struct BestPractice: Codable, Equatable {
    public var title: String
    public var description: String
    public var examples: [String]
    public var adherence: Double
    
    public init(title: String = "", description: String = "", examples: [String] = [], adherence: Double = 0.0) {
        self.title = title
        self.description = description
        self.examples = examples
        self.adherence = adherence
    }
}

public enum CodeContextSource: Codable, Equatable {
    case github(repo: String)
    case local
    case documentation
    
    private enum CodingKeys: String, CodingKey {
        case type
        case repo
    }
    
    private enum SourceType: String, Codable {
        case github
        case local
        case documentation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SourceType.self, forKey: .type)
        switch type {
        case .github:
            let repo = try container.decode(String.self, forKey: .repo)
            self = .github(repo: repo)
        case .local:
            self = .local
        case .documentation:
            self = .documentation
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .github(let repo):
            try container.encode(SourceType.github, forKey: .type)
            try container.encode(repo, forKey: .repo)
        case .local:
            try container.encode(SourceType.local, forKey: .type)
        case .documentation:
            try container.encode(SourceType.documentation, forKey: .type)
        }
    }
}

public struct CodeContext: Codable, Equatable {
    public var id: String
    public var source: CodeContextSource
    public var filePath: String
    public var fileName: String
    public var language: String
    public var content: String
    public var lineCount: Int
    public var imports: [String]
    public var classes: [String]
    public var functions: [String]
    public var comments: [String]
    public var metadata: [String: String]
    public var general: [String]?
    
    public init(
        id: String = "",
        source: CodeContextSource = .local,
        filePath: String = "",
        fileName: String = "",
        language: String = "",
        content: String = "",
        lineCount: Int = 0,
        imports: [String] = [],
        classes: [String] = [],
        functions: [String] = [],
        comments: [String] = [],
        metadata: [String: String] = [:],
        general: [String]? = nil
    ) {
        self.id = id
        self.source = source
        self.filePath = filePath
        self.fileName = fileName
        self.language = language
        self.content = content
        self.lineCount = lineCount
        self.imports = imports
        self.classes = classes
        self.functions = functions
        self.comments = comments
        self.metadata = metadata
        self.general = general
    }
}

public struct AIContextDatabase: Codable, Equatable {
    public var version: String
    public var generatedAt: String
    public var contexts: [CodeContext]
    public var patterns: [CodePattern]
    public var bestPractices: [BestPractice]
    public var statistics: ContextStatistics
    
    public init(
        version: String = "",
        generatedAt: String = "",
        contexts: [CodeContext] = [],
        patterns: [CodePattern] = [],
        bestPractices: [BestPractice] = [],
        statistics: ContextStatistics = ContextStatistics()
    ) {
        self.version = version
        self.generatedAt = generatedAt
        self.contexts = contexts
        self.patterns = patterns
        self.bestPractices = bestPractices
        self.statistics = statistics
    }
}

public struct AIContextConfig: Codable, Equatable {
    public var includeGitHubRepos: Bool
    public var includeLocalFiles: Bool
    public var includeDocumentation: Bool
    public var maxLocalFiles: Int
    public var maxDocTopics: Int
    
    public init(
        includeGitHubRepos: Bool,
        includeLocalFiles: Bool,
        includeDocumentation: Bool,
        maxLocalFiles: Int,
        maxDocTopics: Int
    ) {
        self.includeGitHubRepos = includeGitHubRepos
        self.includeLocalFiles = includeLocalFiles
        self.includeDocumentation = includeDocumentation
        self.maxLocalFiles = maxLocalFiles
        self.maxDocTopics = maxDocTopics
    }
    
    public static func load() -> AIContextConfig {
        return AIContextConfig(
            includeGitHubRepos: false,
            includeLocalFiles: true,
            includeDocumentation: true,
            maxLocalFiles: 200,
            maxDocTopics: 50
        )
    }
}

public struct AIPromptTemplates: Codable, Equatable {
    public var systemPrompt: String
    public var codeGenerationPrompt: String
    public var codeReviewPrompt: String
    public var architecturePrompt: String
    
    public init(
        systemPrompt: String = "",
        codeGenerationPrompt: String = "",
        codeReviewPrompt: String = "",
        architecturePrompt: String = ""
    ) {
        self.systemPrompt = systemPrompt
        self.codeGenerationPrompt = codeGenerationPrompt
        self.codeReviewPrompt = codeReviewPrompt
        self.architecturePrompt = architecturePrompt
    }
}

// MARK: - Documentation Database and Nested Types

public struct AIContextDocumentationDatabase: Codable, Equatable {
    public struct Topic: Codable, Equatable {
        public var id: String
        public var title: String
        public var abstract: String
        public var sections: [Section]
        public var codeExamples: [CodeExample]
        public var url: String
        public var category: String
        public var platforms: [String]
        
        public init(
            id: String = "",
            title: String = "",
            abstract: String = "",
            sections: [Section] = [],
            codeExamples: [CodeExample] = [],
            url: String = "",
            category: String = "",
            platforms: [String] = []
        ) {
            self.id = id
            self.title = title
            self.abstract = abstract
            self.sections = sections
            self.codeExamples = codeExamples
            self.url = url
            self.category = category
            self.platforms = platforms
        }
    }
    
    public struct Section: Codable, Equatable {
        public var heading: String
        public var content: [Content]
        
        public init(heading: String = "", content: [Content] = []) {
            self.heading = heading
            self.content = content
        }
    }
    
    public struct Content: Codable, Equatable {
        public var text: String?
        
        public init(text: String? = nil) {
            self.text = text
        }
    }
    
    public struct CodeExample: Codable, Equatable {
        public var title: String
        public var language: String
        public var code: String
        
        public init(title: String = "", language: String = "", code: String = "") {
            self.title = title
            self.language = language
            self.code = code
        }
    }
    
    public var topics: [Topic]
    
    public init(topics: [Topic] = []) {
        self.topics = topics
    }
}

public typealias AIContextDocsDB = AIContextDocumentationDatabase

// MARK: - Helper Functions

public func loadPersistedContext() {
    // no-op stub
}

public func saveContext(_ db: AIContextDatabase) async {
    // no-op stub
}

public func loadDocumentationDatabase() -> AIContextDocsDB? {
    return nil
}

public func detectLanguage(from fileName: String) -> String {
    let lowercased = fileName.lowercased()
    if lowercased.hasSuffix(".swift") {
        return "Swift"
    } else if lowercased.hasSuffix(".md") {
        return "Markdown"
    } else if lowercased.hasSuffix(".m") || lowercased.hasSuffix(".mm") {
        return "Objective-C"
    } else if lowercased.hasSuffix(".h") {
        return "C"
    } else if lowercased.hasSuffix(".c") || lowercased.hasSuffix(".cpp") || lowercased.hasSuffix(".cc") {
        return "C++"
    } else if lowercased.hasSuffix(".py") {
        return "Python"
    } else if lowercased.hasSuffix(".js") {
        return "JavaScript"
    } else {
        return "Unknown"
    }
}

public func savePrompts(_ prompts: AIPromptTemplates) async {
    // no-op stub
}

public func generateCodeReviewPrompt(from db: AIContextDatabase) -> String {
    return "Code Review Prompt"
}

public func generateArchitecturePrompt(from db: AIContextDatabase) -> String {
    return "Architecture Prompt"
}

