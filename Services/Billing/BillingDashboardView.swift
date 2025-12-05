import SwiftUI
import Charts
import Combine

/// Elite Billing Dashboard with Stripe integration UI
struct BillingDashboardView: View {
    @StateObject private var viewModel = BillingViewModel()
    @State private var showSubscriptionSheet = false
    @State private var showPaymentMethodSheet = false
    @State private var selectedInvoice: Invoice?
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } content: {
            mainContent
        } detail: {
            detailContent
        }
        .navigationTitle("Billing")
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionManagementSheet()
        }
        .sheet(isPresented: $showPaymentMethodSheet) {
            PaymentMethodSheet()
        }
    }
    
    private var sidebarContent: some View {
        List {
            Section("Current Plan") {
                if let plan = viewModel.currentPlan {
                    PlanCard(plan: plan)
                } else {
                    Text("No active plan")
                        .foregroundStyle(.secondary)
                }
                
                Button(action: { showSubscriptionSheet = true }) {
                    Label("Manage Subscription", systemImage: "creditcard.fill")
                }
            }
            
            Section("Quick Stats") {
                StatRow(label: "Monthly Cost", value: "$\(viewModel.monthlyCost)")
                StatRow(label: "Usage", value: "\(viewModel.usagePercent)%")
                StatRow(label: "Next Billing", value: viewModel.nextBillingDate)
            }
            
            Section("Payment Methods") {
                ForEach(viewModel.paymentMethods) { method in
                    PaymentMethodRow(method: method)
                }
                
                Button(action: { showPaymentMethodSheet = true }) {
                    Label("Add Payment Method", systemImage: "plus.circle")
                }
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Usage chart
                UsageChart(data: viewModel.usageData)
                    .frame(height: 250)
                    .padding()
                
                // Cost breakdown
                CostBreakdownChart(data: viewModel.costBreakdown)
                    .frame(height: 200)
                    .padding()
                
                // Available plans
                PlansComparisonView()
                    .padding()
            }
        }
    }
    
    private var detailContent: some View {
        Group {
            if let invoice = selectedInvoice {
                InvoiceDetailView(invoice: invoice)
            } else {
                InvoiceListView(
                    invoices: viewModel.invoices,
                    onSelect: { selectedInvoice = $0 }
                )
            }
        }
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: SubscriptionPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: plan.icon)
                    .font(.title2)
                    .foregroundStyle(plan.color)
                
                Spacer()
                
                Text(plan.tier.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(plan.color.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text(plan.name)
                .font(.headline)
            
            Text("$\(plan.price)/month")
                .font(.title2)
                .fontWeight(.bold)
            
            if let requests = plan.limits.maxAPIRequests {
                 Text("\(requests) requests/month")
                     .font(.caption)
                     .foregroundStyle(.secondary)
             } else {
                 Text("Unlimited requests")
                     .font(.caption)
                     .foregroundStyle(.secondary)
             }
        }
        .padding()
        .background(plan.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Payment Method Row
struct PaymentMethodRow: View {
    let method: PaymentMethod
    
    var body: some View {
        HStack {
            Image(systemName: method.type == .card ? "creditcard.fill" : "building.columns.fill")
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text(method.displayName)
                    .font(.subheadline)
                Text("•••• \(method.last4)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if method.isDefault {
                Text("Default")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Usage Chart
struct UsageChart: View {
    let data: [UsageDataPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("API Usage This Month")
                .font(.headline)
            
            Chart(data) { point in
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Requests", point.requests)
                )
                .foregroundStyle(.blue.gradient)
            }
            
            HStack {
                Text("Total: \(data.map(\.requests).reduce(0, +)) requests")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Limit: 10,000")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Cost Breakdown Chart
struct CostBreakdownChart: View {
    let data: [CostItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Cost Breakdown")
                .font(.headline)
            
            Chart(data) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", item.category))
                .cornerRadius(4)
            }
            
            HStack {
                ForEach(data) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.category)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Plans Comparison
struct PlansComparisonView: View {
    @StateObject private var billingService = BillingService.shared
    
    var plans: [SubscriptionPlan] {
        billingService.plans
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Plans")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(plans) { plan in
                    PlanComparisonCard(plan: plan)
                }
            }
        }
    }
}

struct PlanComparisonCard: View {
    let plan: SubscriptionPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: plan.icon)
                    .foregroundStyle(plan.color)
                Text(plan.name)
                    .font(.headline)
            }
            
            Text("$\(plan.price)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("per month")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                BillingFeatureRow(text: "API Access")
                BillingFeatureRow(text: "24/7 Support")
                if plan.tier == .pro || plan.tier == .enterprise || plan.tier == .business {
                    BillingFeatureRow(text: "Priority Support")
                }
                if plan.tier == .enterprise {
                    BillingFeatureRow(text: "Custom Integration")
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Select Plan")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BillingFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
}

// MARK: - Invoice List
struct InvoiceListView: View {
    let invoices: [Invoice]
    let onSelect: (Invoice) -> Void
    
    var body: some View {
        List(invoices) { invoice in
            Button(action: { onSelect(invoice) }) {
                InvoiceRow(invoice: invoice)
            }
        }
        .navigationTitle("Invoices")
    }
}

struct InvoiceRow: View {
    let invoice: Invoice
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(invoice.number)
                    .font(.headline)
                Text(invoice.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(invoice.amount.formatted(.currency(code: invoice.currency)))
                    .font(.headline)
                BillingStatusBadge(status: invoice.status)
            }
        }
    }
}

struct BillingStatusBadge: View {
    let status: Invoice.InvoiceStatus
    
    var color: Color {
        switch status {
        case .paid: return .green
        case .pending: return .orange
        case .failed: return .red
        case .draft: return .gray
        case .open: return .blue
        case .void: return .gray
        case .uncollectible: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Invoice Detail
struct InvoiceDetailView: View {
    let invoice: Invoice
    
    // Helper for decimal formatting
    private func format(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = invoice.currency
        return formatter.string(from: decimal as NSDecimalNumber) ?? "$0.00"
    }
    
    var body: some View {
        List {
            Section("Invoice Information") {
                LabeledContent("Number", value: invoice.number)
                LabeledContent("Date", value: invoice.date, format: .dateTime)
                LabeledContent("Status", value: invoice.status.rawValue)
            }
            
            Section("Amount") {
                LabeledContent("Subtotal", value: format(invoice.amount))
                LabeledContent("Tax", value: format(invoice.tax))
                LabeledContent("Total", value: format(invoice.total))
            }
            
            Section("Line Items") {
                ForEach(invoice.items) { item in
                    HStack {
                        Text(item.description)
                        Spacer()
                        Text(format(item.amount))
                    }
                }
            }
            
            Section {
                Button("Download PDF") {}
                Button("Send Receipt") {}
            }
        }
        .navigationTitle("Invoice Details")
    }
}


// MARK: - Subscription Management Sheet
struct SubscriptionManagementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan.PlanTier = .pro
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Current Subscription") {
                    Text("Basic Plan")
                    Text("$29/month")
                    Text("Next billing: Jan 1, 2026")
                }
                
                Section("Change Plan") {
                    Picker("Select Plan", selection: $selectedPlan) {
                        Text("Free").tag(SubscriptionPlan.PlanTier.free)
                        Text("Starter - $49").tag(SubscriptionPlan.PlanTier.starter)
                        Text("Pro - $149").tag(SubscriptionPlan.PlanTier.pro)
                        Text("Business - $299").tag(SubscriptionPlan.PlanTier.business)
                        Text("Enterprise - $499").tag(SubscriptionPlan.PlanTier.enterprise)
                    }
                }
                
                Section("Actions") {
                    Button("Update Subscription") {}
                    Button("Cancel Subscription", role: .destructive) {}
                }
            }
            .navigationTitle("Manage Subscription")
            .toolbar {
                ToolbarItem {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Payment Method Sheet
struct PaymentMethodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var setAsDefault = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Card Information") {
                    // Removed .keyboardType as it can cause issues on non-iOS platforms
                    TextField("Card Number", text: $cardNumber)
                    TextField("MM/YY", text: $expiryDate)
                    TextField("CVV", text: $cvv)
                }
                
                Section {
                    Toggle("Set as default payment method", isOn: $setAsDefault)
                }
            }
            .navigationTitle("Add Payment Method")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // Add payment method via Stripe
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model
@MainActor
class BillingViewModel: ObservableObject {
    private var billingService = BillingService.shared
    @Published var currentPlan: SubscriptionPlan?
    @Published var monthlyCost = 29
    @Published var usagePercent = 67
    @Published var nextBillingDate = "Jan 1, 2026"
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var usageData: [UsageDataPoint] = []
    @Published var costBreakdown: [CostItem] = []
    @Published var invoices: [Invoice] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Mock Payment Methods
        paymentMethods = [
            PaymentMethod(
                id: UUID(),
                customerId: UUID(),
                type: .card,
                last4: "4242",
                brand: "Visa",
                isDefault: true,
                createdAt: Date()
            ),
            PaymentMethod(
                id: UUID(),
                customerId: UUID(),
                type: .card,
                last4: "5555",
                brand: "Mastercard",
                isDefault: false,
                createdAt: Date()
            )
        ]
        
        // Mock Usage Data
        usageData = (1...30).map { day in
            UsageDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -30 + day, to: Date())!,
                requests: Int.random(in: 100...500)
            )
        }
        
        // Mock Cost Breakdown
        costBreakdown = [
            CostItem(category: "Base Plan", amount: 29, color: .blue),
            CostItem(category: "Overage", amount: 12, color: .orange),
            CostItem(category: "Add-ons", amount: 5, color: .purple)
        ]
        
        // Mock Invoices
        invoices = (0..<12).map { i in
            let subtotal = Decimal(Int.random(in: 29...150))
            let tax = subtotal * 0.08
            let total = subtotal + tax
            
            return Invoice(
                id: UUID(),
                customerId: UUID(),
                subscriptionId: UUID(),
                number: "INV-\(1000 + i)",
                amount: subtotal,
                tax: tax,
                total: total,
                currency: "USD",
                status: [.paid, .pending, .failed].randomElement()!,
                dueDate: Date(),
                items: [
                    Invoice.InvoiceItem(description: "Basic Plan", quantity: 1, unitPrice: subtotal, amount: subtotal)
                ],
                createdAt: Calendar.current.date(byAdding: .month, value: -i, to: Date())!
            )
        }
        
        // Mock Current Plan
        currentPlan = billingService.plans.first(where: { $0.tier == .pro })
    }
}

// MARK: - Data Models
// SubscriptionPlan and PaymentMethod are defined in BillingModels.swift

struct UsageDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let requests: Int
}

struct CostItem: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}
