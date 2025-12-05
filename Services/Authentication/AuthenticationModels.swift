//
//  AuthenticationModels.swift
//  HIG
//
//  Core data models for Authentication Service
//  Production-ready, monetizable backend infrastructure
//

import Foundation
import CryptoKit

// MARK: - User Model

struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var username: String
    var passwordHash: String
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var emailVerified: Bool
    var phoneVerified: Bool
    var mfaEnabled: Bool
    var accountStatus: AccountStatus
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?
    var metadata: [String: String]
    
    enum AccountStatus: String, Codable {
        case active
        case suspended
        case deleted
        case pendingVerification
    }
    
    var displayName: String {
        if let first = firstName, let last = lastName {
            return "\(first) \(last)"
        }
        return username
    }
}

// MARK: - Session Model

struct UserSession: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var token: String
    var refreshToken: String
    var deviceInfo: DeviceInfo
    var ipAddress: String
    var location: GeoLocation?
    var createdAt: Date
    var expiresAt: Date
    var lastActivityAt: Date
    var isActive: Bool
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

struct DeviceInfo: Codable {
    var deviceType: String // "iOS", "macOS", "web"
    var deviceName: String
    var osVersion: String
    var appVersion: String
    var userAgent: String?
}

struct GeoLocation: Codable {
    var city: String?
    var region: String?
    var country: String
    var countryCode: String
    var latitude: Double?
    var longitude: Double?
}

// MARK: - MFA Models

struct MFADevice: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var type: MFAType
    var name: String
    var secret: String // Encrypted TOTP secret
    var backupCodes: [String]
    var isVerified: Bool
    var createdAt: Date
    var lastUsedAt: Date?
    
    enum MFAType: String, Codable {
        case totp = "TOTP"
        case sms = "SMS"
        case email = "Email"
        case hardware = "Hardware Key"
    }
}

// MARK: - Login Attempt Model

struct LoginAttempt: Identifiable, Codable {
    let id: UUID
    var email: String
    var success: Bool
    var failureReason: String?
    var ipAddress: String
    var location: GeoLocation?
    var deviceInfo: DeviceInfo
    var timestamp: Date
    var mfaUsed: Bool
}

// MARK: - Audit Log Model

struct AuditLog: Identifiable, Codable {
    let id: UUID
    let userId: UUID?
    var action: AuditAction
    var resource: String?
    var details: [String: String]
    var ipAddress: String
    var timestamp: Date
    var severity: Severity
    
    enum AuditAction: String, Codable {
        case login
        case logout
        case passwordChange
        case passwordReset
        case mfaEnabled
        case mfaDisabled
        case emailVerified
        case accountCreated
        case accountSuspended
        case accountDeleted
        case permissionGranted
        case permissionRevoked
    }
    
    enum Severity: String, Codable {
        case info
        case warning
        case critical
    }
}

// MARK: - OAuth Provider

struct OAuthProvider: Codable {
    var provider: Provider
    var clientId: String
    var clientSecret: String
    var redirectUri: String
    var scopes: [String]
    var enabled: Bool
    
    enum Provider: String, Codable {
        case google
        case apple
        case github
        case microsoft
    }
}

// MARK: - Password Reset Token

struct PasswordResetToken: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var token: String
    var expiresAt: Date
    var used: Bool
    var createdAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - Email Verification Token

struct EmailVerificationToken: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var token: String
    var email: String
    var expiresAt: Date
    var verified: Bool
    var createdAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - Rate Limit

struct RateLimit: Codable {
    var identifier: String // IP or user ID
    var action: String // "login", "password_reset", etc.
    var attempts: Int
    var windowStart: Date
    var windowDuration: TimeInterval
    var maxAttempts: Int
    
    var isLimited: Bool {
        let windowEnd = windowStart.addingTimeInterval(windowDuration)
        return Date() < windowEnd && attempts >= maxAttempts
    }
    
    var resetAt: Date {
        windowStart.addingTimeInterval(windowDuration)
    }
}

// MARK: - Authentication Request/Response Models

struct LoginRequest: Codable {
    var email: String
    var password: String
    var deviceInfo: DeviceInfo
    var mfaCode: String?
}

struct LoginResponse: Codable {
    var success: Bool
    var token: String?
    var refreshToken: String?
    var user: User?
    var requiresMFA: Bool
    var error: String?
}

struct RegisterRequest: Codable {
    var email: String
    var username: String
    var password: String
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
}

struct RegisterResponse: Codable {
    var success: Bool
    var user: User?
    var verificationRequired: Bool
    var error: String?
}

struct MFASetupRequest: Codable {
    var type: MFADevice.MFAType
    var name: String
    var phoneNumber: String? // For SMS
}

struct MFASetupResponse: Codable {
    var success: Bool
    var secret: String? // TOTP secret for QR code
    var backupCodes: [String]?
    var qrCodeUrl: String?
    var error: String?
}

struct PasswordResetRequest: Codable {
    var email: String
}

struct PasswordResetResponse: Codable {
    var success: Bool
    var message: String
}

struct PasswordChangeRequest: Codable {
    var token: String
    var newPassword: String
}
