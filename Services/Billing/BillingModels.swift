//
//  BillingModels.swift
//  HIG
//
//  Billing and subscription models for monetization
//

import Foundation
import SwiftUI

// MARK: - Subscription Plan

struct SubscriptionPlan: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var tier: PlanTier
    var price: Decimal
    var billingPeriod: BillingPeriod
    var features: [Feature]
    var limits: PlanLimits
    var isActive: Bool
    
    enum PlanTier: String, Codable, CaseIterable {
        case free = "Free"
        case starter = "Starter"
        case pro = "Pro"
        case business = "Business"
        case enterprise = "Enterprise"
        
        var color: Color {
            switch self {
            case .free: return .gray
            case .starter: return .blue
            case .pro: return .purple
            case .business: return .orange
            case .enterprise: return .pink
            }
        }
        
        var icon: String {
            switch self {
            case .free: return "gift.fill"
            case .starter: return "star.fill"
            case .pro: return "crown.fill"
            case .business: return "building.fill"
            case .enterprise: return "building.2.fill"
            }
        }
    }
    
    var icon: String { tier.icon }
    var color: Color { tier.color }
    
    enum BillingPeriod: String, Codable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var discount: Double {
            self == .yearly ? 0.20 : 0 // 20% off yearly
        }
    }
    
    struct Feature: Codable, Identifiable {
        let id = UUID()
        var name: String
        var included: Bool
        var limit: String?
    }
    
    struct PlanLimits: Codable {
        var maxUsers: Int?
        var maxSessions: Int?
        var maxAPIRequests: Int?
        var maxStorage: Int? // in GB
        var mfaEnabled: Bool
        var ssoEnabled: Bool
        var auditLogsRetention: Int // days
        var supportLevel: SupportLevel
        
        enum SupportLevel: String, Codable {
            case community = "Community"
            case email = "Email"
            case priority = "Priority"
            case dedicated = "Dedicated"
        }
    }
}

// MARK: - Customer Subscription

struct CustomerSubscription: Identifiable, Codable {
    let id: UUID
    let customerId: UUID
    var planId: UUID
    var status: SubscriptionStatus
    var currentPeriodStart: Date
    var currentPeriodEnd: Date
    var cancelAtPeriodEnd: Bool
    var trialEnd: Date?
    var createdAt: Date
    var updatedAt: Date
    
    enum SubscriptionStatus: String, Codable {
        case trialing = "Trialing"
        case active = "Active"
        case pastDue = "Past Due"
        case canceled = "Canceled"
        case unpaid = "Unpaid"
        
        var color: Color {
            switch self {
            case .trialing: return .blue
            case .active: return .green
            case .pastDue: return .orange
            case .canceled: return .gray
            case .unpaid: return .red
            }
        }
    }
    
    var isActive: Bool {
        status == .active || status == .trialing
    }
}

// MARK: - Invoice

struct Invoice: Identifiable, Codable {
    let id: UUID
    let customerId: UUID
    let subscriptionId: UUID?
    var number: String
    var amount: Decimal
    var tax: Decimal
    var total: Decimal
    var currency: String
    var status: InvoiceStatus
    var dueDate: Date
    var paidAt: Date?
    var items: [InvoiceItem]
    var createdAt: Date
    
    var date: Date { createdAt }
    
    enum InvoiceStatus: String, Codable {
        case draft = "Draft"
        case open = "Open"
        case paid = "Paid"
        case pending = "Pending"
        case failed = "Failed"
        case void = "Void"
        case uncollectible = "Uncollectible"
        
        var color: Color {
            switch self {
            case .draft: return .gray
            case .open: return .blue
            case .paid: return .green
            case .pending: return .orange
            case .failed: return .red
            case .void: return .gray
            case .uncollectible: return .red
            }
        }
    }
    
    struct InvoiceItem: Codable, Identifiable {
        let id: UUID
        var description: String
        var quantity: Int
        var unitPrice: Decimal
        var amount: Decimal
        
        init(id: UUID = UUID(), description: String, quantity: Int, unitPrice: Decimal, amount: Decimal) {
            self.id = id
            self.description = description
            self.quantity = quantity
            self.unitPrice = unitPrice
            self.amount = amount
        }
    }
}

// MARK: - Payment Method

struct PaymentMethod: Identifiable, Codable {
    let id: UUID
    let customerId: UUID
    var type: PaymentType
    var last4: String
    var brand: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var isDefault: Bool
    var createdAt: Date
    
    var displayName: String {
        if let brand = brand {
            return "\(brand) •••• \(last4)"
        }
        return "•••• \(last4)"
    }
    
    enum PaymentType: String, Codable {
        case card = "Card"
        case bankAccount = "Bank Account"
        case applePay = "Apple Pay"
    }
}

// MARK: - Usage Tracking

struct UsageRecord: Identifiable, Codable {
    let id: UUID
    let customerId: UUID
    var metric: UsageMetric
    var quantity: Int
    var timestamp: Date
    var metadata: [String: String]
    
    enum UsageMetric: String, Codable {
        case apiRequests = "API Requests"
        case activeUsers = "Active Users"
        case storage = "Storage (GB)"
        case sessions = "Sessions"
    }
}

// MARK: - Billing Customer

struct BillingCustomer: Identifiable, Codable {
    let id: UUID
    var email: String
    var name: String
    var company: String?
    var taxId: String?
    var address: Address?
    var subscription: CustomerSubscription?
    var paymentMethods: [PaymentMethod]
    var balance: Decimal
    var createdAt: Date
    
    struct Address: Codable {
        var line1: String
        var line2: String?
        var city: String
        var state: String?
        var postalCode: String
        var country: String
    }
}
