//
//  URLProcessor.swift
//  HIG
//
//  Processes URLs to extract documentation, create blueprints, and generate resources
//

import Foundation
import SwiftUI

// MARK: - URL Processing Result

struct URLProcessingResult {
    var url: String
    var type: ContentType
    var title: String
    var description: String
    var documentation: ExtractedDocumentation?
    var blueprint: ProjectBlueprint?
    var package: PackageDefinition?
    var learningResources: [URLLearningResource]
    var crossReferences: [CrossReference]
    var platformDesigns: [PlatformDesign]
    var contextItems: [ContextGridItem]
    var metadata: [String: String]
    
    enum ContentType: String {
        case documentation
        case tutorial
        case api
        case library
        case framework
        case example
        case blog
        case video
        case course
        case repository
    }
}

// MARK: - Extracted Documentation

struct ExtractedDocumentation: Codable {
    var sections: [DocSection]
    var codeExamples: [CodeExample]
    var apiReference: [APIEndpoint]
    var concepts: [Concept]
    var bestPractices: [String]
    var commonPatterns: [Pattern]
    
    struct DocSection: Codable, Identifiable {
        let id = UUID()
        var title: String
        var content: String
        var level: Int
        var subsections: [DocSection]
    }
    
    struct CodeExample: Codable, Identifiable {
        let id = UUID()
        var title: String
        var code: String
        var language: String
        var description: String
        var tags: [String]
    }
    
    struct APIEndpoint: Codable, Identifiable {
        let id = UUID()
        var name: String
        var method: String
        var path: String
        var parameters: [Parameter]
        var response: String
        var description: String
        
        struct Parameter: Codable {
            var name: String
            var type: String
            var required: Bool
            var description: String
        }
    }
    
    struct Concept: Codable, Identifiable {
        let id = UUID()
        var name: String
        var description: String
        var examples: [String]
        var relatedConcepts: [String]
    }
    
    struct Pattern: Codable, Identifiable {
        let id = UUID()
        var name: String
        var description: String
        var useCase: String
        var implementation: String
    }
}

// MARK: - Project Blueprint

struct ProjectBlueprint: Codable {
    var name: String
    var description: String
    var architecture: Architecture
    var structure: FileStructure
    var dependencies: [Dependency]
    var features: [Feature]
    var platforms: [Platform]
    var estimatedTime: String
    
    enum Architecture: String, Codable {
        case mvc, mvvm, viper, clean, modular
    }
    
    struct FileStructure: Codable {
        var folders: [Folder]
        var files: [File]
        
        struct Folder: Codable, Identifiable {
            let id = UUID()
            var name: String
            var path: String
            var purpose: String
            var subfolders: [Folder]
        }
        
        struct File: Codable, Identifiable {
            let id = UUID()
            var name: String
            var path: String
            var type: String
            var template: String?
        }
    }
    
    struct Dependency: Codable, Identifiable {
        let id = UUID()
        var name: String
        var version: String
        var purpose: String
        var platform: String
    }
    
    struct Feature: Codable, Identifiable {
        let id = UUID()
        var name: String
        var description: String
        var priority: Priority
        var estimatedHours: Int
        var dependencies: [String]
        
        enum Priority: String, Codable {
            case must, should, could, wont
        }
    }
    
    enum Platform: String, Codable {
        case ios, macos, watchos, tvos, visionos, web, android
    }
}

// MARK: - Package Definition

struct PackageDefinition: Codable {
    var name: String
    var description: String
    var version: String
    var platforms: [String]
    var dependencies: [String]
    var targets: [Target]
    var swiftVersion: String
    
    struct Target: Codable {
        var name: String
        var type: TargetType
        var dependencies: [String]
        var path: String
        
        enum TargetType: String, Codable {
            case library, executable, test
        }
    }
    
    func generatePackageSwift() -> String {
        """
        // swift-tools-version: \(swiftVersion)
        import PackageDescription
        
        let package = Package(
            name: "\(name)",
            platforms: [
                \(platforms.map { ".\($0)" }.joined(separator: ", "))
            ],
            products: [
                .library(name: "\(name)", targets: ["\(name)"])
            ],
            dependencies: [
                \(dependencies.map { ".package(url: \"\($0)\", from: \"1.0.0\")" }.joined(separator: ",\n        "))
            ],
            targets: [
                \(targets.map { generateTarget($0) }.joined(separator: ",\n        "))
            ]
        )
        """
    }
    
