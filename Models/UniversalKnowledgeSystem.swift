//
//  UniversalKnowledgeSystem.swift
//  HIG
//
//  Universal knowledge and productivity system
//  Chat-first interface for everything
//

import Foundation
import SwiftUI

// MARK: - Content Types

enum ContentType: String, Codable, CaseIterable {
    case documentation
    case code
    case note
    case task
    case event
    case contact
    case project
    case idea
    case file
    case folder
    
    var icon: String {
        switch self {
        case .documentation: return "doc.text"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .note: return "note.text"
        case .task: return "checkmark.circle"
        case .event: return "calendar"
        case .contact: return "person.circle"
        case .project: return "folder.badge.gearshape"
        case .idea: return "lightbulb"
        case .file: return "doc"
        case .folder: return "folder"
        }
    }
    
    var color: Color {
        switch self {
        case .documentation: return .blue
        case .code: return .purple
        case .note: return .orange
        case .task: return .green
        case .event: return .red
        case .contact: return .pink
        case .project: return .indigo
        case .idea: return .yellow
        case .file: return .gray
        case .folder: return .cyan
        }
    }
}

// MARK: - Searchable Protocol

protocol Searchable: Identifiable, Codable {
    var id: UUID { get }
    var title: String { get }
    var content: String { get }
    var type: ContentType { get }
    var tags: [String] { get }
    var lastModified: Date { get }
    var createdDate: Date { get }
    
    func relevanceScore(for query: String) -> Double
}

extension Searchable {
    func relevanceScore(for query: String) -> Double {
        let queryLower = query.lowercased()
        var score = 0.0
        
        // Title match (highest weight)
        if title.lowercased().contains(queryLower) {
            score += 10.0
        }
        
        // Content match
        if content.lowercased().contains(queryLower) {
            score += 5.0
        }
        
        // Tag match
        for tag in tags where tag.lowercased().contains(queryLower) {
            score += 3.0
        }
        
        // Recency bonus (newer = higher score)
        let daysSinceModified = Date().timeIntervalSince(lastModified) / 86400
        score += max(0, 5.0 - daysSinceModified * 0.1)
        
        return score
    }
}

// MARK: - User Knowledge Base

@MainActor
@Observable
class UserKnowledgeBase {
    static let shared = UserKnowledgeBase()
    
    var notes: [Note] = []
    var tasks: [UserTask] = []
    var events: [UserCalendarEvent] = []
    var contacts: [Contact] = []
    var projects: [Project] = []
    var ideas: [Idea] = []
    var fileReferences: [FileReference] = []
    var learningPatterns: LearningPatterns = LearningPatterns()
    var currentContext: UserContext = UserContext()
    
    private let storageURL: URL
    
    init() {
        // Create storage directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        storageURL = appSupport.appendingPathComponent("UserKnowledge", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        
        load()
    }
    
    // MARK: - Universal Search
    
