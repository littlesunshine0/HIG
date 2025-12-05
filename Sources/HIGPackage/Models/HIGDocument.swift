import Foundation

public struct HIGDocument: Codable, Equatable {
    public let version: String
    public let generatedAt: Date?
    public let source: String
    public let sourceUrl: URL
    public let categories: [String: [GuidelineTopic]]
    public let topics: [GuidelineTopic]
    public let topicCount: Int

    public init(
        version: String,
        generatedAt: Date?,
        source: String,
        sourceUrl: URL,
        categories: [String: [GuidelineTopic]],
        topics: [GuidelineTopic],
        topicCount: Int
    ) {
        self.version = version
        self.generatedAt = generatedAt
        self.source = source
        self.sourceUrl = sourceUrl
        self.categories = categories
        self.topics = topics
        self.topicCount = topicCount
    }
}

public struct GuidelineTopic: Codable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let category: String
    public let subcategory: String?
    public let url: URL
    public let fetchedAt: Date?
    public let abstract: String
    public let sections: [GuidelineSection]
    public let relatedTopics: [String]
    public let platforms: [String]

    public init(
        id: String,
        title: String,
        category: String,
        subcategory: String?,
        url: URL,
        fetchedAt: Date?,
        abstract: String,
        sections: [GuidelineSection],
        relatedTopics: [String],
        platforms: [String]
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.subcategory = subcategory
        self.url = url
        self.fetchedAt = fetchedAt
        self.abstract = abstract
        self.sections = sections
        self.relatedTopics = relatedTopics
        self.platforms = platforms
    }
}

public struct GuidelineSection: Codable, Equatable {
    public let heading: String
    public let text: String

    public init(heading: String, text: String) {
        self.heading = heading
        self.text = text
    }
}
