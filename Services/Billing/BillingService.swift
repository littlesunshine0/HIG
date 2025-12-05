//
//  BillingService.swift
//  HIG
//
//  Stripe-integrated billing service for monetization
//

import Foundation
import Combine

@MainActor
class BillingService: ObservableObject {
    
    static let shared = BillingService()
    
    @Published var plans: [SubscriptionPlan] = []
    @Published var customers: [UUID: BillingCustomer] = [:]
    @Published var subscriptions: [UUID: CustomerSubscription] = [:]
    @Published var invoices: [Invoice] = []
    @Published var usageRecords: [UsageRecord] = []
    
    private let stripeAPIKey = "sk_test_your_key_here" // Replace with real key
    
    private init() {
        loadPlans()
    }
    
    // MARK: - Subscription Management
    
    func createSubscription(customerId: UUID, planId: UUID) async throws -> CustomerSubscription {
        guard plans.first(where: { $0.id == planId }) != nil else {
            throw BillingError.planNotFound
        }
        
        let subscription = CustomerSubscription(
            id: UUID(),
            customerId: customerId,
            planId: planId,
            status: .trialing,
            currentPeriodStart: Date(),
            currentPeriodEnd: Date().addingTimeInterval(2592000), // 30 days
            cancelAtPeriodEnd: false,
            trialEnd: Date().addingTimeInterval(1209600), // 14 day trial
            createdAt: Date(),
            updatedAt: Date()
        )
        
        subscriptions[subscription.id] = subscription
        
        // Update customer
        customers[customerId]?.subscription = subscription
        
        return subscription
    }
    
    func cancelSubscription(subscriptionId: UUID, immediately: Bool = false) async throws {
        guard var subscription = subscriptions[subscriptionId] else {
            throw BillingError.subscriptionNotFound
        }
        
        if immediately {
            subscription.status = .canceled
            subscription.updatedAt = Date()
        } else {
            subscription.cancelAtPeriodEnd = true
        }
        
        subscriptions[subscriptionId] = subscription
    }
    
    func upgradeSubscription(subscriptionId: UUID, newPlanId: UUID) async throws -> CustomerSubscription {
        guard var subscription = subscriptions[subscriptionId] else {
            throw BillingError.subscriptionNotFound
        }
        
        subscription.planId = newPlanId
        subscription.updatedAt = Date()
        subscriptions[subscriptionId] = subscription
        
        return subscription
    }
    
    // MARK: - Usage Tracking
    
    func trackUsage(customerId: UUID, metric: UsageRecord.UsageMetric, quantity: Int) {
        let record = UsageRecord(
            id: UUID(),
            customerId: customerId,
            metric: metric,
            quantity: quantity,
            timestamp: Date(),
            metadata: [:]
        )
        usageRecords.append(record)
    }
    
    func getUsage(customerId: UUID, metric: UsageRecord.UsageMetric, period: DateInterval) -> Int {
        usageRecords
            .filter { $0.customerId == customerId && $0.metric == metric }
            .filter { period.contains($0.timestamp) }
            .reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - Invoicing
    
    func generateInvoice(customerId: UUID, subscriptionId: UUID) async throws -> Invoice {
        guard let subscription = subscriptions[subscriptionId],
              let plan = plans.first(where: { $0.id == subscription.planId }) else {
            throw BillingError.subscriptionNotFound
        }
        
        let subtotal = plan.price
        let tax = subtotal * 0.08 // 8% tax
        let total = subtotal + tax
        
        let invoice = Invoice(
            id: UUID(),
            customerId: customerId,
            subscriptionId: subscriptionId,
            number: "INV-\(Int.random(in: 10000...99999))",
            amount: subtotal,
            tax: tax,
            total: total,
            currency: "USD",
            status: .open,
            dueDate: Date().addingTimeInterval(86400 * 7), // 7 days
            paidAt: nil,
            items: [
                Invoice.InvoiceItem(
                    description: "\(plan.name) - \(plan.billingPeriod.rawValue)",
                    quantity: 1,
                    unitPrice: plan.price,
                    amount: plan.price
                )
            ],
            createdAt: Date()
        )
        
        invoices.append(invoice)
        return invoice
    }
    
    // MARK: - Plans
    
    private func loadPlans() {
        plans = [
            // Authentication Service Plans
            SubscriptionPlan(
                id: UUID(),
                name: "Auth Free",
                description: "Basic authentication for small projects",
                tier: .free,
                price: 0,
                billingPeriod: .monthly,
                features: [
                    .init(name: "Up to 100 users", included: true),
                    .init(name: "Email/Password auth", included: true),
                    .init(name: "Basic audit logs", included: true, limit: "7 days"),
                    .init(name: "MFA", included: false),
                    .init(name: "SSO", included: false)
                ],
                limits: .init(
                    maxUsers: 100,
                    maxSessions: 500,
                    maxAPIRequests: 10000,
                    maxStorage: nil,
                    mfaEnabled: false,
                    ssoEnabled: false,
                    auditLogsRetention: 7,
                    supportLevel: .community
                ),
                isActive: true
            ),
            SubscriptionPlan(
                id: UUID(),
                name: "Auth Pro",
                description: "Professional authentication for growing teams",
                tier: .pro,
                price: 29,
                billingPeriod: .monthly,
                features: [
                    .init(name: "Up to 1,000 users", included: true),
                    .init(name: "Email/Password auth", included: true),
                    .init(name: "MFA (TOTP, SMS)", included: true),
                    .init(name: "Audit logs", included: true, limit: "90 days"),
                    .init(name: "SSO", included: false)
                ],
                limits: .init(
                    maxUsers: 1000,
                    maxSessions: 5000,
                    maxAPIRequests: 100000,
                    maxStorage: nil,
                    mfaEnabled: true,
                    ssoEnabled: false,
                    auditLogsRetention: 90,
                    supportLevel: .email
                ),
                isActive: true
            ),
            SubscriptionPlan(
                id: UUID(),
                name: "Auth Enterprise",
                description: "Enterprise-grade authentication",
                tier: .enterprise,
                price: 99,
                billingPeriod: .monthly,
                features: [
                    .init(name: "Unlimited users", included: true),
                    .init(name: "All auth methods", included: true),
                    .init(name: "MFA + SSO", included: true),
                    .init(name: "Unlimited audit logs", included: true),
                    .init(name: "Custom branding", included: true),
                    .init(name: "SLA guarantee", included: true)
                ],
                limits: .init(
                    maxUsers: nil,
                    maxSessions: nil,
                    maxAPIRequests: nil,
                    maxStorage: nil,
                    mfaEnabled: true,
                    ssoEnabled: true,
                    auditLogsRetention: 365,
                    supportLevel: .dedicated
                ),
                isActive: true
            )
        ]
    }
}

// MARK: - Billing Error

enum BillingError: LocalizedError {
    case planNotFound
    case subscriptionNotFound
    case paymentFailed
    case insufficientFunds
    case invalidCard
    case subscriptionExpired
    
    var errorDescription: String? {
        switch self {
        case .planNotFound: return "Subscription plan not found"
        case .subscriptionNotFound: return "Subscription not found"
        case .paymentFailed: return "Payment failed"
        case .insufficientFunds: return "Insufficient funds"
        case .invalidCard: return "Invalid payment method"
        case .subscriptionExpired: return "Subscription has expired"
        }
    }
}
