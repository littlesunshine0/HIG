import SwiftUI

/// Elite Authorization Dashboard with role management and permission matrix
struct AuthorizationDashboardView: View {
    @StateObject private var authService = AuthorizationService.shared
    @State private var selectedRole: Role?
    @State private var showRoleEditor = false
    @State private var showPermissionMatrix = false
    @State private var searchText = ""
    @State private var filterScope: FilterScope = .all
    
    enum FilterScope: String, CaseIterable {
        case all = "All"
        case roles = "Roles"
        case users = "Users"
        case permissions = "Permissions"
    }
    
    // Helper to convert dictionary to sorted array for UI iteration
    private var sortedRoles: [Role] {
        Array(authService.roles.values).sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            sidebarContent
        } content: {
            // Main content
            mainContent
        } detail: {
            // Detail view
            detailContent
        }
        .navigationTitle("Authorization")
        .sheet(isPresented: $showRoleEditor) {
            RoleEditorSheet(role: selectedRole)
        }
        .sheet(isPresented: $showPermissionMatrix) {
            PermissionMatrixSheet()
        }
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedRole) {
            Section("Quick Actions") {
                Button(action: { showRoleEditor = true }) {
                    Label("Create Role", systemImage: "plus.circle.fill")
                }
                
                Button(action: { showPermissionMatrix = true }) {
                    Label("Permission Matrix", systemImage: "square.grid.3x3.fill")
                }
            }
            
            Section("Roles") {
                ForEach(sortedRoles) { role in
                    RoleRow(role: role)
                        .tag(role)
                }
            }
            
            Section("Statistics") {
                AuthzStatRow(label: "Total Roles", value: "\(authService.roles.count)")
                AuthzStatRow(label: "Active Users", value: "\(authService.activeUserCount)")
                AuthzStatRow(label: "Permissions", value: "\(Permission.Action.allCases.count)")
            }
        }
        .searchable(text: $searchText)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Filter bar
            Picker("Scope", selection: $filterScope) {
                ForEach(FilterScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if let role = selectedRole {
                RoleDetailView(role: role)
            } else {
                RoleOverviewView()
            }
        }
    }
    
    private var detailContent: some View {
        Group {
            if let role = selectedRole {
                RolePermissionsView(role: role)
            } else {
                ContentUnavailableView(
                    "Select a Role",
                    systemImage: "person.3.fill",
                    description: Text("Choose a role to view its permissions and assigned users")
                )
            }
        }
    }
}

// MARK: - Role Editor Sheet
struct RoleEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthorizationService.shared
    
    let role: Role?
    @State private var name = ""
    @State private var description = ""
    @State private var selectedPermissionTypes: Set<PermissionType> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Role Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Permissions") {
                    ForEach(PermissionType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { selectedPermissionTypes.contains(type) },
                            set: { isOn in
                                if isOn {
                                    selectedPermissionTypes.insert(type)
                                } else {
                                    selectedPermissionTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(role == nil ? "Create Role" : "Edit Role")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRole()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let role = role {
                name = role.name
                description = role.description
                // Map existing complex permissions back to simplified UI types
                let mappedTypes = role.permissions.compactMap { perm -> PermissionType? in
                    return PermissionType.allCases.first { $0.actionMapping == perm.action }
                }
                selectedPermissionTypes = Set(mappedTypes)
            }
        }
    }
    
    private func saveRole() {
        // Convert UI permission types to Model permissions
        let permissions = selectedPermissionTypes.map { type in
            Permission(
                id: UUID(),
                resource: "*", // Global resource for simplicity
                action: type.actionMapping,
                scope: .global,
                conditions: []
            )
        }
        
        let newRole = Role(
            id: role?.id ?? UUID(),
            name: name,
            description: description,
            permissions: Set(permissions),
            parentRoleId: nil,
            isSystemRole: false,
            createdAt: role?.createdAt ?? Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        authService.createRole(newRole)
    }
}

// MARK: - Permission Matrix Sheet
struct PermissionMatrixSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthorizationService.shared
    
    var sortedRoles: [Role] {
        Array(authService.roles.values).sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("Role")
                            .frame(width: 150, alignment: .leading)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                        
                        ForEach(PermissionType.allCases, id: \.self) { permission in
                            Text(permission.rawValue)
                                .frame(width: 100)
                                .padding()
                                .background(Color.accentColor.opacity(0.1))
                        }
                    }
                    
                    // Role rows
                    ForEach(sortedRoles) { role in
                        HStack(spacing: 0) {
                            Text(role.name)
                                .frame(width: 150, alignment: .leading)
                                .padding()
                                .background(Color.secondary.opacity(0.05))
                            
                            ForEach(PermissionType.allCases, id: \.self) { type in
                                let hasPermission = role.permissions.contains { $0.action == type.actionMapping }
                                Image(systemName: hasPermission ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(hasPermission ? .green : .secondary)
                                    .frame(width: 100)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Permission Matrix")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct RoleRow: View {
    let role: Role
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(role.name)
                .font(.headline)
            Text("\(role.permissions.count) permissions")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AuthzStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct RoleDetailView: View {
    let role: Role
    
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Name", value: role.name)
                LabeledContent("Description", value: role.description)
                LabeledContent("Created", value: role.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
            
            Section("Permissions (\(role.permissions.count))") {
                ForEach(Array(role.permissions)) { permission in
                    Label(permission.displayName, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

struct RoleOverviewView: View {
    @StateObject private var authService = AuthorizationService.shared
    
    var sortedRoles: [Role] {
        Array(authService.roles.values).sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(sortedRoles) { role in
                    RoleCard(role: role)
                }
            }
            .padding()
        }
    }
}

struct RoleCard: View {
    let role: Role
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
            
            Text(role.name)
                .font(.headline)
            
            Text(role.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Divider()
            
            Text("\(role.permissions.count) permissions")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RolePermissionsView: View {
    let role: Role
    
    var body: some View {
        List {
            Section("Assigned Permissions") {
                ForEach(Array(role.permissions)) { permission in
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        Text(permission.displayName)
                    }
                }
            }
        }
    }
}

// MARK: - Mock Data Extensions
extension AuthorizationService {
    var activeUserCount: Int { 
        userRoles.values.flatMap { $0 }.filter { $0.isActive && !$0.isExpired }.count
    }
}

enum PermissionType: String, CaseIterable {
    case read = "Read"
    case write = "Write"
    case delete = "Delete"
    case admin = "Admin"
    case billing = "Billing"
    case analytics = "Analytics"
    case userManagement = "User Management"
    case apiAccess = "API Access"
    
    // Mapping to backend Action model
    var actionMapping: Permission.Action {
        switch self {
        case .read: return .read
        case .write: return .update
        case .delete: return .delete
        case .admin: return .manage
        case .billing: return .read
        case .analytics: return .read
        case .userManagement: return .manage
        case .apiAccess: return .execute
        }
    }
}
