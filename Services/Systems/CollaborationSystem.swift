//
//  CollaborationSystem.swift
//  HIG
//
//  Collaboration System - Real-time editing, presence
//

import SwiftUI

struct CollaborationSystemView: View {
    @State private var selectedTab = "Editor"
    @State private var collaborators: [Collaborator] = Collaborator.samples
    @State private var documentContent = "# Welcome to Collaborative Editing\n\nStart typing to see real-time collaboration in action.\n\nThis document supports:\n- Multiple cursors\n- Real-time sync\n- Comments and suggestions\n- Version history"
    
    let tabs = ["Editor", "Presence", "Comments", "History"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "person.2.fill").font(.title2).foregroundStyle(.indigo)
                Text("Collaboration System").font(.title2.bold())
                Spacer()
                
                // Active Collaborators
                HStack(spacing: -8) {
                    ForEach(collaborators.filter { $0.isOnline }.prefix(4)) { collaborator in
                        Circle()
                            .fill(collaborator.color)
                            .frame(width: 32, height: 32)
                            .overlay(Text(String(collaborator.name.prefix(1))).font(.caption).foregroundStyle(.white))
                            .overlay(Circle().stroke(Color(.windowBackgroundColor), lineWidth: 2))
                    }
                    
                    if collaborators.filter({ $0.isOnline }).count > 4 {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 32, height: 32)
                            .overlay(Text("+\(collaborators.filter { $0.isOnline }.count - 4)").font(.caption).foregroundStyle(.white))
                    }
                }
                
                Button("Share") {}.buttonStyle(.borderedProminent).tint(.indigo)
            }
            .padding()
            .background(.regularMaterial)
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 20).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.indigo.opacity(0.2) : Color.clear)
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
                case "Editor": CollaborativeEditorView(content: $documentContent, collaborators: collaborators)
                case "Presence": PresenceView(collaborators: collaborators)
                case "Comments": CommentsView()
                case "History": CollabVersionHistoryView()
                default: EmptyView()
                }
            }
        }
    }
}

struct CollaborativeEditorView: View {
    @Binding var content: String
    let collaborators: [Collaborator]
    
    var body: some View {
        HSplitView {
            // Editor
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button { } label: { Image(systemName: "bold") }.buttonStyle(.bordered)
                    Button { } label: { Image(systemName: "italic") }.buttonStyle(.bordered)
                    Button { } label: { Image(systemName: "underline") }.buttonStyle(.bordered)
                    Divider().frame(height: 20)
                    Button { } label: { Image(systemName: "list.bullet") }.buttonStyle(.bordered)
                    Button { } label: { Image(systemName: "list.number") }.buttonStyle(.bordered)
                    Divider().frame(height: 20)
                    Button { } label: { Image(systemName: "link") }.buttonStyle(.bordered)
                    Button { } label: { Image(systemName: "photo") }.buttonStyle(.bordered)
                    Spacer()
                    
                    // Sync Status
                    HStack(spacing: 4) {
                        Circle().fill(.green).frame(width: 8, height: 8)
                        Text("Synced").font(.caption)
                    }
                }
                .padding(8)
                .background(.regularMaterial)
                
                Divider()
                
                // Editor Area
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                    
                    // Simulated cursors
                    ForEach(collaborators.filter { $0.isOnline && $0.cursorPosition != nil }.prefix(3)) { collaborator in
                        CollaboratorCursor(collaborator: collaborator)
                            .offset(x: CGFloat.random(in: 50...400), y: CGFloat.random(in: 50...300))
                    }
                }
            }
            
            // Sidebar
            VStack(alignment: .leading, spacing: 16) {
                Text("Collaborators").font(.headline)
                
                ForEach(collaborators.filter { $0.isOnline }) { collaborator in
                    HStack(spacing: 8) {
                        Circle().fill(collaborator.color).frame(width: 24, height: 24)
                            .overlay(Text(String(collaborator.name.prefix(1))).font(.caption2).foregroundStyle(.white))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(collaborator.name).font(.caption)
                            Text(collaborator.status).font(.caption2).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Circle().fill(.green).frame(width: 8, height: 8)
                    }
                }
                
                Divider()
                
                Text("Quick Actions").font(.headline)
                
                Button { } label: { Label("Add Comment", systemImage: "bubble.left") }.buttonStyle(.bordered).frame(maxWidth: .infinity)
                Button { } label: { Label("Suggest Edit", systemImage: "pencil.line") }.buttonStyle(.bordered).frame(maxWidth: .infinity)
                Button { } label: { Label("Request Review", systemImage: "checkmark.circle") }.buttonStyle(.bordered).frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding()
            .frame(width: 220)
            .background(.regularMaterial)
        }
    }
}

struct CollaboratorCursor: View {
    let collaborator: Collaborator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cursor
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: 16))
                path.addLine(to: CGPoint(x: 4, y: 12))
                path.addLine(to: CGPoint(x: 8, y: 16))
                path.addLine(to: CGPoint(x: 4, y: 0))
                path.closeSubpath()
            }
            .fill(collaborator.color)
            .frame(width: 10, height: 18)
            
            // Name tag
            Text(collaborator.name.components(separatedBy: " ").first ?? "")
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 4).fill(collaborator.color))
        }
    }
}

