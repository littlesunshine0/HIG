//
//  DatabaseSystem.swift
//  HIG
//
//  Database System - Core Data, SQLite, cloud sync
//

import SwiftUI

struct DatabaseSystemView: View {
    @State private var selectedTab = "Schema"
    @State private var tables: [DatabaseTable] = DatabaseTable.samples
    @State private var selectedTable: DatabaseTable?
    @State private var queryText = "SELECT * FROM users WHERE active = true"
    @State private var queryResults: [[String: String]] = []
    
    let tabs = ["Schema", "Query", "Migrations", "Sync"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cylinder.fill").font(.title2).foregroundStyle(.green)
                Text("Database System").font(.title2.bold())
                Spacer()
                
                HStack(spacing: 8) {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("Connected").font(.caption)
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
                            .background(selectedTab == tab ? Color.green.opacity(0.2) : Color.clear)
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
                case "Schema": SchemaView(tables: tables, selectedTable: $selectedTable)
                case "Query": QueryView(queryText: $queryText, results: $queryResults)
                case "Migrations": MigrationsView()
                case "Sync": SyncView()
                default: EmptyView()
                }
            }
        }
    }
}

struct SchemaView: View {
    let tables: [DatabaseTable]
    @Binding var selectedTable: DatabaseTable?
    
