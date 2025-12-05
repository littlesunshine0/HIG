//
//  AuthorizationService.swift
//  HIG
//
//  Production-ready RBAC authorization service
//

import Foundation
import Combine

@MainActor
class AuthorizationService: ObservableObject {
    
    static let shared = AuthorizationService()
    
    @Published var roles: [UUID: Role] = [:]
    @Published var userRoles: [UUID: [UserRoleAssignment]] = [:]
    @Published var policies: [UUID: Policy] = [:]
    @Published var auditTrail: [AuthorizationAudit] = []
    
    private init() {
        loadDefaultRoles()
    }
    
    // MARK: - Authorization Check
    
    func checkAccess(_ request: AccessRequest) -> AccessResponse {
        let userRoleAssignments = userRoles[request.userId] ?? []
        let activeRoles = userRoleAssignments.filter { $0.isActive && !$0.isExpired }
        
        var allowed = false
        var matchedPolicies: [UUID] = []
        var reason: String?
        
        // Check role permissions
        for assignment in activeRoles {
            guard let role = roles[assignment.roleId] else { continue }
            
            for permission in role.permissions {
                if permission.resource == request.resource &&
                   permission.action == request.action {
                    allowed = true
                    break
                }
            }
        }
        
        // Check policies (can override role permissions)
        let applicablePolicies = policies.values
            .filter { $0.isEnabled }
            .filter { policy in
                policy.principals.contains(request.userId) &&
                policy.actions.contains(request.action) &&
                policy.resources.contains(request.resource)
            }
            .sorted { $0.priority > $1.priority }
        
        for policy in applicablePolicies {
            matchedPolicies.append(policy.id)
            if policy.effect == .deny {
                allowed = false
                reason = "Denied by policy: \(policy.name)"
                break
            } else {
                allowed = true
            }
        }
        
        // Audit
        auditAccess(request, allowed: allowed, reason: reason)
        
        return AccessResponse(
            allowed: allowed,
            reason: reason,
            matchedPolicies: matchedPolicies,
            evaluatedAt: Date()
        )
    }
    
    // MARK: - Role Management
    
    func createRole(_ role: Role) {
        roles[role.id] = role
    }
    
    func assignRole(userId: UUID, roleId: UUID, assignedBy: UUID) {
        let assignment = UserRoleAssignment(
            id: UUID(),
            userId: userId,
            roleId: roleId,
            assignedBy: assignedBy,
            assignedAt: Date(),
            expiresAt: nil,
            isActive: true
        )
        
        if userRoles[userId] == nil {
            userRoles[userId] = []
        }
        userRoles[userId]?.append(assignment)
    }
    
    // MARK: - Audit
    
    private func auditAccess(_ request: AccessRequest, allowed: Bool, reason: String?) {
        let audit = AuthorizationAudit(
            id: UUID(),
            userId: request.userId,
            action: request.action,
            resource: request.resource,
            resourceId: request.resourceId,
            allowed: allowed,
            reason: reason,
            timestamp: Date(),
            ipAddress: "127.0.0.1",
            userAgent: nil
        )
        auditTrail.append(audit)
    }
    
    // MARK: - Default Roles
    
    private func loadDefaultRoles() {
        let adminRole = Role(
            id: UUID(),
            name: "Admin",
            description: "Full system access",
            permissions: Set([
                Permission(id: UUID(), resource: "*", action: .manage, scope: .global, conditions: [])
            ]),
            parentRoleId: nil,
            isSystemRole: true,
            createdAt: Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        let userRole = Role(
            id: UUID(),
            name: "User",
            description: "Basic user access",
            permissions: Set([
                Permission(id: UUID(), resource: "profile", action: .read, scope: .own, conditions: []),
                Permission(id: UUID(), resource: "profile", action: .update, scope: .own, conditions: [])
            ]),
            parentRoleId: nil,
            isSystemRole: true,
            createdAt: Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        roles[adminRole.id] = adminRole
        roles[userRole.id] = userRole
    }
}