struct PresenceView: View {
    let collaborators: [Collaborator]
    
    var body: some View {
        VStack(spacing: 20) {
            // Online/Offline Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(collaborators.filter { $0.isOnline }.count)").font(.largeTitle.bold()).foregroundStyle(.green)
                    Text("Online").font(.caption)
                }
                
                VStack {
                    Text("\(collaborators.filter { !$0.isOnline }.count)").font(.largeTitle.bold()).foregroundStyle(.secondary)
                    Text("Offline").font(.caption)
                }
                
                VStack {
                    Text("\(collaborators.count)").font(.largeTitle.bold()).foregroundStyle(.indigo)
                    Text("Total").font(.caption)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // Collaborator List
            List {
                Section("Online") {
                    ForEach(collaborators.filter { $0.isOnline }) { collaborator in
                        CollaboratorRow(collaborator: collaborator)
                    }
                }
                
                Section("Offline") {
                    ForEach(collaborators.filter { !$0.isOnline }) { collaborator in
                        CollaboratorRow(collaborator: collaborator)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct CollaboratorRow: View {
    let collaborator: Collaborator
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(collaborator.color).frame(width: 40, height: 40)
                    .overlay(Text(String(collaborator.name.prefix(1))).foregroundStyle(.white))
                
                Circle().fill(collaborator.isOnline ? .green : .secondary).frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(.windowBackgroundColor), lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(collaborator.name).font(.subheadline)
                Text(collaborator.role).font(.caption2).foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(collaborator.status).font(.caption).foregroundStyle(.secondary)
                if let location = collaborator.currentLocation {
                    Text(location).font(.caption2).foregroundStyle(.indigo)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CommentsView: View {
    let comments = [
        ("Alice", "Great introduction! Maybe add more examples?", "Line 3", "2 min ago"),
        ("Bob", "Should we include a code sample here?", "Line 8", "15 min ago"),
        ("Charlie", "Approved! Ready for merge.", "General", "1 hour ago"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Comments").font(.headline)
                Spacer()
                Button("Add Comment") {}.buttonStyle(.borderedProminent).tint(.indigo)
            }
            
            List {
                ForEach(comments, id: \.0) { comment in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle().fill(.indigo).frame(width: 24, height: 24)
                                .overlay(Text(String(comment.0.prefix(1))).font(.caption2).foregroundStyle(.white))
                            Text(comment.0).font(.subheadline.bold())
                            Spacer()
                            Text(comment.3).font(.caption2).foregroundStyle(.secondary)
                        }
                        
                        Text(comment.1).font(.caption)
                        
                        HStack {
                            Text(comment.2).font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(Color.indigo.opacity(0.2)))
                            
                            Spacer()
                            
                            Button("Reply") {}.buttonStyle(.bordered).controlSize(.small)
                            Button("Resolve") {}.buttonStyle(.bordered).controlSize(.small)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct CollabVersionHistoryView: View {
    let versions = [
        ("Current", "Alice", "Just now", true),
        ("v1.4", "Bob", "2 hours ago", false),
        ("v1.3", "Alice", "Yesterday", false),
        ("v1.2", "Charlie", "2 days ago", false),
        ("v1.1", "Alice", "3 days ago", false),
        ("v1.0", "Bob", "1 week ago", false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Version History").font(.headline)
                Spacer()
                Button("Compare") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(versions, id: \.0) { version in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(version.0).font(.subheadline.bold())
                                if version.3 {
                                    Text("Current").font(.caption2)
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Capsule().fill(Color.green.opacity(0.2)))
                                }
                            }
                            Text("by \(version.1) • \(version.2)").font(.caption).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !version.3 {
                            Button("Restore") {}.buttonStyle(.bordered).controlSize(.small)
                            Button("View") {}.buttonStyle(.bordered).controlSize(.small)
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

struct Collaborator: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let color: Color
    let isOnline: Bool
    let status: String
    let cursorPosition: Int?
    let currentLocation: String?
    
    static var samples: [Collaborator] {
        [
            Collaborator(name: "Alice Johnson", role: "Editor", color: .blue, isOnline: true, status: "Editing", cursorPosition: 45, currentLocation: "Line 12"),
            Collaborator(name: "Bob Smith", role: "Reviewer", color: .green, isOnline: true, status: "Viewing", cursorPosition: 120, currentLocation: "Line 28"),
            Collaborator(name: "Charlie Brown", role: "Contributor", color: .orange, isOnline: true, status: "Commenting", cursorPosition: nil, currentLocation: nil),
            Collaborator(name: "Diana Prince", role: "Owner", color: .purple, isOnline: false, status: "Last seen 2h ago", cursorPosition: nil, currentLocation: nil),
            Collaborator(name: "Eve Wilson", role: "Viewer", color: .pink, isOnline: false, status: "Last seen yesterday", cursorPosition: nil, currentLocation: nil),
        ]
    }
}

#Preview {
    CollaborationSystemView()
        .frame(width: 1100, height: 700)
}