    func search(query: String, types: [ContentType]? = nil, limit: Int = 20) -> [any Searchable] {
        var results: [any Searchable] = []
        
        let searchTypes = types ?? ContentType.allCases
        
        if searchTypes.contains(.note) {
            results.append(contentsOf: notes.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.task) {
            results.append(contentsOf: tasks.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.event) {
            results.append(contentsOf: events.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.contact) {
            results.append(contentsOf: contacts.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.project) {
            results.append(contentsOf: projects.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.idea) {
            results.append(contentsOf: ideas.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        if searchTypes.contains(.file) || searchTypes.contains(.folder) {
            results.append(contentsOf: fileReferences.filter { $0.relevanceScore(for: query) > 0 })
        }
        
        // Sort by relevance
        return results.sorted { $0.relevanceScore(for: query) > $1.relevanceScore(for: query) }.prefix(limit).map { $0 }
    }
    
    // MARK: - CRUD Operations
    
    func add(_ item: any Searchable) {
        switch item.type {
        case .note:
            if let note = item as? Note {
                notes.append(note)
                currentContext.addToWorkingMemory(.note(note))
            }
        case .task:
            if let task = item as? UserTask {
                tasks.append(task)
                currentContext.addToWorkingMemory(.task(task))
            }
        case .event:
            if let event = item as? UserCalendarEvent {
                events.append(event)
                currentContext.addToWorkingMemory(.event(event))
            }
        case .contact:
            if let contact = item as? Contact {
                contacts.append(contact)
            }
        case .project:
            if let project = item as? Project {
                projects.append(project)
                currentContext.currentProject = project
            }
        case .idea:
            if let idea = item as? Idea {
                ideas.append(idea)
            }
        case .file, .folder:
            if let fileRef = item as? FileReference {
                fileReferences.append(fileRef)
                currentContext.addRecentFile(fileRef)
            }
        default:
            break
        }
        
        save()
    }
    
    func update(_ item: any Searchable) {
        // Update the item in the appropriate array
        switch item.type {
        case .note:
            if let note = item as? Note, let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        case .task:
            if let task = item as? UserTask, let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
            }
        case .event:
            if let event = item as? UserCalendarEvent, let index = events.firstIndex(where: { $0.id == event.id }) {
                events[index] = event
            }
        case .contact:
            if let contact = item as? Contact, let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                contacts[index] = contact
            }
        case .project:
            if let project = item as? Project, let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = project
            }
        case .idea:
            if let idea = item as? Idea, let index = ideas.firstIndex(where: { $0.id == idea.id }) {
                ideas[index] = idea
            }
        case .file, .folder:
            if let fileRef = item as? FileReference, let index = fileReferences.firstIndex(where: { $0.id == fileRef.id }) {
                fileReferences[index] = fileRef
            }
        default:
            break
        }
        
        save()
    }
    
    func delete(_ item: any Searchable) {
        switch item.type {
        case .note:
            notes.removeAll { $0.id == item.id }
        case .task:
            tasks.removeAll { $0.id == item.id }
        case .event:
            events.removeAll { $0.id == item.id }
        case .contact:
            contacts.removeAll { $0.id == item.id }
        case .project:
            projects.removeAll { $0.id == item.id }
        case .idea:
            ideas.removeAll { $0.id == item.id }
        case .file, .folder:
            fileReferences.removeAll { $0.id == item.id }
        default:
            break
        }
        
        save()
    }
    
    // MARK: - Persistence
    
    private func save() {
        _Concurrency.Task {
            do {
                // Save each type to its own file
                        try saveJSON(notes, to: "notes.json")
                try saveJSON(tasks, to: "tasks.json")
                try saveJSON(events, to: "events.json")
                try saveJSON(contacts, to: "contacts.json")
                try saveJSON(projects, to: "projects.json")
                try saveJSON(ideas, to: "ideas.json")
                try saveJSON(fileReferences, to: "fileReferences.json")
                try saveJSON(learningPatterns, to: "learningPatterns.json")
                try saveJSON(currentContext, to: "currentContext.json")
            } catch {
                print("Failed to save: \(error)")
            }
        }
    }
    
    private func load() {
        notes = loadJSON("notes.json") as [Note]? ?? []
        tasks = loadJSON("tasks.json") as [UserTask]? ?? []
        events = loadJSON("events.json") as [UserCalendarEvent]? ?? []
        contacts = loadJSON("contacts.json") as [Contact]? ?? []
        projects = loadJSON("projects.json") as [Project]? ?? []
        ideas = loadJSON("ideas.json") as [Idea]? ?? []
        fileReferences = loadJSON("fileReferences.json") as [FileReference]? ?? []
        learningPatterns = loadJSON("learningPatterns.json") as LearningPatterns? ?? LearningPatterns()
        currentContext = loadJSON("currentContext.json") as UserContext? ?? UserContext()
    }
    
    private func saveJSON<T: Encodable>(_ value: T, to filename: String) throws {
        let url = storageURL.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(value)
        try data.write(to: url)
    }
    
    private func loadJSON<T: Decodable>(_ filename: String) -> T? {
        let url = storageURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Data Models

struct Note: Searchable {
    let id: UUID
    var title: String
    var content: String
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .note
    var category: String?
    var linkedItems: [UUID] // Links to other items
    
    init(title: String, content: String, tags: [String] = [], category: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.tags = tags
        self.lastModified = Date()
        self.createdDate = Date()
        self.category = category
        self.linkedItems = []
    }
}

struct UserTask: Searchable {
    let id: UUID
    var title: String
    var content: String
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .task
    var dueDate: Date?
    var priority: Priority
    var status: Status
    var projectId: UUID?
    
    enum Priority: String, Codable {
        case low, medium, high, urgent
    }
    
    enum Status: String, Codable {
        case todo, inProgress, done, cancelled
    }
    
    init(title: String, content: String = "", tags: [String] = [], dueDate: Date? = nil, priority: Priority = .medium) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.tags = tags
        self.lastModified = Date()
        self.createdDate = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.status = .todo
    }
}

struct UserCalendarEvent: Searchable {
    let id: UUID
    var title: String
    var content: String
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .event
    var startDate: Date
    var endDate: Date
    var location: String?
    var attendees: [UUID] // Contact IDs
    var reminders: [Date]
    
    init(title: String, content: String = "", startDate: Date, endDate: Date, location: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.tags = []
        self.lastModified = Date()
        self.createdDate = Date()
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.attendees = []
        self.reminders = []
    }
}

struct Contact: Searchable {
    let id: UUID
    var title: String // Full name
    var content: String // Notes about contact
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .contact
    var email: String?
    var phone: String?
    var company: String?
    var role: String?
    var socialLinks: [String: String]
    
    init(name: String, email: String? = nil, phone: String? = nil, company: String? = nil) {
        self.id = UUID()
        self.title = name
        self.content = ""
        self.tags = []
        self.lastModified = Date()
        self.createdDate = Date()
        self.email = email
        self.phone = phone
        self.company = company
        self.socialLinks = [:]
    }
}

struct Project: Searchable {
    let id: UUID
    var title: String
    var content: String // Description
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .project
    var status: Status
    var rootPath: String? // File system path
    var language: String?
    var framework: String?
    var taskIds: [UUID]
    var noteIds: [UUID]
    
    enum Status: String, Codable {
        case planning, active, paused, completed, archived
    }
    
    init(title: String, content: String, rootPath: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.tags = []
        self.lastModified = Date()
        self.createdDate = Date()
        self.status = .planning
        self.rootPath = rootPath
        self.taskIds = []
        self.noteIds = []
    }
}

struct Idea: Searchable {
    let id: UUID
    var title: String
    var content: String
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    let type: ContentType = .idea
    var category: String?
    var feasibility: Int? // 1-5
    var impact: Int? // 1-5
    var convertedToProjectId: UUID?
    
    init(title: String, content: String, tags: [String] = [], category: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.tags = tags
        self.lastModified = Date()
        self.createdDate = Date()
        self.category = category
    }
}

struct FileReference: Searchable {
    let id: UUID
    var title: String // Filename
    var content: String // File content preview or summary
    var tags: [String]
    var lastModified: Date
    var createdDate: Date
    var type: ContentType
    var path: String
    var fileSize: Int64
    var fileType: String
    var projectId: UUID?
    
    init(path: String, type: ContentType = .file) {
        self.id = UUID()
        self.path = path
        self.title = URL(fileURLWithPath: path).lastPathComponent
        self.content = ""
        self.tags = []
        self.type = type
        
        let attrs = try? FileManager.default.attributesOfItem(atPath: path)
        self.lastModified = attrs?[.modificationDate] as? Date ?? Date()
        self.createdDate = attrs?[.creationDate] as? Date ?? Date()
        self.fileSize = attrs?[.size] as? Int64 ?? 0
        self.fileType = URL(fileURLWithPath: path).pathExtension
    }
}

// MARK: - User Context

struct UserContext: Codable {
    var currentProject: Project?
    var recentFiles: [FileReference] = []
    var activeTask: UserTask?
    var workingMemory: [ContextItem] = []
    var lastActivity: Date = Date()
    
    mutating func addRecentFile(_ file: FileReference) {
        recentFiles.removeAll { $0.id == file.id }
        recentFiles.insert(file, at: 0)
        recentFiles = Array(recentFiles.prefix(20))
        lastActivity = Date()
    }
    
    mutating func addToWorkingMemory(_ item: ContextItem) {
        workingMemory.insert(item, at: 0)
        workingMemory = Array(workingMemory.prefix(50))
        lastActivity = Date()
    }
    
    func relevantContext(for query: String) -> [ContextItem] {
        return workingMemory.filter { item in
            switch item {
            case .note(let note):
                return note.relevanceScore(for: query) > 0
            case .task(let task):
                return task.relevanceScore(for: query) > 0
            case .event(let event):
                return event.relevanceScore(for: query) > 0
            case .file(let file):
                return file.relevanceScore(for: query) > 0
            }
        }
    }
}

enum ContextItem: Codable {
    case note(Note)
    case task(UserTask)
    case event(UserCalendarEvent)
    case file(FileReference)
    
    enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    enum ItemType: String, Codable {
        case note, task, event, file
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        
        switch type {
        case .note:
            let note = try container.decode(Note.self, forKey: .data)
            self = .note(note)
        case .task:
            let task = try container.decode(UserTask.self, forKey: .data)
            self = .task(task)
        case .event:
            let event = try container.decode(UserCalendarEvent.self, forKey: .data)
            self = .event(event)
        case .file:
            let file = try container.decode(FileReference.self, forKey: .data)
            self = .file(file)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .note(let note):
            try container.encode(ItemType.note, forKey: .type)
            try container.encode(note, forKey: .data)
        case .task(let task):
            try container.encode(ItemType.task, forKey: .type)
            try container.encode(task, forKey: .data)
        case .event(let event):
            try container.encode(ItemType.event, forKey: .type)
            try container.encode(event, forKey: .data)
        case .file(let file):
            try container.encode(ItemType.file, forKey: .type)
            try container.encode(file, forKey: .data)
        }
    }
}

// MARK: - Learning Patterns

struct LearningPatterns: Codable {
    var codingPatterns: [String: Int] = [:] // Pattern -> frequency
    var namingConventions: [String: String] = [:] // Type -> convention
    var architectureChoices: [String: Int] = [:] // Architecture -> frequency
    var productiveHours: [Int: Int] = [:] // Hour -> activity count
    var commonSolutions: [String: String] = [:] // Problem -> solution
    
    mutating func recordPattern(_ pattern: String) {
        codingPatterns[pattern, default: 0] += 1
    }
    
    mutating func recordActivity(at hour: Int) {
        productiveHours[hour, default: 0] += 1
    }
    
    func mostProductiveHours() -> [Int] {
        productiveHours.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
}
