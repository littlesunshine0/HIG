//
//  VersionControlSystem.swift
//  HIG
//
//  Version Control System - Track changes, rollback/restore previous states
//

import SwiftUI

struct VersionControlSystemView: View {
    @State private var selectedTab = "History"
    @State private var versions: [DataVersion] = DataVersion.samples
    
    let tabs = ["History", "Compare", "Branches", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock.arrow.circlepath").font(.title2).foregroundStyle(.cyan)
                Text("Version Control").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.cyan.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "History": VersionHistoryView(versions: versions)
                case "Compare": VersionCompareView()
                case "Branches": BranchesView()
                case "Settings": VersionSettingsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct VersionHistoryView: View {
    let versions: [DataVersion]
    @State private var selectedVersion: DataVersion?
    
    var body: some View {
        HSplitView {
            // Version List
            VStack(spacing: 0) {
                HStack {
                    TextField("Search versions...", text: .constant("")).textFieldStyle(.roundedBorder)
                    Button { } label: { Image(systemName: "line.3.horizontal.decrease.circle") }.buttonStyle(.bordered)
                }
                .padding()
                
                List(versions, selection: $selectedVersion) { version in
                    VersionRow(version: version).tag(version)
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 350)
            
            // Version Detail
            if let version = selectedVersion {
                VersionDetailView(version: version)
            } else {
                VStack {
                    Image(systemName: "clock.arrow.circlepath").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("Select a version").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct VersionRow: View {
    let version: DataVersion
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Circle().fill(version.isCurrent ? .green : .cyan).frame(width: 12)
                if !version.isCurrent {
                    Rectangle().fill(Color.secondary.opacity(0.3)).frame(width: 2, height: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(version.title).font(.subheadline.bold())
                    if version.isCurrent {
                        Text("Current").font(.caption2).foregroundStyle(.white).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.green))
                    }
                    if version.isTagged {
                        Text(version.tag ?? "").font(.caption2).foregroundStyle(.cyan)
                    }
                }
                Text(version.description).font(.caption).foregroundStyle(.secondary)
                HStack {
                    Text(version.author).font(.caption2)
                    Text("•").foregroundStyle(.secondary)
                    Text(version.timeAgo).font(.caption2).foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(version.hash).font(.caption.monospaced()).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct VersionDetailView: View {
    let version: DataVersion
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(version.title).font(.title2.bold())
                        Text(version.hash).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !version.isCurrent {
                        Button("Restore") {}.buttonStyle(.borderedProminent).tint(.cyan)
                    }
                }
                
                Divider()
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Text("Author:").foregroundStyle(.secondary); Text(version.author) }
                    HStack { Text("Date:").foregroundStyle(.secondary); Text(version.date) }
                    HStack { Text("Changes:").foregroundStyle(.secondary); Text("\(version.changes.count) modifications") }
                }
                .font(.caption)
                
                Divider()
                
                // Changes
                Text("Changes").font(.headline)
                
                ForEach(version.changes, id: \.field) { change in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(change.field).font(.subheadline.bold())
                        
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Before").font(.caption2).foregroundStyle(.secondary)
                                Text(change.oldValue).font(.caption).padding(8)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.1)))
                            }
                            
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading) {
                                Text("After").font(.caption2).foregroundStyle(.secondary)
                                Text(change.newValue).font(.caption).padding(8)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.green.opacity(0.1)))
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                }
            }
            .padding()
        }
    }
}

struct VersionCompareView: View {
    @State private var version1 = "v1.2.0"
    @State private var version2 = "v1.1.0"
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Picker("From", selection: $version1) {
                    Text("v1.2.0 (Current)").tag("v1.2.0")
                    Text("v1.1.0").tag("v1.1.0")
                    Text("v1.0.0").tag("v1.0.0")
                }
                
                Image(systemName: "arrow.left.arrow.right").foregroundStyle(.secondary)
                
                Picker("To", selection: $version2) {
                    Text("v1.2.0 (Current)").tag("v1.2.0")
                    Text("v1.1.0").tag("v1.1.0")
                    Text("v1.0.0").tag("v1.0.0")
                }
                
