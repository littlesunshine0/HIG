//
//  AuthorizationModels.swift
//  HIG
//
//  Role-Based Access Control (RBAC) system models
//  Production-ready authorization infrastructure
//

import Foundation

// MARK: - Role Model

struct Role: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var permissions: Set<Permission>
    var parentRoleId: UUID?
    var isSystemRole: Bool
    var createdAt: Date
    var updatedAt: Date
    var metadata: [String: String]
    
    // Hierarchical role support
    var inheritsFrom: [UUID] {
        parentRoleId.map { [$0] } ?? []
    }
}

// MARK: - Permission Model

struct Permission: Identifiable, Codable, Hashable {
    let id: UUID
    var resource: String // e.g., "users", "posts", "settings"
    var action: Action
    var scope: Scope
    var conditions: [Condition]
    
    enum Action: String, Codable, CaseIterable {
        case create, read, update, delete
        case list, execute, manage
        
        var displayName: String { rawValue.capitalized }
    }
    
    enum Scope: String, Codable {
        case own // User's own resources
        case team // Team resources
        case organization // Organization-wide
        case global // All resources
    }
    
    struct Condition: Codable, Hashable {
        var field: String
        var conditionOperator: ConditionOperator
        var value: String
        
        enum ConditionOperator: String, Codable {
            case equals, notEquals
            case contains, notContains
            case greaterThan, lessThan
        }
    }
    
    var displayName: String {
        "\(action.displayName) \(resource)"
    }
}

// MARK: - User Role Assignment

struct UserRoleAssignment: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let roleId: UUID
    var assignedBy: UUID
    var assignedAt: Date
    var expiresAt: Date?
    var isActive: Bool
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
}

// MARK: - Resource

struct Resource: Identifiable, Codable {
    let id: UUID
    var type: String
    var ownerId: UUID
    var teamId: UUID?
    var organizationId: UUID?
    var isPublic: Bool
    var createdAt: Date
    var metadata: [String: String]
}

// MARK: - Policy

struct Policy: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var effect: Effect
    var principals: [UUID] // User or Role IDs
    var actions: [Permission.Action]
    var resources: [String]
    var conditions: [Permission.Condition]
    var priority: Int
    var isEnabled: Bool
    
    enum Effect: String, Codable {
        case allow, deny
    }
}

// MARK: - Access Request

struct AccessRequest: Codable {
    var userId: UUID
    var action: Permission.Action
    var resource: String
    var resourceId: UUID?
    var context: [String: String]
}

struct AccessResponse: Codable {
    var allowed: Bool
    var reason: String?
    var matchedPolicies: [UUID]
    var evaluatedAt: Date
}

// MARK: - Audit Trail

struct AuthorizationAudit: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var action: Permission.Action
    var resource: String
    var resourceId: UUID?
    var allowed: Bool
    var reason: String?
    var timestamp: Date
    var ipAddress: String
    var userAgent: String?
}
