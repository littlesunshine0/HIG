//
//  APIEndpoints.swift
//  HIG
//
//  REST API endpoints for external consumption
//  Production-ready API layer for monetization
//

import Foundation
import Combine

// MARK: - API Router

@MainActor
class ExternalAPIRouter: ObservableObject {
    
    static let shared = ExternalAPIRouter()
    
    @Published var isProcessing = false
    
    private let authService = AuthenticationService.shared
    private let authzService = AuthorizationService.shared
    
    // MARK: - Authentication Endpoints
    
    /// POST /api/v1/auth/register
    func register(_ request: RegisterRequest) async throws -> APIResponse<RegisterResponse> {
        let response = try await authService.register(request)
        return APIResponse(success: response.success, data: response, error: response.error)
    }
    
    /// POST /api/v1/auth/login
    func login(_ request: LoginRequest) async throws -> APIResponse<LoginResponse> {
        let response = try await authService.login(request)
        return APIResponse(success: response.success, data: response, error: response.error)
    }
    
    /// POST /api/v1/auth/logout
    func logout(token: String) async -> APIResponse<EmptyResponse> {
        await authService.logout()
        return APIResponse(success: true, data: EmptyResponse(), error: nil)
    }
    
    /// POST /api/v1/auth/refresh
    func refreshToken(_ refreshToken: String) async throws -> APIResponse<UserSession> {
        let session = try await authService.refreshSession(refreshToken: refreshToken)
        return APIResponse(success: true, data: session, error: nil)
    }
    
    /// POST /api/v1/auth/password/reset
    func requestPasswordReset(_ request: PasswordResetRequest) async throws -> APIResponse<PasswordResetResponse> {
        let response = try await authService.requestPasswordReset(request)
        return APIResponse(success: response.success, data: response, error: nil)
    }
    
    /// POST /api/v1/auth/mfa/setup
    func setupMFA(userId: UUID, request: MFASetupRequest) async throws -> APIResponse<MFASetupResponse> {
        let response = try await authService.setupMFA(userId: userId, request: request)
        return APIResponse(success: response.success, data: response, error: response.error)
    }
    
    // MARK: - Authorization Endpoints
    
    /// POST /api/v1/authz/check
    func checkAccess(_ request: AccessRequest) -> APIResponse<AccessResponse> {
        let response = authzService.checkAccess(request)
        return APIResponse(success: response.allowed, data: response, error: response.reason)
    }
    
    /// POST /api/v1/authz/roles
    func createRole(_ role: Role) -> APIResponse<Role> {
        authzService.createRole(role)
        return APIResponse(success: true, data: role, error: nil)
    }
    
    /// POST /api/v1/authz/roles/assign
    func assignRole(userId: UUID, roleId: UUID, assignedBy: UUID) -> APIResponse<EmptyResponse> {
        authzService.assignRole(userId: userId, roleId: roleId, assignedBy: assignedBy)
        return APIResponse(success: true, data: EmptyResponse(), error: nil)
    }
    
    /// GET /api/v1/authz/roles
    func getRoles() -> APIResponse<[Role]> {
        let roles = Array(authzService.roles.values)
        return APIResponse(success: true, data: roles, error: nil)
    }
    
    // MARK: - Analytics Endpoints
    
    /// GET /api/v1/analytics/login-attempts
    func getLoginAttempts(limit: Int = 100) -> APIResponse<[LoginAttempt]> {
        let attempts = authService.getLoginAttempts(limit: limit)
        return APIResponse(success: true, data: attempts, error: nil)
    }
    
    /// GET /api/v1/analytics/audit-logs
    func getAuditLogs(userId: UUID? = nil, limit: Int = 100) -> APIResponse<[AuditLog]> {
        let logs = authService.getAuditLogs(userId: userId, limit: limit)
        return APIResponse(success: true, data: logs, error: nil)
    }
    
    /// GET /api/v1/analytics/sessions
    func getActiveSessions(userId: UUID? = nil) -> APIResponse<[UserSession]> {
        let sessions = authService.getActiveSessions(userId: userId)
        return APIResponse(success: true, data: sessions, error: nil)
    }
}

// MARK: - API Response

struct APIResponse<T: Codable>: Codable {
    var success: Bool
    var data: T?
    var error: String?
    var timestamp: Date = Date()
    var version: String = "1.0"
}

struct EmptyResponse: Codable {}

// MARK: - API Documentation

enum APIDocumentation {
    static let baseURL = "https://api.yourdomain.com"
    static let version = "v1"
    
    static let endpoints: [APIEndpoint] = [
        // Authentication
        APIEndpoint(
            method: .POST,
            path: "/api/v1/auth/register",
            description: "Register a new user",
            requestBody: "RegisterRequest",
            response: "RegisterResponse",
            requiresAuth: false
        ),
        APIEndpoint(
            method: .POST,
            path: "/api/v1/auth/login",
            description: "Login with email and password",
            requestBody: "LoginRequest",
            response: "LoginResponse",
            requiresAuth: false
        ),
        APIEndpoint(
            method: .POST,
            path: "/api/v1/auth/logout",
            description: "Logout and invalidate session",
            requestBody: nil,
            response: "EmptyResponse",
            requiresAuth: true
        ),
        APIEndpoint(
            method: .POST,
            path: "/api/v1/auth/refresh",
            description: "Refresh access token",
            requestBody: "RefreshTokenRequest",
            response: "UserSession",
            requiresAuth: false
        ),
        
        // Authorization
        APIEndpoint(
            method: .POST,
            path: "/api/v1/authz/check",
            description: "Check if user has access to resource",
            requestBody: "AccessRequest",
            response: "AccessResponse",
            requiresAuth: true
        ),
        APIEndpoint(
            method: .GET,
            path: "/api/v1/authz/roles",
            description: "Get all roles",
            requestBody: nil,
            response: "[Role]",
            requiresAuth: true
        ),
        
        // Analytics
        APIEndpoint(
            method: .GET,
            path: "/api/v1/analytics/login-attempts",
            description: "Get login attempt history",
            requestBody: nil,
            response: "[LoginAttempt]",
            requiresAuth: true
        )
    ]
}

struct APIEndpoint: Identifiable {
    let id = UUID()
    var method: HTTPMethod
    var path: String
    var description: String
    var requestBody: String?
    var response: String
    var requiresAuth: Bool
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
}

// MARK: - Rate Limiting

class ExternalRateLimiter {
    private var requests: [String: [Date]] = [:]
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    
    init(maxRequests: Int = 100, timeWindow: TimeInterval = 60) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func checkLimit(for identifier: String) -> Bool {
        let now = Date()
        let windowStart = now.addingTimeInterval(-timeWindow)
        
        // Clean old requests
        requests[identifier] = requests[identifier]?.filter { $0 > windowStart } ?? []
        
        // Check limit
        guard let count = requests[identifier]?.count, count < maxRequests else {
            return false
        }
        
        // Add new request
        if requests[identifier] == nil {
            requests[identifier] = []
        }
        requests[identifier]?.append(now)
        
        return true
    }
}
