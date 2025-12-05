//
//  Persistence.swift
//  HIG
//
//  SwiftData scaffolding for Project, TaskEntity, and ChecklistEntity.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ProjectEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade) var tasks: [TaskEntity] = []

    init(id: UUID = UUID(), title: String, summary: String, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.summary = summary
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class TaskEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    var status: String
    var priority: String
    var createdAt: Date
    var dueAt: Date?

    @Relationship(deleteRule: .cascade) var checklist: ChecklistEntity?
    @Relationship(inverse: \ProjectEntity.tasks) var project: ProjectEntity?

    init(id: UUID = UUID(), title: String, details: String, status: String, priority: String, createdAt: Date = .now, dueAt: Date? = nil, project: ProjectEntity? = nil) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.priority = priority
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.project = project
    }
}

@Model
final class ChecklistEntity {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var items: [ChecklistItemEntity] = []

    init(id: UUID = UUID()) { self.id = id }
}

@Model
final class ChecklistItemEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

@Model
final class ChatThreadEntity {
    @Attribute(.unique) var id: UUID
    var projectID: UUID?
    var taskID: UUID?
    var title: String
    @Relationship(deleteRule: .cascade) var messages: [ChatMessageEntity] = []

    init(id: UUID = UUID(), projectID: UUID?, taskID: UUID?, title: String) {
        self.id = id
        self.projectID = projectID
        self.taskID = taskID
        self.title = title
    }
}

@Model
final class ChatMessageEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var role: String // "user" or "assistant"
    var text: String
    @Relationship var thread: ChatThreadEntity?

    init(id: UUID = UUID(), date: Date, role: String, text: String, thread: ChatThreadEntity?) {
        self.id = id
        self.date = date
        self.role = role
        self.text = text
        self.thread = thread
    }
}

// MARK: - Model Container

enum PersistenceController {
    static var shared: ModelContainer = {
        let schema = Schema([
            ProjectEntity.self,
            TaskEntity.self,
            ChecklistEntity.self,
            ChecklistItemEntity.self,
            ChatThreadEntity.self,
            ChatMessageEntity.self
        ])
        let config = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
