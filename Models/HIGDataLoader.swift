//
//  HIGDataLoader.swift
//  HIG
//
//  Loads HIG content from bundled JSON
//

import Foundation
import Combine

@MainActor
class HIGDataLoader: ObservableObject {
    @Published var database: HIGDatabase?
    @Published var categories: [HIGCategory] = []
    @Published var isLoading = false
    @Published var error: String?
    
    static let shared = HIGDataLoader()
    
    private init() {}
    
    /// Check if running in preview mode
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func load() {
        guard database == nil else { return }
        isLoading = true
        error = nil
        
        Task {
            do {
                let db = try await loadFromBundle()
                self.database = db
                self.categories = buildCategories(from: db)
                self.isLoading = false
            } catch {
                // In preview mode, fail silently with empty data
                if isPreview {
                    self.categories = []
                    self.isLoading = false
                } else {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadFromBundle() async throws -> HIGDatabase {
        // Try to load from the docc bundle first
        let possiblePaths = [
            "HIGDocumentation.docc/hig_combined",
            "hig_combined"
        ]
        
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(HIGDatabase.self, from: data)
            }
        }
        
        // Try loading from Resources directory during development
        let resourcesPath = Bundle.main.bundlePath + "/Contents/Resources/HIGDocumentation.docc/hig_combined.json"
        if FileManager.default.fileExists(atPath: resourcesPath) {
            let data = try Data(contentsOf: URL(fileURLWithPath: resourcesPath))
            return try JSONDecoder().decode(HIGDatabase.self, from: data)
        }
        
        throw HIGError.dataNotFound
    }
    
    private func buildCategories(from db: HIGDatabase) -> [HIGCategory] {
        var result: [HIGCategory] = []
        
        let categoryOrder = ["Foundations", "Patterns", "Inputs", "Technologies", "Components"]
        
        for catName in categoryOrder {
            guard let topicIds = db.categories[catName] else { continue }
            
            let topics = db.topics.filter { topicIds.contains($0.id) }
            let icon = HIGCategory.icons[catName] ?? "folder"
            
            result.append(HIGCategory(name: catName, topics: topics, icon: icon))
        }
        
        return result
    }
    
    func topic(byId id: String) -> HIGTopic? {
        database?.topics.first { $0.id == id }
    }
    
    func search(_ query: String) -> [HIGTopic] {
        guard let db = database, !query.isEmpty else { return [] }
        
        let lowercased = query.lowercased()
        return db.topics.filter { topic in
            topic.title.lowercased().contains(lowercased) ||
            topic.abstract.lowercased().contains(lowercased) ||
            topic.category.lowercased().contains(lowercased)
        }
    }
}

enum HIGError: LocalizedError {
    case dataNotFound
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "HIG data file not found. Make sure hig_combined.json is included in the bundle."
        }
    }
}
