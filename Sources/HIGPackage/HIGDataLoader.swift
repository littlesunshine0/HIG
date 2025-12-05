import Foundation

public enum HIGDataLoader {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public static func load(from data: Data) throws -> HIGDocument {
        try decoder.decode(HIGDocument.self, from: data)
    }

    public static func load(from url: URL, fileManager: FileManager = .default) throws -> HIGDocument {
        let data = try Data(contentsOf: url)
        return try load(from: data)
    }

    public static func topics(for category: String, in document: HIGDocument) -> [GuidelineTopic] {
        if let topics = document.categories[category] {
            return topics
        }
        return document.topics.filter { $0.category.caseInsensitiveCompare(category) == .orderedSame }
    }

    public static func searchTopics(matching query: String, in document: HIGDocument) -> [GuidelineTopic] {
        guard !query.isEmpty else { return [] }
        let lowered = query.lowercased()
        return document.topics.filter { topic in
            topic.title.lowercased().contains(lowered)
                || topic.abstract.lowercased().contains(lowered)
                || topic.sections.contains { section in
                    section.heading.lowercased().contains(lowered) || section.text.lowercased().contains(lowered)
                }
        }
    }
}
