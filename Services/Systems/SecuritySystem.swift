//
//  SecuritySystem.swift
//  HIG
//
//  Security System - Encryption, auth, permissions
//

import SwiftUI

struct SecuritySystemView: View {
    @State private var selectedTab = "Auth"
    
    let tabs = ["Auth", "Encryption", "Permissions", "Audit"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "shield.fill").font(.title2).foregroundStyle(.red)
                Text("Security System").font(.title2.bold())
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill").foregroundStyle(.green)
                    Text("Secure").font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.green.opacity(0.2)))
            }
            .padding()
            .background(.regularMaterial)
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 20).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.red.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case "Auth": AuthenticationView()
                case "Encryption": EncryptionView()
                case "Permissions": PermissionsView()
                case "Audit": AuditLogView()
                default: EmptyView()
                }
            }
        }
    }
}

struct AuthenticationView: View {
    @State private var authMethod = "JWT"
    @State private var mfaEnabled = true
    @State private var sessionTimeout = 30
    
    var body: some View {
        HSplitView {
            // Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("Authentication Settings").font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Method").font(.subheadline)
                    Picker("", selection: $authMethod) {
                        Text("JWT").tag("JWT")
                        Text("OAuth 2.0").tag("OAuth 2.0")
                        Text("SAML").tag("SAML")
                        Text("API Key").tag("API Key")
                    }
                    .pickerStyle(.segmented)
                }
                
                Divider()
                
                Toggle("Multi-Factor Authentication", isOn: $mfaEnabled)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Timeout: \(sessionTimeout) minutes")
                    Slider(value: Binding(get: { Double(sessionTimeout) }, set: { sessionTimeout = Int($0) }), in: 5...120, step: 5)
                }
                
                Divider()
                
                Text("Password Policy").font(.subheadline)
                VStack(alignment: .leading, spacing: 6) {
                    PolicyRow(label: "Minimum length", value: "8 characters", met: true)
                    PolicyRow(label: "Uppercase required", value: "Yes", met: true)
                    PolicyRow(label: "Numbers required", value: "Yes", met: true)
                    PolicyRow(label: "Special characters", value: "Yes", met: true)
                    PolicyRow(label: "Password expiry", value: "90 days", met: true)
                }
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 350)
            
            // Active Sessions
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Active Sessions").font(.headline)
                    Spacer()
                    Button("Revoke All") {}.buttonStyle(.bordered).tint(.red)
                }
                
                List {
                    ForEach(0..<5, id: \.self) { i in
                        HStack {
                            Image(systemName: i == 0 ? "desktopcomputer" : "iphone")
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading) {
                                Text(i == 0 ? "MacBook Pro" : "iPhone \(12 + i)")
                                    .font(.subheadline)
                                Text(i == 0 ? "Current session" : "\(i * 2) hours ago")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if i == 0 {
                                Text("Current").font(.caption).foregroundStyle(.green)
                            } else {
                                Button("Revoke") {}.buttonStyle(.bordered).controlSize(.small)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .padding()
        }
    }
}

struct PolicyRow: View {
    let label: String
    let value: String
    let met: Bool
    
    var body: some View {
        HStack {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(met ? .green : .red)
            Text(label).font(.caption)
            Spacer()
            Text(value).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct EncryptionView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Encryption Status
            HStack(spacing: 40) {
                EncryptionCard(title: "Data at Rest", status: "AES-256", icon: "lock.fill", color: .green)
                EncryptionCard(title: "Data in Transit", status: "TLS 1.3", icon: "arrow.left.arrow.right", color: .green)
                EncryptionCard(title: "Key Management", status: "HSM", icon: "key.fill", color: .green)
            }
            
            Divider()
            
            // Key Management
            VStack(alignment: .leading, spacing: 16) {
                Text("Encryption Keys").font(.headline)
                
                List {
                    KeyRow(name: "Master Key", type: "AES-256", created: "Jan 1, 2024", status: "Active")
                    KeyRow(name: "Data Key", type: "AES-256", created: "Jan 1, 2024", status: "Active")
                    KeyRow(name: "API Key", type: "RSA-4096", created: "Mar 15, 2024", status: "Active")
                    KeyRow(name: "Backup Key", type: "AES-256", created: "Jan 1, 2024", status: "Rotated")
                }
                .listStyle(.plain)
            }
            .padding()
            
            HStack {
                Button("Generate New Key") {}.buttonStyle(.bordered)
                Button("Rotate Keys") {}.buttonStyle(.borderedProminent).tint(.red)
            }
        }
        .padding()
    }
}

struct EncryptionCard: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.title).foregroundStyle(color)
            Text(title).font(.subheadline)
            Text(status).font(.caption.bold()).foregroundStyle(color)
        }
        .frame(width: 150, height: 120)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct KeyRow: View {
    let name: String
    let type: String
    let created: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: "key.fill").foregroundStyle(.yellow)
            VStack(alignment: .leading) {
                Text(name).font(.subheadline)
                Text(type).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Text(created).font(.caption).foregroundStyle(.secondary)
            Text(status).font(.caption)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(status == "Active" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)))
        }
    }
}