    private func generateTarget(_ target: Target) -> String {
        """
        .\(target.type.rawValue)(
            name: "\(target.name)",
            dependencies: [\(target.dependencies.map { "\"\($0)\"" }.joined(separator: ", "))]
        )
        """
    }
}

// MARK: - Learning Resource

struct URLLearningResource: Codable, Identifiable {
    let id = UUID()
    var title: String
    var type: ResourceType
    var url: String
    var description: String
    var difficulty: Difficulty
    var duration: String
    var topics: [String]
    var prerequisites: [String]
    
    enum ResourceType: String, Codable {
        case tutorial, video, article, course, documentation, example, book
    }
    
    enum Difficulty: String, Codable {
        case beginner, intermediate, advanced, expert
    }
}

// MARK: - Cross Reference

struct CrossReference: Codable, Identifiable {
    let id = UUID()
    var sourceURL: String
    var targetURL: String
    var relationship: Relationship
    var description: String
    var relevance: Double
    
    enum Relationship: String, Codable {
        case implements, extends, uses, relatedTo, alternativeTo, prerequisiteFor
    }
}

// MARK: - Platform Design

struct PlatformDesign: Codable, Identifiable {
    let id = UUID()
    var platform: String
    var components: [Component]
    var layouts: [Layout]
    var interactions: [Interaction]
    var adaptations: [String]
    
    struct Component: Codable, Identifiable {
        let id = UUID()
        var name: String
        var type: String
        var properties: [String: String]
        var styling: [String: String]
    }
    
    struct Layout: Codable, Identifiable {
        let id = UUID()
        var name: String
        var type: String
        var constraints: [String]
        var responsive: Bool
    }
    
    struct Interaction: Codable, Identifiable {
        let id = UUID()
        var trigger: String
        var action: String
        var feedback: String
    }
}

// MARK: - Context Grid Item

struct ContextGridItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var subtitle: String
    var icon: String
    var color: String
    var type: ItemType
    var content: String
    var action: String?
    var metadata: [String: String]
    
    enum ItemType: String, Codable {
        case documentation
        case codeExample
        case blueprint
        case package
        case tutorial
        case concept
        case pattern
        case api
        case design
        case resource
        case reference
        case note
        case task
        case suggestion
    }
}

// MARK: - URL Processor

@MainActor
class URLProcessor {
    static let shared = URLProcessor()
    
    private let knowledgeBase = UserKnowledgeBase.shared
    private let documentationImporter = DocumentationImporter()
    private var processedURLs: [String: ProcessedURLMetadata] = [:]
    private var updateCheckTimer: Timer?
    
    struct ProcessedURLMetadata: Codable {
        var url: String
        var lastProcessed: Date
        var lastChecked: Date
        var contentHash: String
        var autoUpdate: Bool
        var checkInterval: TimeInterval // in seconds
    }
    
    init() {
        loadProcessedURLs()
        startAutoUpdateChecker()
    }
    
