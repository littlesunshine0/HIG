//
//  ActivityAuditSystem.swift
//  HIG
//
//  Activity / Audit Log System - Track user actions for security and history
//

import SwiftUI

struct ActivityAuditSystemView: View {
    @State private var selectedTab = "Activity"
    @State private var activities: [ActivityLog] = ActivityLog.samples
    @State private var filterType = "All"
    
    let tabs = ["Activity", "Audit", "Security", "Export"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock.arrow.circlepath").font(.title2).foregroundStyle(.mint)
                Text("Activity & Audit System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.mint.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Activity": ActivityFeedView(activities: activities, filterType: $filterType)
                case "Audit": AuditTrailView()
                case "Security": SecurityEventsView()
                case "Export": AuditExportView()
                default: EmptyView()
                }
            }
        }
    }
}

struct ActivityFeedView: View {
    let activities: [ActivityLog]
    @Binding var filterType: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search activities...", text: .constant("")).textFieldStyle(.roundedBorder).frame(width: 250)
                
                Picker("Type", selection: $filterType) {
                    Text("All").tag("All")
                    Text("Create").tag("Create")
                    Text("Update").tag("Update")
                    Text("Delete").tag("Delete")
                    Text("Login").tag("Login")
                }
                .frame(width: 120)
                
                Spacer()
                
                Button("Refresh") {}.buttonStyle(.bordered)
            }
            .padding()
            
            List {
                ForEach(activities) { activity in
                    AuditActivityRow(activity: activity)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct AuditActivityRow: View {
    let activity: ActivityLog
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(activity.type.color.opacity(0.2)).frame(width: 40, height: 40)
                Image(systemName: activity.type.icon).foregroundStyle(activity.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(activity.user).font(.subheadline.bold())
                    Text(activity.action).font(.subheadline)
                }
                Text(activity.target).font(.caption).foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Label(activity.timeAgo, systemImage: "clock").font(.caption2)
                    if let ip = activity.ipAddress {
                        Label(ip, systemImage: "network").font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(activity.type.rawValue).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(activity.type.color.opacity(0.2)))
        }
        .padding(.vertical, 8)
    }
}

struct AuditTrailView: View {
    let auditEntries = [
        ("Document updated", "contract.pdf", "john@example.com", "Field 'status' changed from 'draft' to 'published'"),
        ("Permission changed", "Project Alpha", "admin@example.com", "Added 'Editor' role to jane@example.com"),
        ("Settings modified", "Security Settings", "admin@example.com", "MFA requirement enabled"),
        ("Record deleted", "User #1234", "admin@example.com", "Soft delete performed"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Audit Trail").font(.headline)
                Spacer()
                Button("Filter") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(auditEntries, id: \.0) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(entry.0).font(.subheadline.bold())
                            Spacer()
                            Text("2 hours ago").font(.caption).foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label(entry.1, systemImage: "doc").font(.caption)
                            Text("•").foregroundStyle(.secondary)
                            Text(entry.2).font(.caption).foregroundStyle(.secondary)
                        }
                        
                        Text(entry.3).font(.caption).foregroundStyle(.secondary)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color(.controlBackgroundColor)))
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct SecurityEventsView: View {
    let events = [
        ("Login successful", "john@example.com", "Chrome / macOS", "192.168.1.1", true),
        ("Failed login attempt", "unknown@test.com", "Firefox / Windows", "10.0.0.5", false),
        ("Password changed", "jane@example.com", "Safari / iOS", "172.16.0.1", true),
        ("MFA enabled", "bob@example.com", "Chrome / macOS", "192.168.1.2", true),
        ("Suspicious activity", "admin@example.com", "Unknown", "45.33.32.156", false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Security Events").font(.headline)
                Spacer()
                
                HStack(spacing: 8) {
                    Circle().fill(.green).frame(width: 8)
                    Text("Normal").font(.caption)
                    Circle().fill(.red).frame(width: 8)
                    Text("Alert").font(.caption)
                }
            }
            
            List {
                ForEach(events, id: \.0) { event in
                    HStack {
                        Image(systemName: event.4 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .foregroundStyle(event.4 ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.0).font(.subheadline)
                            Text(event.1).font(.caption).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(event.2).font(.caption2)
                            Text(event.3).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct AuditExportView: View {
    @State private var dateRange = "Last 30 days"
    @State private var includeTypes: Set<String> = ["All"]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Export Audit Logs").font(.headline)
                
                HStack {
                    Text("Date Range").frame(width: 100, alignment: .leading)
                    Picker("", selection: $dateRange) {
                        Text("Last 7 days").tag("Last 7 days")
                        Text("Last 30 days").tag("Last 30 days")
                        Text("Last 90 days").tag("Last 90 days")
                        Text("Custom").tag("Custom")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Include").font(.subheadline)
                    HStack {
                        Toggle("Activity", isOn: .constant(true))
                        Toggle("Audit", isOn: .constant(true))
                        Toggle("Security", isOn: .constant(true))
                    }
                    .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Format").font(.subheadline)
                    HStack {
                        Button("CSV") {}.buttonStyle(.bordered)
                        Button("JSON") {}.buttonStyle(.bordered)
                        Button("PDF Report") {}.buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Button("Generate Export") {}.buttonStyle(.borderedProminent).tint(.mint)
            
            Spacer()
        }
        .padding()
    }
}

struct ActivityLog: Identifiable {
    let id = UUID()
    let user: String
    let action: String
    let target: String
    let type: ActivityType
    let timestamp: Date
    let ipAddress: String?
    
    enum ActivityType: String {
        case create = "Create"
        case update = "Update"
        case delete = "Delete"
        case login = "Login"
        case view = "View"
        
        var icon: String {
            switch self {
            case .create: return "plus.circle.fill"
            case .update: return "pencil.circle.fill"
            case .delete: return "trash.circle.fill"
            case .login: return "person.circle.fill"
            case .view: return "eye.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .create: return .green
            case .update: return .blue
            case .delete: return .red
            case .login: return .purple
            case .view: return .secondary
            }
        }
    }
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
    
    static var samples: [ActivityLog] {
        [
            ActivityLog(user: "John Doe", action: "created", target: "Project: Mobile App", type: .create, timestamp: Date().addingTimeInterval(-300), ipAddress: "192.168.1.1"),
            ActivityLog(user: "Jane Smith", action: "updated", target: "Document: Q4 Report", type: .update, timestamp: Date().addingTimeInterval(-1800), ipAddress: "10.0.0.5"),
            ActivityLog(user: "Bob Wilson", action: "logged in", target: "from Chrome / macOS", type: .login, timestamp: Date().addingTimeInterval(-3600), ipAddress: "172.16.0.1"),
            ActivityLog(user: "Alice Brown", action: "deleted", target: "Task: Old backlog item", type: .delete, timestamp: Date().addingTimeInterval(-7200), ipAddress: nil),
            ActivityLog(user: "Charlie Davis", action: "viewed", target: "Dashboard: Analytics", type: .view, timestamp: Date().addingTimeInterval(-14400), ipAddress: "192.168.1.50"),
        ]
    }
}

#Preview { ActivityAuditSystemView().frame(width: 900, height: 700) }
