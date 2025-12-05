//
//  DatabaseDashboardView.swift
//  HIG
//

import SwiftUI
import Charts

struct DatabaseDashboardView: View {
    @StateObject private var service = DatabaseService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cylinder.split.1x2.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.purple)
                Text("Database Management")
                    .appText(.title, weight: .bold)
                Spacer()
                
                // Quick Stats
                HStack(spacing: DSSpacing.lg) {
                    DatabaseStatBadge(label: "Connections", value: "\(service.connections.count)", color: Color.purple)
                    DatabaseStatBadge(label: "Queries", value: "\(service.queries.count)", color: Color.blue)
                    DatabaseStatBadge(label: "Backups", value: "\(service.backups.count)", color: Color.green)
                }
            }
            .padding(DSSpacing.lg)
            
            Divider()
            
            // Tabs
            Picker("View", selection: $selectedTab) {
                Text("Connections").tag(0)
                Text("Queries").tag(1)
                Text("Backups").tag(2)
                Text("Performance").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(DSSpacing.md)
            
            // Content
            TabView(selection: $selectedTab) {
                ConnectionsView(service: service).tag(0)
                QueriesView(service: service).tag(1)
                BackupsView(service: service).tag(2)
                PerformanceView(service: service).tag(3)
            }
            .tabViewStyle(.automatic)
        }
    }
}

struct ConnectionsView: View {
    @ObservedObject var service: DatabaseService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(Array(service.connections.values)) { connection in
                    ConnectionCard(connection: connection)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct ConnectionCard: View {
    let connection: DatabaseConnection
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: "cylinder.fill")
                    .foregroundStyle(statusColor)
                Text(connection.name)
                    .appText(.body, weight: .semibold)
                Spacer()
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(connection.status.rawValue)
                    .appText(.caption)
            }
            
            HStack(spacing: DSSpacing.xl) {
                InfoItem(label: "Type", value: connection.type.rawValue)
                InfoItem(label: "Host", value: connection.host)
                InfoItem(label: "Pool", value: "\(connection.activeConnections)/\(connection.poolSize)")
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private var statusColor: Color {
        switch connection.status {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected, .error: return .red
        }
    }
}

struct QueriesView: View {
    @ObservedObject var service: DatabaseService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                ForEach(service.queries.suffix(50).reversed()) { query in
                    QueryRow(query: query)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct QueryRow: View {
    let query: QueryLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(query.query)
                .appText(.body, weight: .medium)
                .lineLimit(2)
            
            HStack {
                Text(String(format: "%.2fms", query.duration * 1000))
                    .appText(.caption, color: .secondary)
                Text("•")
                    .appText(.caption, color: .secondary)
                Text("\(query.rowsAffected) rows")
                    .appText(.caption, color: .secondary)
                Spacer()
                Image(systemName: query.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(query.success ? .green : .red)
            }
        }
        .padding(DSSpacing.sm)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

struct BackupsView: View {
    @ObservedObject var service: DatabaseService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(service.backups) { backup in
                    BackupCard(backup: backup)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct BackupCard: View {
    let backup: DatabaseBackup
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: "archivebox.fill")
                .font(.system(size: 32))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(backup.name)
                    .appText(.body, weight: .semibold)
                Text("\(backup.type.rawValue) • \(ByteCountFormatter.string(fromByteCount: backup.size, countStyle: .file))")
                    .appText(.caption, color: .secondary)
            }
            
            Spacer()
            
            Text(backup.status.rawValue)
                .appText(.caption)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(statusColor.opacity(0.1), in: Capsule())
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private var statusColor: Color {
        switch backup.status {
        case .completed: return .green
        case .inProgress: return .orange
        case .failed: return .red
        case .pending: return .gray
        }
    }
}

struct PerformanceView: View {
    @ObservedObject var service: DatabaseService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text("Performance Metrics")
                    .appText(.heading, weight: .bold)
                
                Text("Real-time monitoring coming soon")
                    .appText(.body, color: .secondary)
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct InfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(label)
                .appText(.caption, color: .secondary)
            Text(value)
                .appText(.body, weight: .medium)
        }
    }
}

// Database-specific stat badge
struct DatabaseStatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(value)
                .appText(.title, weight: .bold)
                .foregroundStyle(color)
            Text(label)
                .appText(.caption, color: .secondary)
        }
    }
}

#Preview {
    DatabaseDashboardView()
        .frame(width: 1200, height: 800)
}
