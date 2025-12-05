//
//  AuthorizationSystem.swift
//  HIG
//
//  Authorization / Permissions System - RBAC, ACL
//

import SwiftUI

struct AuthorizationSystemView: View {
    @State private var selectedTab = "Roles"
    @State private var roles: [SystemRole] = SystemRole.samples
    @State private var selectedRole: SystemRole?
    
    let tabs = ["Roles", "Permissions", "ACL", "Policies"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "person.badge.shield.checkmark.fill").font(.title2).foregroundStyle(.purple)
                Text("Authorization System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.purple.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Roles": RolesView(roles: $roles, selectedRole: $selectedRole)
                case "Permissions": PermissionsMatrixView()
                case "ACL": ACLView()
                case "Policies": PoliciesView()
                default: EmptyView()
                }
            }
        }
    }
}

struct RolesView: View {
    @Binding var roles: [SystemRole]
    @Binding var selectedRole: SystemRole?
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                HStack {
                    Text("Roles").font(.headline)
                    Spacer()
                    Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                }
                .padding()
                Divider()
                
                List(roles, selection: $selectedRole) { role in
                    HStack {
                        Circle().fill(role.color).frame(width: 12)
                        VStack(alignment: .leading) {
                            Text(role.name).font(.subheadline)
                            Text("\(role.userCount) users").font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if role.isSystem { Text("System").font(.caption2).foregroundStyle(.secondary) }
                    }
                    .tag(role)
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 220)
            
            if let role = selectedRole {
                SystemRoleDetailView(role: role)
            } else {
                VStack { Image(systemName: "shield").font(.system(size: 60)).foregroundStyle(.secondary); Text("Select a role") }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct SystemRoleDetailView: View {
    let role: SystemRole
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Circle().fill(role.color).frame(width: 40)
                    VStack(alignment: .leading) {
                        Text(role.name).font(.title2.bold())
                        Text(role.description).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Edit") {}.buttonStyle(.bordered)
                }
                
                Divider()
                
                Text("Permissions").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                    ForEach(role.permissions, id: \.self) { perm in
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(perm).font(.caption)
                            Spacer()
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color(.controlBackgroundColor)))
                    }
                }
                
                Divider()
                
                Text("Users with this role").font(.headline)
                HStack {
                    ForEach(0..<min(5, role.userCount), id: \.self) { i in
                        Circle().fill(Color.blue).frame(width: 32).overlay(Text("\(i+1)").font(.caption2).foregroundStyle(.white))
                    }
                    if role.userCount > 5 { Text("+\(role.userCount - 5)").font(.caption).foregroundStyle(.secondary) }
                }
            }
            .padding()
        }
    }
}

struct PermissionsMatrixView: View {
    let resources = ["Users", "Posts", "Comments", "Files", "Settings"]
    let actions = ["Create", "Read", "Update", "Delete"]
    let roles = ["Admin", "Editor", "Viewer"]
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("Resource / Action").font(.caption.bold()).frame(width: 120, alignment: .leading).padding(8)
                    ForEach(roles, id: \.self) { role in
                        Text(role).font(.caption.bold()).frame(width: 80).padding(8)
                    }
                }
                .background(Color(.controlBackgroundColor))
                
                ForEach(resources, id: \.self) { resource in
                    ForEach(actions, id: \.self) { action in
                        HStack(spacing: 0) {
                            Text("\(resource).\(action)").font(.caption).frame(width: 120, alignment: .leading).padding(8)
                            ForEach(roles, id: \.self) { role in
                                Image(systemName: hasPermission(role, resource, action) ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(hasPermission(role, resource, action) ? .green : .secondary)
                                    .frame(width: 80).padding(8)
                            }
                        }
                        Divider()
                    }
                }
            }
        }
        .padding()
    }
    
    func hasPermission(_ role: String, _ resource: String, _ action: String) -> Bool {
        if role == "Admin" { return true }
        if role == "Editor" && action != "Delete" { return true }
        if role == "Viewer" && action == "Read" { return true }
        return false
    }
}

struct ACLView: View {
    let entries = [
        ("Document A", "user@example.com", "Read, Write"),
        ("Folder B", "team@company.com", "Read"),
        ("Project X", "admin@company.com", "Full Access"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Access Control List").font(.headline)
                Spacer()
                Button("Add Entry") {}.buttonStyle(.borderedProminent).tint(.purple)
            }
            
            List {
                ForEach(entries, id: \.0) { entry in
                    HStack {
                        Image(systemName: "doc.fill").foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(entry.0).font(.subheadline)
                            Text(entry.1).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(entry.2).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.purple.opacity(0.2)))
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct PoliciesView: View {
    let policies = [
        ("IP Whitelist", "Allow access only from approved IPs", true),
        ("Time-based Access", "Restrict access outside business hours", false),
        ("Device Trust", "Require managed devices", true),
        ("Geo-restriction", "Block access from certain countries", false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Security Policies").font(.headline)
                Spacer()
                Button("Create Policy") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(policies, id: \.0) { policy in
                    HStack {
                        Image(systemName: "shield.fill").foregroundStyle(policy.2 ? .green : .secondary)
                        VStack(alignment: .leading) {
                            Text(policy.0).font(.subheadline)
                            Text(policy.1).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: .constant(policy.2)).labelsHidden()
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct SystemRole: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let color: Color
    let permissions: [String]
    let userCount: Int
    let isSystem: Bool
    
    static var samples: [SystemRole] {
        [
            SystemRole(name: "Super Admin", description: "Full system access", color: .red, permissions: ["users.manage", "settings.manage", "billing.manage", "roles.manage"], userCount: 2, isSystem: true),
            SystemRole(name: "Admin", description: "Administrative access", color: .orange, permissions: ["users.manage", "content.manage", "reports.view"], userCount: 5, isSystem: true),
            SystemRole(name: "Editor", description: "Content management", color: .blue, permissions: ["content.create", "content.edit", "content.publish"], userCount: 15, isSystem: false),
            SystemRole(name: "Viewer", description: "Read-only access", color: .green, permissions: ["content.view", "reports.view"], userCount: 50, isSystem: false),
        ]
    }
}

#Preview { AuthorizationSystemView().frame(width: 1000, height: 700) }