    func process(url: String) async -> URLProcessingResult {
        // Validate URL
        guard let validURL = URL(string: url) else {
            return createErrorResult(url: url, error: "Invalid URL")
        }
        
        // Determine content type
        let contentType = detectContentType(url: validURL)
        
        // Extract content
        let html = await fetchHTML(from: validURL)
        
        // Process based on type
        var result = URLProcessingResult(
            url: url,
            type: contentType,
            title: extractTitle(from: html),
            description: extractDescription(from: html),
            documentation: Optional<ExtractedDocumentation>.none,
            blueprint: Optional<ProjectBlueprint>.none,
            package: Optional<PackageDefinition>.none,
            learningResources: [],
            crossReferences: [],
            platformDesigns: [],
            contextItems: [],
            metadata: [:]
        )
        
        // Extract documentation
        result.documentation = await extractDocumentation(from: html, url: validURL)
        
        // Generate blueprint if applicable
        if shouldGenerateBlueprint(for: contentType) {
            result.blueprint = await generateBlueprint(from: result.documentation, url: validURL)
        }
        
        // Generate package if applicable
        if shouldGeneratePackage(for: contentType) {
            result.package = await generatePackage(from: result.blueprint, url: validURL)
        }
        
        // Extract learning resources
        result.learningResources = await extractLearningResources(from: html, url: validURL)
        
        // Find cross references
        result.crossReferences = await findCrossReferences(for: url, in: html)
        
        // Generate platform designs
        result.platformDesigns = await generatePlatformDesigns(from: result.documentation)
        
        // Create context grid items (up to 14)
        result.contextItems = createContextGridItems(from: result)
        
        // Save to knowledge base
        await saveToKnowledgeBase(result)
        
        // Track processed URL
        let contentHash = html.hashValue.description
        processedURLs[url] = ProcessedURLMetadata(
            url: url,
            lastProcessed: Date(),
            lastChecked: Date(),
            contentHash: contentHash,
            autoUpdate: true, // Enable auto-update by default
            checkInterval: 86400 // Check daily
        )
        saveProcessedURLs()
        
        return result
    }
    
    // MARK: - Content Type Detection
    
    private func detectContentType(url: URL) -> URLProcessingResult.ContentType {
        let urlString = url.absoluteString.lowercased()
        let host = url.host?.lowercased() ?? ""
        
        if host.contains("github.com") {
            return .repository
        } else if host.contains("youtube.com") || host.contains("vimeo.com") {
            return .video
        } else if urlString.contains("/api/") || urlString.contains("/reference/") {
            return .api
        } else if urlString.contains("/tutorial") || urlString.contains("/guide") {
            return .tutorial
        } else if urlString.contains("/docs") || urlString.contains("/documentation") {
            return .documentation
        } else if urlString.contains("/example") {
            return .example
        } else if host.contains("medium.com") || host.contains("dev.to") {
            return .blog
        } else if urlString.contains("/course") {
            return .course
        } else if urlString.contains("/framework") || urlString.contains("/library") {
            return .library
        }
        
        return .documentation
    }
    
    // MARK: - HTML Fetching
    