struct PermissionsView: View {
    let roles = ["Admin", "Editor", "Viewer", "Guest"]
    @State private var selectedRole = "Editor"
    
    var body: some View {
        HSplitView {
            // Roles
            VStack(spacing: 0) {
                HStack {
                    Text("Roles").font(.headline)
                    Spacer()
                    Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                
                List(roles, id: \.self, selection: $selectedRole) { role in
                    HStack {
                        Image(systemName: "person.badge.key.fill").foregroundStyle(roleColor(role))
                        Text(role)
                        Spacer()
                        Text("\(roleUserCount(role)) users").font(.caption).foregroundStyle(.secondary)
                    }
                    .tag(role)
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 220)
            
            // Permissions
            VStack(alignment: .leading, spacing: 16) {
                Text("Permissions: \(selectedRole)").font(.headline)
                
                List {
                    PermissionSection(title: "Users", permissions: [
                        ("View users", selectedRole != "Guest"),
                        ("Create users", selectedRole == "Admin"),
                        ("Edit users", selectedRole == "Admin" || selectedRole == "Editor"),
                        ("Delete users", selectedRole == "Admin"),
                    ])
                    
                    PermissionSection(title: "Content", permissions: [
                        ("View content", true),
                        ("Create content", selectedRole != "Guest"),
                        ("Edit content", selectedRole != "Guest" && selectedRole != "Viewer"),
                        ("Delete content", selectedRole == "Admin"),
                        ("Publish content", selectedRole == "Admin" || selectedRole == "Editor"),
                    ])
                    
                    PermissionSection(title: "Settings", permissions: [
                        ("View settings", selectedRole != "Guest"),
                        ("Edit settings", selectedRole == "Admin"),
                        ("Manage integrations", selectedRole == "Admin"),
                    ])
                }
                .listStyle(.plain)
            }
            .padding()
        }
    }
    
    func roleColor(_ role: String) -> Color {
        switch role {
        case "Admin": return .red
        case "Editor": return .blue
        case "Viewer": return .green
        default: return .secondary
        }
    }
    
    func roleUserCount(_ role: String) -> Int {
        switch role {
        case "Admin": return 3
        case "Editor": return 12
        case "Viewer": return 45
        default: return 100
        }
    }
}

struct PermissionSection: View {
    let title: String
    let permissions: [(String, Bool)]
    
    var body: some View {
        Section(title) {
            ForEach(permissions, id: \.0) { permission in
                HStack {
                    Image(systemName: permission.1 ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(permission.1 ? .green : .secondary)
                    Text(permission.0).font(.subheadline)
                }
            }
        }
    }
}

struct AuditLogView: View {
    let logs = [
        ("User login", "john@example.com", "Success", "2 min ago"),
        ("Password change", "jane@example.com", "Success", "15 min ago"),
        ("Failed login", "unknown@test.com", "Failed", "1 hour ago"),
        ("Role change", "bob@example.com", "Success", "2 hours ago"),
        ("API key created", "admin@example.com", "Success", "3 hours ago"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Audit Log").font(.headline)
                Spacer()
                Button("Export") {}.buttonStyle(.bordered)
                Button("Filter") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(logs, id: \.0) { log in
                    HStack {
                        Image(systemName: log.2 == "Success" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(log.2 == "Success" ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text(log.0).font(.subheadline)
                            Text(log.1).font(.caption2).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(log.2).font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(log.2 == "Success" ? Color.green.opacity(0.2) : Color.red.opacity(0.2)))
                        
                        Text(log.3).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    SecuritySystemView()
        .frame(width: 1000, height: 700)
}
