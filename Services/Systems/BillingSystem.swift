//
//  BillingSystem.swift
//  HIG
//
//  Billing / Subscription System - Plans, payments, invoices, trials
//

import SwiftUI

struct BillingSystemView: View {
    @State private var selectedTab = "Plans"
    
    let tabs = ["Plans", "Subscriptions", "Invoices", "Payment Methods"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "creditcard.fill").font(.title2).foregroundStyle(.green)
                Text("Billing System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.green.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Plans": PlansView()
                case "Subscriptions": SubscriptionsView()
                case "Invoices": InvoicesView()
                case "Payment Methods": PaymentMethodsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct PlansView: View {
    let plans = [
        ("Free", "$0", "Basic features", ["5 projects", "1GB storage", "Email support"], false),
        ("Pro", "$19", "For professionals", ["Unlimited projects", "50GB storage", "Priority support", "API access"], true),
        ("Enterprise", "$99", "For teams", ["Everything in Pro", "Unlimited storage", "SSO", "Dedicated support", "SLA"], false),
    ]
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 20) {
                ForEach(plans, id: \.0) { plan in
                    VStack(spacing: 16) {
                        if plan.4 { Text("Most Popular").font(.caption).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 4).background(Capsule().fill(Color.green)) }
                        
                        Text(plan.0).font(.title2.bold())
                        HStack(alignment: .top, spacing: 2) {
                            Text(plan.1).font(.largeTitle.bold())
                            Text("/mo").font(.caption).foregroundStyle(.secondary)
                        }
                        Text(plan.2).font(.caption).foregroundStyle(.secondary)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(plan.3, id: \.self) { feature in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                    Text(feature).font(.caption)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(plan.4 ? "Current Plan" : "Upgrade") {}
                            .buttonStyle(.borderedProminent)
                            .tint(plan.4 ? .secondary : .green)
                            .disabled(plan.4)
                    }
                    .padding(24)
                    .frame(width: 250, height: 400)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.controlBackgroundColor)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(plan.4 ? Color.green : Color.clear, lineWidth: 2))
                }
            }
            .padding()
        }
    }
}

struct SubscriptionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Current Subscription
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Subscription").font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pro Plan").font(.title3.bold())
                        Text("$19/month • Renews Dec 27, 2024").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("Active").font(.caption).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Capsule().fill(Color.green))
                }
                
                Divider()
                
                HStack {
                    Button("Change Plan") {}.buttonStyle(.bordered)
                    Button("Cancel Subscription") {}.buttonStyle(.bordered).tint(.red)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // Usage
            VStack(alignment: .leading, spacing: 12) {
                Text("Usage This Period").font(.headline)
                
                UsageRow(label: "Projects", used: 12, limit: nil, unit: "")
                UsageRow(label: "Storage", used: 23.5, limit: 50, unit: "GB")
                UsageRow(label: "API Calls", used: 45000, limit: 100000, unit: "")
                UsageRow(label: "Team Members", used: 5, limit: 10, unit: "")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct UsageRow: View {
    let label: String
    let used: Double
    let limit: Double?
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                if let limit = limit {
                    Text("\(formatNumber(used))\(unit) / \(formatNumber(limit))\(unit)").font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("\(formatNumber(used)) (Unlimited)").font(.caption).foregroundStyle(.secondary)
                }
            }
            if let limit = limit {
                ProgressView(value: used / limit).tint(used / limit > 0.8 ? .orange : .green)
            }
        }
    }
    
    func formatNumber(_ n: Double) -> String {
        if n >= 1000 { return String(format: "%.0fK", n / 1000) }
        return n == floor(n) ? String(format: "%.0f", n) : String(format: "%.1f", n)
    }
}

struct InvoicesView: View {
    let invoices = [
        ("INV-2024-012", "Nov 27, 2024", "$19.00", "Paid"),
        ("INV-2024-011", "Oct 27, 2024", "$19.00", "Paid"),
        ("INV-2024-010", "Sep 27, 2024", "$19.00", "Paid"),
        ("INV-2024-009", "Aug 27, 2024", "$19.00", "Paid"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Invoices").font(.headline)
                Spacer()
                Button("Download All") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(invoices, id: \.0) { invoice in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(invoice.0).font(.subheadline)
                            Text(invoice.1).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(invoice.2).font(.subheadline.bold())
                        Text(invoice.3).font(.caption).foregroundStyle(.white).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.green))
                        Button { } label: { Image(systemName: "arrow.down.doc") }.buttonStyle(.bordered)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct PaymentMethodsView: View {
    let methods = [
        ("Visa •••• 4242", "Expires 12/25", true),
        ("PayPal", "john@example.com", false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Payment Methods").font(.headline)
                Spacer()
                Button("Add Method") {}.buttonStyle(.borderedProminent).tint(.green)
            }
            
            ForEach(methods, id: \.0) { method in
                HStack {
                    Image(systemName: method.0.contains("Visa") ? "creditcard.fill" : "p.circle.fill")
                        .font(.title2).foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text(method.0).font(.subheadline)
                        Text(method.1).font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if method.2 {
                        Text("Default").font(.caption).foregroundStyle(.green)
                    }
                    Button("Edit") {}.buttonStyle(.bordered)
                    Button { } label: { Image(systemName: "trash") }.buttonStyle(.bordered).tint(.red)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview { BillingSystemView().frame(width: 900, height: 700) }
