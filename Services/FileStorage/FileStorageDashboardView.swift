//
//  FileStorageDashboardView.swift
//  HIG
//

import SwiftUI
import Charts

struct FileStorageDashboardView: View {
    @StateObject private var service = FileStorageService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "externaldrive.fill.badge.icloud")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
                Text("File Storage & CDN")
                    .appText(.title, weight: .bold)
                Spacer()
                
                // Quick Stats
                HStack(spacing: DSSpacing.lg) {
                    StorageStatBadge(label: "Files", value: "\(service.files.count)", color: .blue)
                    StorageStatBadge(label: "CDN Nodes", value: "\(service.cdnNodes.count)", color: .green)
                    StorageStatBadge(label: "Active Uploads", value: "\(service.uploads.values.filter { $0.status == .uploading }.count)", color: .orange)
                }
            }
            .padding(DSSpacing.lg)
            
            Divider()
            
            // Tabs
            Picker("View", selection: $selectedTab) {
                Text("Files").tag(0)
                Text("CDN").tag(1)
                Text("Analytics").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(DSSpacing.md)
            
            // Content
            TabView(selection: $selectedTab) {
                FilesView(service: service).tag(0)
                CDNView(service: service).tag(1)
                FileStorageAnalyticsView(service: service).tag(2)
            }
            .tabViewStyle(.automatic)
        }
    }
}

struct FilesView: View {
    @ObservedObject var service: FileStorageService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(Array(service.files.values)) { file in
                    StorageFileRow(file: file)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct StorageFileRow: View {
    let file: StoredFile
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: iconForFile(file))
                .font(.system(size: 32))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(file.filename)
                    .appText(.body, weight: .semibold)
                Text("\(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file)) • \(file.downloadCount) downloads")
                    .appText(.caption, color: .secondary)
            }
            
            Spacer()
            
            if !file.cdnUrl.isEmpty {
                Label("CDN", systemImage: "network")
                    .appText(.caption)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(.green.opacity(0.1), in: Capsule())
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private func iconForFile(_ file: StoredFile) -> String {
        if file.mimeType.starts(with: "image/") { return "photo" }
        if file.mimeType.starts(with: "video/") { return "video" }
        if file.mimeType.starts(with: "audio/") { return "music.note" }
        if file.mimeType == "application/pdf" { return "doc.text" }
        return "doc"
    }
}

struct CDNView: View {
    @ObservedObject var service: FileStorageService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(service.cdnNodes) { node in
                    CDNNodeCard(node: node)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct CDNNodeCard: View {
    let node: CDNNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: "server.rack")
                    .foregroundStyle(.green)
                Text(node.location)
                    .appText(.body, weight: .semibold)
                Spacer()
                Circle()
                    .fill(node.status == .active ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(node.status.rawValue)
                    .appText(.caption)
            }
            
            HStack(spacing: DSSpacing.xl) {
                VStack(alignment: .leading) {
                    Text("\(node.requestsPerSecond)")
                        .appText(.title, weight: .bold)
                    Text("req/s")
                        .appText(.caption, color: .secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("\(node.latency)ms")
                        .appText(.title, weight: .bold)
                    Text("latency")
                        .appText(.caption, color: .secondary)
                }
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

struct FileStorageAnalyticsView: View {
    @ObservedObject var service: FileStorageService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text("Storage Metrics")
                    .appText(.heading, weight: .bold)
                
                // Placeholder for charts
                Text("Charts coming soon")
                    .appText(.body, color: .secondary)
            }
            .padding(DSSpacing.lg)
        }
    }
}

struct StorageStatBadge: View {
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
    FileStorageDashboardView()
        .frame(width: 1200, height: 800)
}