    private func fetchHTML(from url: URL) async -> String {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Failed to fetch URL: \(error)")
            return ""
        }
    }
    
    // MARK: - Content Extraction
    
    private func extractTitle(from html: String) -> String {
        // Extract title from HTML
        if let titleRange = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
            let title = String(html[titleRange])
                .replacingOccurrences(of: "<title>", with: "")
                .replacingOccurrences(of: "</title>", with: "")
            return title
        }
        return "Untitled"
    }
    
    private func extractDescription(from html: String) -> String {
        // Extract meta description
        if let descRange = html.range(of: "<meta name=\"description\" content=\"(.*?)\"", options: .regularExpression) {
            let desc = String(html[descRange])
            // Parse content attribute
            return desc
        }
        return ""
    }
    
    private func extractDocumentation(from html: String, url: URL) async -> ExtractedDocumentation {
        var sections: [ExtractedDocumentation.DocSection] = []
        var codeExamples: [ExtractedDocumentation.CodeExample] = []
        var apiReference: [ExtractedDocumentation.APIEndpoint] = []
        var concepts: [ExtractedDocumentation.Concept] = []
        var bestPractices: [String] = []
        var commonPatterns: [ExtractedDocumentation.Pattern] = []
        
        // Extract sections (h1, h2, h3, etc.)
        sections = extractSections(from: html)
        
        // Extract code examples
        codeExamples = extractCodeExamples(from: html)
        
        // Extract API endpoints if applicable
        apiReference = extractAPIEndpoints(from: html)
        
        // Extract concepts
        concepts = extractConcepts(from: html)
        
        // Extract best practices
        bestPractices = extractBestPractices(from: html)
        
        // Extract patterns
        commonPatterns = extractPatterns(from: html)
        
        return ExtractedDocumentation(
            sections: sections,
            codeExamples: codeExamples,
            apiReference: apiReference,
            concepts: concepts,
            bestPractices: bestPractices,
            commonPatterns: commonPatterns
        )
    }
    
    private func extractSections(from html: String) -> [ExtractedDocumentation.DocSection] {
        // Would parse HTML and extract sections
        return []
    }
    
    private func extractCodeExamples(from html: String) -> [ExtractedDocumentation.CodeExample] {
        // Would extract code blocks
        return []
    }
    
    private func extractAPIEndpoints(from html: String) -> [ExtractedDocumentation.APIEndpoint] {
        // Would extract API documentation
        return []
    }
    
    private func extractConcepts(from html: String) -> [ExtractedDocumentation.Concept] {
        // Would extract key concepts
        return []
    }
    
    private func extractBestPractices(from html: String) -> [String] {
        // Would extract best practices
        return []
    }
    
    private func extractPatterns(from html: String) -> [ExtractedDocumentation.Pattern] {
        // Would extract common patterns
        return []
    }
    
    // MARK: - Blueprint Generation
    
    private func shouldGenerateBlueprint(for type: URLProcessingResult.ContentType) -> Bool {
        [.tutorial, .example, .repository, .library, .framework].contains(type)
    }
    
    private func generateBlueprint(from documentation: ExtractedDocumentation?, url: URL) async -> ProjectBlueprint {
        // Analyze documentation and generate project blueprint
        let name = url.lastPathComponent.replacingOccurrences(of: "-", with: " ").capitalized
        
        return ProjectBlueprint(
            name: name,
            description: "Generated from \(url.absoluteString)",
            architecture: .mvvm,
            structure: generateFileStructure(for: name),
            dependencies: extractDependencies(from: documentation),
            features: extractFeatures(from: documentation),
            platforms: [.ios, .macos],
            estimatedTime: "2-3 weeks"
        )
    }
    
    private func generateFileStructure(for projectName: String) -> ProjectBlueprint.FileStructure {
        // Generate standard project structure
        return ProjectBlueprint.FileStructure(
            folders: [
                ProjectBlueprint.FileStructure.Folder(
                    name: "Sources",
                    path: "Sources/\(projectName)",
                    purpose: "Main source code",
                    subfolders: [
                        ProjectBlueprint.FileStructure.Folder(name: "Models", path: "Sources/\(projectName)/Models", purpose: "Data models", subfolders: []),
                        ProjectBlueprint.FileStructure.Folder(name: "Views", path: "Sources/\(projectName)/Views", purpose: "UI views", subfolders: []),
                        ProjectBlueprint.FileStructure.Folder(name: "ViewModels", path: "Sources/\(projectName)/ViewModels", purpose: "View models", subfolders: []),
                        ProjectBlueprint.FileStructure.Folder(name: "Services", path: "Sources/\(projectName)/Services", purpose: "Business logic", subfolders: [])
                    ]
                ),
                ProjectBlueprint.FileStructure.Folder(name: "Tests", path: "Tests/\(projectName)Tests", purpose: "Unit tests", subfolders: [])
            ],
            files: []
        )
    }
    
    private func extractDependencies(from documentation: ExtractedDocumentation?) -> [ProjectBlueprint.Dependency] {
        // Extract dependencies from documentation
        return []
    }
    
    private func extractFeatures(from documentation: ExtractedDocumentation?) -> [ProjectBlueprint.Feature] {
        // Extract features from documentation
        return []
    }
    
    // MARK: - Package Generation
    
    private func shouldGeneratePackage(for type: URLProcessingResult.ContentType) -> Bool {
        [.library, .framework, .repository].contains(type)
    }
    
    private func generatePackage(from blueprint: ProjectBlueprint?, url: URL) async -> PackageDefinition {
        guard let blueprint = blueprint else {
            return PackageDefinition(
                name: "Package",
                description: "",
                version: "1.0.0",
                platforms: [],
                dependencies: [],
                targets: [],
                swiftVersion: "5.9"
            )
        }
        
        return PackageDefinition(
            name: blueprint.name,
            description: blueprint.description,
            version: "1.0.0",
            platforms: blueprint.platforms.map { $0.rawValue },
            dependencies: blueprint.dependencies.map { $0.name },
            targets: [
                PackageDefinition.Target(
                    name: blueprint.name,
                    type: .library,
                    dependencies: [],
                    path: "Sources"
                ),
                PackageDefinition.Target(
                    name: "\(blueprint.name)Tests",
                    type: .test,
                    dependencies: [blueprint.name],
                    path: "Tests"
                )
            ],
            swiftVersion: "5.9"
        )
    }
    
    // MARK: - Learning Resources
    
    private func extractLearningResources(from html: String, url: URL) async -> [URLLearningResource] {
        // Extract related learning resources
        return []
    }
    
    // MARK: - Cross References
    
    private func findCrossReferences(for url: String, in html: String) async -> [CrossReference] {
        // Find related URLs and create cross-references
        return []
    }
    
    // MARK: - Platform Designs
    
    private func generatePlatformDesigns(from documentation: ExtractedDocumentation?) async -> [PlatformDesign] {
        // Generate platform-specific designs
        return []
    }
    
    // MARK: - Context Grid Items
    
    private func createContextGridItems(from result: URLProcessingResult) -> [ContextGridItem] {
        var items: [ContextGridItem] = []
        
        // 1. Main documentation
        items.append(ContextGridItem(
            title: result.title,
            subtitle: "Documentation",
            icon: "doc.text",
            color: "blue",
            type: .documentation,
            content: result.description,
            action: "view_docs",
            metadata: [:]
        ))
        
        // 2-4. Code examples (up to 3)
        if let docs = result.documentation {
            for example in docs.codeExamples.prefix(3) {
                items.append(ContextGridItem(
                    title: example.title,
                    subtitle: "Code Example",
                    icon: "chevron.left.forwardslash.chevron.right",
                    color: "purple",
                    type: .codeExample,
                    content: example.code,
                    action: "copy_code",
                    metadata: [:]
                ))
            }
        }
        
        // 5. Blueprint
        if let blueprint = result.blueprint {
            items.append(ContextGridItem(
                title: blueprint.name,
                subtitle: "Project Blueprint",
                icon: "square.grid.3x3",
                color: "indigo",
                type: .blueprint,
                content: blueprint.description,
                action: "generate_project",
                metadata: [:]
            ))
        }
        
        // 6. Package
        if let package = result.package {
            items.append(ContextGridItem(
                title: package.name,
                subtitle: "Swift Package",
                icon: "shippingbox",
                color: "orange",
                type: .package,
                content: package.description,
                action: "create_package",
                metadata: [:]
            ))
        }
        
        // 7-9. Learning resources (up to 3)
        for resource in result.learningResources.prefix(3) {
            items.append(ContextGridItem(
                title: resource.title,
                subtitle: resource.type.rawValue.capitalized,
                icon: "book",
                color: "green",
                type: .tutorial,
                content: resource.description,
                action: "open_resource",
                metadata: [:]
            ))
        }
        
        // 10-12. Platform designs (up to 3)
        for design in result.platformDesigns.prefix(3) {
            items.append(ContextGridItem(
                title: "\(design.platform) Design",
                subtitle: "Platform Adaptation",
                icon: "iphone",
                color: "pink",
                type: .design,
                content: "\(design.components.count) components",
                action: "view_design",
                metadata: [:]
            ))
        }
        
        // 13-14. Cross references (up to 2)
        for reference in result.crossReferences.prefix(2) {
            items.append(ContextGridItem(
                title: "Related: \(reference.targetURL)",
                subtitle: reference.relationship.rawValue,
                icon: "link",
                color: "cyan",
                type: .reference,
                content: reference.description,
                action: "open_reference",
                metadata: [:]
            ))
        }
        
        // Return up to 14 items
        return Array(items.prefix(14))
    }
    
    // MARK: - Save to Knowledge Base
    
    private func saveToKnowledgeBase(_ result: URLProcessingResult) async {
        // Convert to HIG-style documentation structure
        let importedDoc = convertToImportedDocumentation(result)
        
        // Add to importer's list (it will auto-save)
        if !documentationImporter.importedDocs.contains(where: { $0.id == importedDoc.id }) {
            documentationImporter.importedDocs.append(importedDoc)
        }
        
        // Also save individual components to knowledge base
        
        // 1. Save main documentation as note
        let note = Note(
            title: result.title,
            content: result.description,
            tags: [result.type.rawValue, "url-processed", "documentation"],
            category: "Documentation"
        )
        knowledgeBase.add(note)
        
        // 2. Save code examples
        if let docs = result.documentation {
            for example in docs.codeExamples {
                let exampleNote = Note(
                    title: example.title,
                    content: "```\(example.language)\n\(example.code)\n```\n\n\(example.description)",
                    tags: example.tags + ["code-example", result.title],
                    category: "Code Examples"
                )
                knowledgeBase.add(exampleNote)
            }
            
            // 3. Save concepts
            for concept in docs.concepts {
                let conceptNote = Note(
                    title: concept.name,
                    content: concept.description,
                    tags: ["concept", result.title] + concept.relatedConcepts,
                    category: "Concepts"
                )
                knowledgeBase.add(conceptNote)
            }
            
            // 4. Save patterns
            for pattern in docs.commonPatterns {
                let patternNote = Note(
                    title: pattern.name,
                    content: "**Use Case:** \(pattern.useCase)\n\n**Description:** \(pattern.description)\n\n**Implementation:**\n```\n\(pattern.implementation)\n```",
                    tags: ["pattern", result.title],
                    category: "Patterns"
                )
                knowledgeBase.add(patternNote)
            }
        }
        
        // 5. Save blueprint as project idea
        if let blueprint = result.blueprint {
            let idea = Idea(
                title: blueprint.name,
                content: blueprint.description,
                tags: ["blueprint", "generated", result.title],
                category: "Projects"
            )
            knowledgeBase.add(idea)
        }
        
        // 6. Save learning resources
        for resource in result.learningResources {
            let resourceNote = Note(
                title: resource.title,
                content: "\(resource.description)\n\n**Type:** \(resource.type.rawValue)\n**Difficulty:** \(resource.difficulty.rawValue)\n**Duration:** \(resource.duration)\n**URL:** \(resource.url)",
                tags: resource.topics + ["learning-resource", result.title],
                category: "Learning"
            )
            knowledgeBase.add(resourceNote)
        }
    }
    
    // MARK: - Convert to HIG-Style Documentation
    
    private func convertToImportedDocumentation(_ result: URLProcessingResult) -> ImportedDocumentation {
        var pages: [ImportedDocumentation.ImportedPage] = []
        
        // Create main page
        let mainPage = ImportedDocumentation.ImportedPage(
            id: UUID(),
            url: result.url,
            title: result.title,
            content: result.description,
            abstract: result.description.prefix(200).description,
            sections: [],
            category: result.type.rawValue,
            subcategory: nil,
            metadata: ImportedDocumentation.ImportedPage.PageMetadata(
                author: nil,
                lastModified: Date(),
                tags: [result.type.rawValue],
                depth: 0
            )
        )
        pages.append(mainPage)
        
        // Create pages from documentation sections
        if let docs = result.documentation {
            for (index, section) in docs.sections.enumerated() {
                // Convert section content to content blocks
                let contentBlocks = [
                    ImportedDocumentation.ImportedPage.Section.ContentBlock(
                        type: .text,
                        text: section.content,
                        code: nil,
                        language: nil
                    )
                ]
                
                let sectionObj = ImportedDocumentation.ImportedPage.Section(
                    id: UUID(),
                    heading: section.title,
                    content: contentBlocks
                )
                
                let sectionPage = ImportedDocumentation.ImportedPage(
                    id: UUID(),
                    url: "\(result.url)#\(section.title.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    title: section.title,
                    content: section.content,
                    abstract: section.content.prefix(200).description,
                    sections: [sectionObj],
                    category: result.type.rawValue,
                    subcategory: "Section",
                    metadata: ImportedDocumentation.ImportedPage.PageMetadata(
                        author: nil,
                        lastModified: Date(),
                        tags: [result.type.rawValue, "section"],
                        depth: section.level
                    )
                )
                pages.append(sectionPage)
            }
            
            // Create pages from code examples
            for example in docs.codeExamples {
                let codeBlock = ImportedDocumentation.ImportedPage.Section.ContentBlock(
                    type: .code,
                    text: example.description,
                    code: example.code,
                    language: example.language
                )
                
                let section = ImportedDocumentation.ImportedPage.Section(
                    id: UUID(),
                    heading: example.title,
                    content: [codeBlock]
                )
                
                let examplePage = ImportedDocumentation.ImportedPage(
                    id: UUID(),
                    url: "\(result.url)#example-\(example.title.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    title: example.title,
                    content: example.code,
                    abstract: example.description,
                    sections: [section],
                    category: "Examples",
                    subcategory: example.language,
                    metadata: ImportedDocumentation.ImportedPage.PageMetadata(
                        author: nil,
                        lastModified: Date(),
                        tags: example.tags + ["code-example"],
                        depth: 1
                    )
                )
                pages.append(examplePage)
            }
            
            // Create pages from concepts
            for concept in docs.concepts {
                let contentBlock = ImportedDocumentation.ImportedPage.Section.ContentBlock(
                    type: .text,
                    text: concept.description,
                    code: nil,
                    language: nil
                )
                
                let section = ImportedDocumentation.ImportedPage.Section(
                    id: UUID(),
                    heading: concept.name,
                    content: [contentBlock]
                )
                
                let conceptPage = ImportedDocumentation.ImportedPage(
                    id: UUID(),
                    url: "\(result.url)#concept-\(concept.name.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    title: concept.name,
                    content: concept.description,
                    abstract: concept.description.prefix(200).description,
                    sections: [section],
                    category: "Concepts",
                    subcategory: nil,
                    metadata: ImportedDocumentation.ImportedPage.PageMetadata(
                        author: nil,
                        lastModified: Date(),
                        tags: concept.relatedConcepts + ["concept"],
                        depth: 1
                    )
                )
                pages.append(conceptPage)
            }
        }
        
        // Extract categories from all pages
        let categories = Array(Set(pages.map { $0.category }))
        
        return ImportedDocumentation(
            id: UUID(),
            name: result.title,
            sourceURL: result.url,
            importDate: Date(),
            pages: pages,
            categories: categories
        )
    }
    
    // MARK: - Error Handling
    
    private func createErrorResult(url: String, error: String) -> URLProcessingResult {
        return URLProcessingResult(
            url: url,
            type: .documentation,
            title: "Error",
            description: error,
            documentation: Optional<ExtractedDocumentation>.none,
            blueprint: Optional<ProjectBlueprint>.none,
            package: Optional<PackageDefinition>.none,
            learningResources: [],
            crossReferences: [],
            platformDesigns: [],
            contextItems: [],
            metadata: ["error": error]
        )
    }
    
    // MARK: - Auto-Update System
    
    func enableAutoUpdate(for url: String, interval: TimeInterval = 86400) { // Default: 24 hours
        if var metadata = processedURLs[url] {
            metadata.autoUpdate = true
            metadata.checkInterval = interval
            processedURLs[url] = metadata
            saveProcessedURLs()
        }
    }
    
    func disableAutoUpdate(for url: String) {
        if var metadata = processedURLs[url] {
            metadata.autoUpdate = false
            processedURLs[url] = metadata
            saveProcessedURLs()
        }
    }
    
    private func startAutoUpdateChecker() {
        // Check for updates every hour
        updateCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkForUpdates()
            }
        }
    }
    
    private func checkForUpdates() async {
        let now = Date()
        
        for (url, metadata) in processedURLs where metadata.autoUpdate {
            // Check if it's time to update
            let timeSinceLastCheck = now.timeIntervalSince(metadata.lastChecked)
            if timeSinceLastCheck >= metadata.checkInterval {
                await checkAndUpdateURL(url, metadata: metadata)
            }
        }
    }
    
    private func checkAndUpdateURL(_ url: String, metadata: ProcessedURLMetadata) async {
        guard let validURL = URL(string: url) else { return }
        
        // Fetch current content
        let html = await fetchHTML(from: validURL)
        let currentHash = html.hashValue.description
        
        // Update last checked time
        var updatedMetadata = metadata
        updatedMetadata.lastChecked = Date()
        
        // Check if content changed
        if currentHash != metadata.contentHash {
            print("📡 Update detected for \(url)")
            
            // Re-process URL
            let result = await process(url: url)
            
            // Update metadata
            updatedMetadata.contentHash = currentHash
            updatedMetadata.lastProcessed = Date()
            
            // Notify user
            await notifyUserOfUpdate(url: url, result: result)
        }
        
        processedURLs[url] = updatedMetadata
        saveProcessedURLs()
    }
    
    private func notifyUserOfUpdate(url: String, result: URLProcessingResult) async {
        // Create notification
        let note = Note(
            title: "Documentation Updated: \(result.title)",
            content: "The documentation at \(url) has been updated with new content.",
            tags: ["update", "notification"],
            category: "Updates"
        )
        knowledgeBase.add(note)
        
        // Could also trigger a system notification here
    }
    
    // MARK: - Organization & Categorization
    
    func organizeDocumentation() async {
        // Get all imported documentation
        let allDocs = documentationImporter.importedDocs
        
        // Organize by category
        var categorized: [String: [ImportedDocumentation]] = [:]
        for doc in allDocs {
            for category in doc.categories {
                categorized[category, default: []].append(doc)
            }
        }
        
        // Create category notes
        for (category, docs) in categorized {
            let categoryNote = Note(
                title: "\(category) Documentation",
                content: "Collection of \(docs.count) documentation sources in \(category)",
                tags: ["category", category.lowercased()],
                category: "Documentation Categories"
            )
            knowledgeBase.add(categoryNote)
        }
    }
    
    func searchDocumentation(query: String) -> [ImportedDocumentation.ImportedPage] {
        var results: [ImportedDocumentation.ImportedPage] = []
        
        for doc in documentationImporter.importedDocs {
            let matchingPages = doc.pages.filter { page in
                page.title.localizedCaseInsensitiveContains(query) ||
                page.content.localizedCaseInsensitiveContains(query) ||
                page.category.localizedCaseInsensitiveContains(query)
            }
            results.append(contentsOf: matchingPages)
        }
        
        return results
    }
    
    func getDocumentationByCategory(_ category: String) -> [ImportedDocumentation] {
        return documentationImporter.importedDocs.filter { doc in
            doc.categories.contains { $0.localizedCaseInsensitiveContains(category) }
        }
    }
    
    func getRecentDocumentation(limit: Int = 10) -> [ImportedDocumentation] {
        return documentationImporter.importedDocs
            .sorted { $0.importDate > $1.importDate }
            .prefix(limit)
            .map { $0 }
    }
    
    func getUpdatedDocumentation(since date: Date) -> [ImportedDocumentation] {
        return documentationImporter.importedDocs.filter { $0.importDate > date }
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> DocumentationStatistics {
        let allDocs = documentationImporter.importedDocs
        let totalPages = allDocs.reduce(0) { $0 + $1.pages.count }
        let categories = Set(allDocs.flatMap { $0.categories })
        
        return DocumentationStatistics(
            totalSources: allDocs.count,
            totalPages: totalPages,
            totalCategories: categories.count,
            recentlyUpdated: getUpdatedDocumentation(since: Date().addingTimeInterval(-86400 * 7)).count,
            autoUpdateEnabled: processedURLs.values.filter(\.autoUpdate).count
        )
    }
    
    struct DocumentationStatistics {
        var totalSources: Int
        var totalPages: Int
        var totalCategories: Int
        var recentlyUpdated: Int
        var autoUpdateEnabled: Int
    }
    
    // MARK: - Persistence
    
    private func loadProcessedURLs() {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ProcessedURLs.json")
        
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: ProcessedURLMetadata].self, from: data) else {
            return
        }
        
        processedURLs = decoded
    }
    
    private func saveProcessedURLs() {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ProcessedURLs.json")
        
        guard let data = try? JSONEncoder().encode(processedURLs) else { return }
        try? data.write(to: url)
    }
}