    var body: some View {
        HSplitView {
            // Tables List
            VStack(spacing: 0) {
                HStack {
                    Text("Tables").font(.headline)
                    Spacer()
                    Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                
                List(tables, selection: $selectedTable) { table in
                    HStack {
                        Image(systemName: "tablecells").foregroundStyle(.green)
                        VStack(alignment: .leading) {
                            Text(table.name).font(.subheadline)
                            Text("\(table.columns.count) columns • \(table.rowCount) rows").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .tag(table)
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 220)
            
            // Table Detail
            if let table = selectedTable {
                VStack(spacing: 0) {
                    // Table Header
                    HStack {
                        Text(table.name).font(.title3.bold())
                        Spacer()
                        Button("Edit") {}.buttonStyle(.bordered)
                        Button("Drop") {}.buttonStyle(.bordered).tint(.red)
                    }
                    .padding()
                    
                    Divider()
                    
                    // Columns
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Column").font(.caption.bold()).frame(width: 150, alignment: .leading)
                            Text("Type").font(.caption.bold()).frame(width: 100, alignment: .leading)
                            Text("Nullable").font(.caption.bold()).frame(width: 80, alignment: .leading)
                            Text("Key").font(.caption.bold()).frame(width: 80, alignment: .leading)
                            Text("Default").font(.caption.bold()).frame(width: 100, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.controlBackgroundColor))
                        
                        ForEach(table.columns) { column in
                            HStack {
                                HStack(spacing: 4) {
                                    if column.isPrimaryKey {
                                        Image(systemName: "key.fill").font(.caption2).foregroundStyle(.yellow)
                                    }
                                    Text(column.name).font(.caption)
                                }
                                .frame(width: 150, alignment: .leading)
                                
                                Text(column.type).font(.caption).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
                                Text(column.nullable ? "Yes" : "No").font(.caption).frame(width: 80, alignment: .leading)
                                Text(column.isPrimaryKey ? "PK" : (column.isForeignKey ? "FK" : "-")).font(.caption).frame(width: 80, alignment: .leading)
                                Text(column.defaultValue ?? "-").font(.caption).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            
                            Divider()
                        }
                    }
                    
                    Spacer()
                    
                    // Indexes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Indexes").font(.headline)
                        HStack {
                            ForEach(table.indexes, id: \.self) { index in
                                Text(index).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Color.green.opacity(0.2)))
                            }
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    Image(systemName: "tablecells").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("Select a table").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct QueryView: View {
    @Binding var queryText: String
    @Binding var results: [[String: String]]
    @State private var isExecuting = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Query Editor
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Query").font(.headline)
                    Spacer()
                    Button("Format") {}.buttonStyle(.bordered)
                    Button {
                        executeQuery()
                    } label: {
                        Label("Execute", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                
                TextEditor(text: $queryText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 120)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.textBackgroundColor)))
            }
            .padding()
            
            Divider()
            
            // Results
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Results").font(.headline)
                    Spacer()
                    if !results.isEmpty {
                        Text("\(results.count) rows").font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                if results.isEmpty {
                    VStack {
                        Image(systemName: "doc.text.magnifyingglass").font(.title).foregroundStyle(.secondary)
                        Text("Execute a query to see results").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header
                            HStack(spacing: 0) {
                                ForEach(Array(results.first?.keys ?? [:].keys), id: \.self) { key in
                                    Text(key).font(.caption.bold()).frame(width: 120, alignment: .leading).padding(8)
                                }
                            }
                            .background(Color(.controlBackgroundColor))
                            
                            // Rows
                            ForEach(results.indices, id: \.self) { index in
                                HStack(spacing: 0) {
                                    ForEach(Array(results[index].keys), id: \.self) { key in
                                        Text(results[index][key] ?? "").font(.caption).frame(width: 120, alignment: .leading).padding(8)
                                    }
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    func executeQuery() {
        isExecuting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            results = [
                ["id": "1", "name": "John Doe", "email": "john@example.com", "active": "true"],
                ["id": "2", "name": "Jane Smith", "email": "jane@example.com", "active": "true"],
                ["id": "3", "name": "Bob Wilson", "email": "bob@example.com", "active": "true"],
            ]
            isExecuting = false
        }
    }
}

struct MigrationsView: View {
    let migrations = [
        ("001_create_users", "Applied", "Nov 1, 2024"),
        ("002_add_email_index", "Applied", "Nov 5, 2024"),
        ("003_create_products", "Applied", "Nov 10, 2024"),
        ("004_add_categories", "Pending", "-"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Migrations").font(.headline)
                Spacer()
                Button("Create Migration") {}.buttonStyle(.bordered)
                Button("Run Pending") {}.buttonStyle(.borderedProminent).tint(.green)
            }
            
            List {
                ForEach(migrations, id: \.0) { migration in
                    HStack {
                        Image(systemName: migration.1 == "Applied" ? "checkmark.circle.fill" : "clock")
                            .foregroundStyle(migration.1 == "Applied" ? .green : .orange)
                        
                        VStack(alignment: .leading) {
                            Text(migration.0).font(.subheadline)
                            Text(migration.2).font(.caption2).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(migration.1).font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(migration.1 == "Applied" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)))
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct SyncView: View {
    @State private var syncStatus = "Synced"
    @State private var lastSync = "2 minutes ago"
    
    var body: some View {
        VStack(spacing: 20) {
            // Status
            VStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                
                Text("Cloud Sync").font(.title2.bold())
                
                HStack {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text(syncStatus)
                }
                
                Text("Last synced: \(lastSync)").font(.caption).foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Sync Settings
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Auto-sync enabled", isOn: .constant(true))
                Toggle("Sync on Wi-Fi only", isOn: .constant(false))
                Toggle("Background sync", isOn: .constant(true))
                
                Picker("Sync frequency", selection: .constant("5 minutes")) {
                    Text("1 minute").tag("1 minute")
                    Text("5 minutes").tag("5 minutes")
                    Text("15 minutes").tag("15 minutes")
                    Text("Manual").tag("Manual")
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Button("Sync Now") {}
                .buttonStyle(.borderedProminent)
                .tint(.green)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

struct DatabaseTable: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let columns: [DatabaseColumn]
    let rowCount: Int
    let indexes: [String]
    
    static var samples: [DatabaseTable] {
        [
            DatabaseTable(name: "users", columns: [
                DatabaseColumn(name: "id", type: "INTEGER", nullable: false, isPrimaryKey: true, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "name", type: "VARCHAR(255)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "email", type: "VARCHAR(255)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "active", type: "BOOLEAN", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: "true"),
                DatabaseColumn(name: "created_at", type: "TIMESTAMP", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: "NOW()"),
            ], rowCount: 1250, indexes: ["idx_users_email", "idx_users_active"]),
            DatabaseTable(name: "products", columns: [
                DatabaseColumn(name: "id", type: "INTEGER", nullable: false, isPrimaryKey: true, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "name", type: "VARCHAR(255)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "price", type: "DECIMAL(10,2)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "category_id", type: "INTEGER", nullable: true, isPrimaryKey: false, isForeignKey: true, defaultValue: nil),
            ], rowCount: 450, indexes: ["idx_products_category"]),
            DatabaseTable(name: "orders", columns: [
                DatabaseColumn(name: "id", type: "INTEGER", nullable: false, isPrimaryKey: true, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "user_id", type: "INTEGER", nullable: false, isPrimaryKey: false, isForeignKey: true, defaultValue: nil),
                DatabaseColumn(name: "total", type: "DECIMAL(10,2)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: nil),
                DatabaseColumn(name: "status", type: "VARCHAR(50)", nullable: false, isPrimaryKey: false, isForeignKey: false, defaultValue: "'pending'"),
            ], rowCount: 3200, indexes: ["idx_orders_user", "idx_orders_status"]),
        ]
    }
}

struct DatabaseColumn: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: String
    let nullable: Bool
    let isPrimaryKey: Bool
    let isForeignKey: Bool
    let defaultValue: String?
}

#Preview {
    DatabaseSystemView()
        .frame(width: 1000, height: 700)
}
