//
//  HIGModels.swift
//  HIG
//
//  Swift models for Apple Human Interface Guidelines content
//

import Foundation

// MARK: - Combined HIG Data

struct HIGDatabase: Codable {
    let version: String
    let generatedAt: String
    let source: String
    let sourceUrl: String
    let categories: [String: [String]]
    let topics: [HIGTopic]
    let topicCount: Int
}

// MARK: - Topic

struct HIGTopic: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let subcategory: String?
    let url: String
    let fetchedAt: String
    let abstract: String
    let sections: [HIGSection]
    let relatedTopics: [HIGRelatedTopic]
    let platforms: [String]
    
    var displayCategory: String {
        if let sub = subcategory {
            return "\(category) > \(sub)"
        }
        return category
    }
    
    // Hashable conformance (just use id)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HIGTopic, rhs: HIGTopic) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Section

struct HIGSection: Codable, Identifiable {
    let heading: String
    let level: Int
    let anchor: String?
    let content: [HIGContent]
    
    var id: String { anchor ?? heading }
}

// MARK: - Content Types

struct HIGContent: Codable {
    let type: String
    let text: String?
    let items: [String]?
    let syntax: String?
    let code: String?
    let style: String?
    let content: [String]?
}

// MARK: - Related Topic

struct HIGRelatedTopic: Codable, Identifiable {
    let title: String
    let url: String
    let section: String
    
    var id: String { url }
}

// MARK: - Category Info

struct HIGCategory: Identifiable, Hashable {
    let name: String
    let topics: [HIGTopic]
    let icon: String
    
    var id: String { name }
    
    static let icons: [String: String] = [
        "Foundations": "square.grid.2x2",
        "Patterns": "rectangle.3.group",
        "Inputs": "hand.tap",
        "Technologies": "cpu",
        "Components": "square.stack.3d.up"
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: HIGCategory, rhs: HIGCategory) -> Bool {
        lhs.name == rhs.name
    }
}