                Button("Compare") {}.buttonStyle(.borderedProminent).tint(.cyan)
            }
            .padding()
            
            Divider()
            
            // Comparison Results
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(version2).font(.headline)
                    Text("Previous").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                
                VStack(alignment: .leading) {
                    Text(version1).font(.headline)
                    Text("Current").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
            }
            
            List {
                CompareRow(field: "Title", old: "My Document", new: "My Updated Document", type: .modified)
                CompareRow(field: "Status", old: "Draft", new: "Published", type: .modified)
                CompareRow(field: "Tags", old: "-", new: "important, featured", type: .added)
                CompareRow(field: "Old Field", old: "Some value", new: "-", type: .deleted)
            }
            .listStyle(.plain)
        }
    }
}

struct CompareRow: View {
    let field: String
    let old: String
    let new: String
    let type: ChangeType
    
    enum ChangeType { case added, modified, deleted }
    
    var body: some View {
        HStack {
            Image(systemName: type == .added ? "plus.circle.fill" : (type == .deleted ? "minus.circle.fill" : "pencil.circle.fill"))
                .foregroundStyle(type == .added ? .green : (type == .deleted ? .red : .orange))
            
            Text(field).font(.subheadline).frame(width: 100, alignment: .leading)
            
            Text(old).font(.caption).foregroundStyle(type == .deleted ? .red : .secondary).frame(maxWidth: .infinity, alignment: .leading)
            
            Text(new).font(.caption).foregroundStyle(type == .added ? .green : .primary).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct BranchesView: View {
    let branches = [("main", true, "Production branch"), ("develop", false, "Development branch"), ("feature/new-ui", false, "UI redesign")]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Branches").font(.headline)
                Spacer()
                Button("Create Branch") {}.buttonStyle(.borderedProminent).tint(.cyan)
            }
            
            List {
                ForEach(branches, id: \.0) { branch in
                    HStack {
                        Image(systemName: "arrow.triangle.branch").foregroundStyle(.cyan)
                        VStack(alignment: .leading) {
                            HStack {
                                Text(branch.0).font(.subheadline.bold())
                                if branch.1 { Text("Default").font(.caption2).foregroundStyle(.green) }
                            }
                            Text(branch.2).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Checkout") {}.buttonStyle(.bordered).controlSize(.small)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct VersionSettingsView: View {
    @State private var autoSave = true
    @State private var keepVersions = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Version Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Auto-save versions", isOn: $autoSave)
                
                HStack {
                    Text("Keep versions:")
                    Picker("", selection: $keepVersions) {
                        Text("10").tag(10)
                        Text("25").tag(25)
                        Text("50").tag(50)
                        Text("100").tag(100)
                        Text("Unlimited").tag(0)
                    }
                }
                
                Divider()
                
                Button("Purge Old Versions") {}.buttonStyle(.bordered).tint(.red)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct DataVersion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let hash: String
    let author: String
    let date: String
    let timeAgo: String
    let isCurrent: Bool
    let isTagged: Bool
    let tag: String?
    let changes: [VersionChange]
    
    static func == (lhs: DataVersion, rhs: DataVersion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    static var samples: [DataVersion] {
        [
            DataVersion(title: "Updated content", description: "Modified title and status", hash: "a1b2c3d", author: "John Doe", date: "Nov 27, 2024", timeAgo: "2 hours ago", isCurrent: true, isTagged: true, tag: "v1.2.0", changes: [VersionChange(field: "Title", oldValue: "Old Title", newValue: "New Title"), VersionChange(field: "Status", oldValue: "Draft", newValue: "Published")]),
            DataVersion(title: "Added tags", description: "Added category tags", hash: "e4f5g6h", author: "Jane Smith", date: "Nov 26, 2024", timeAgo: "1 day ago", isCurrent: false, isTagged: false, tag: nil, changes: [VersionChange(field: "Tags", oldValue: "", newValue: "important")]),
            DataVersion(title: "Initial version", description: "Created document", hash: "i7j8k9l", author: "John Doe", date: "Nov 25, 2024", timeAgo: "2 days ago", isCurrent: false, isTagged: true, tag: "v1.0.0", changes: []),
        ]
    }
}

struct VersionChange: Hashable {
    let field: String
    let oldValue: String
    let newValue: String
}

#Preview { VersionControlSystemView().frame(width: 1000, height: 700) }
