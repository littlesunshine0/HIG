//
//  PluginExtensionSystem.swift
//  HIG
//
//  Plugin / Extension System - APIs and sandboxing for third-party extensions
//

import SwiftUI

struct PluginExtensionSystemView: View {
    @State private var selectedTab = "Installed"
    @State private var plugins: [Plugin] = Plugin.samples
    
    let tabs = ["Installed", "Marketplace", "Develop", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "puzzlepiece.extension.fill").font(.title2).foregroundStyle(.pink)
                Text("Plugin System").font(.title2.bold())
                Spacer()
                Text("\(plugins.filter { $0.isEnabled }.count) active plugins").font(.caption).foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.pink.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Installed": InstalledPluginsView(plugins: $plugins)
                case "Marketplace": MarketplaceView()
                case "Develop": DeveloperView()
                case "Settings": PluginSettingsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct InstalledPluginsView: View {
    @Binding var plugins: [Plugin]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search plugins...", text: .constant("")).textFieldStyle(.roundedBorder).frame(width: 250)
                Spacer()
                Button("Check Updates") {}.buttonStyle(.bordered)
            }
            .padding()
            
            List {
                ForEach($plugins) { $plugin in
                    PluginRow(plugin: $plugin)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct PluginRow: View {
    @Binding var plugin: Plugin
    @State private var showSettings = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(plugin.color.opacity(0.2)).frame(width: 50, height: 50)
                Image(systemName: plugin.icon).font(.title2).foregroundStyle(plugin.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plugin.name).font(.subheadline.bold())
                    if plugin.hasUpdate {
                        Text("Update").font(.caption2).foregroundStyle(.white).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.blue))
                    }
                }
                Text(plugin.description).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text("v\(plugin.version)").font(.caption2)
                    Text("•").foregroundStyle(.secondary)
                    Text(plugin.author).font(.caption2).foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $plugin.isEnabled).labelsHidden()
            
            Button { showSettings.toggle() } label: { Image(systemName: "gearshape") }.buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
    }
}

struct MarketplaceView: View {
    let featured = [
        ("Analytics Pro", "Advanced analytics dashboard", "chart.bar.fill", Color.purple, 4.8, 1250),
        ("AI Assistant", "Smart AI-powered helper", "brain.head.profile", Color.blue, 4.9, 3400),
        ("Theme Studio", "Custom themes and styling", "paintpalette.fill", Color.orange, 4.7, 890),
    ]
    
    let categories = ["All", "Productivity", "Analytics", "Integration", "UI/UX", "Developer"]
    @State private var selectedCategory = "All"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Featured
                VStack(alignment: .leading, spacing: 12) {
                    Text("Featured").font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(featured, id: \.0) { plugin in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12).fill(plugin.3.opacity(0.2)).frame(width: 50, height: 50)
                                            Image(systemName: plugin.2).font(.title2).foregroundStyle(plugin.3)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            HStack(spacing: 2) {
                                                Image(systemName: "star.fill").foregroundStyle(.yellow)
                                                Text(String(format: "%.1f", plugin.4)).font(.caption)
                                            }
                                            Text("\(plugin.5) installs").font(.caption2).foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Text(plugin.0).font(.subheadline.bold())
                                    Text(plugin.1).font(.caption).foregroundStyle(.secondary)
                                    
                                    Button("Install") {}.buttonStyle(.borderedProminent).tint(.pink).controlSize(.small)
                                }
                                .padding()
                                .frame(width: 220)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.controlBackgroundColor)))
                            }
                        }
                    }
                }
                
                // Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categories").font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button { selectedCategory = cat } label: {
                                    Text(cat).font(.caption).padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Capsule().fill(selectedCategory == cat ? Color.pink : Color(.controlBackgroundColor)))
                                        .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // All Plugins Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                    ForEach(0..<8, id: \.self) { i in
                        MarketplacePluginCard(index: i)
                    }
                }
            }
            .padding()
        }
    }
}

struct MarketplacePluginCard: View {
    let index: Int
    let names = ["Data Sync", "Export Plus", "Slack Connect", "GitHub Integration", "Calendar Sync", "Email Templates", "PDF Generator", "Backup Pro"]
    let icons = ["arrow.triangle.2.circlepath", "square.and.arrow.up", "bubble.left.fill", "chevron.left.forwardslash.chevron.right", "calendar", "envelope.fill", "doc.fill", "externaldrive.fill"]
    let colors: [Color] = [.blue, .green, .purple, .orange, .red, .teal, .indigo, .cyan]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icons[index % icons.count]).foregroundStyle(colors[index % colors.count])
                Text(names[index % names.count]).font(.subheadline.bold())
            }
            Text("Plugin description goes here").font(.caption).foregroundStyle(.secondary)
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                    Text("4.\(5 + index % 4)").font(.caption2)
                }
                Spacer()
                Button("Install") {}.buttonStyle(.bordered).controlSize(.mini)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct DeveloperView: View {
    var body: some View {
        VStack(spacing: 24) {
            // API Documentation
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text.fill").foregroundStyle(.pink)
                    Text("API Documentation").font(.headline)
                }
                Text("Build plugins using our comprehensive API").font(.caption).foregroundStyle(.secondary)
                
                HStack {
                    Button("View Docs") {}.buttonStyle(.bordered)
                    Button("API Reference") {}.buttonStyle(.bordered)
                    Button("Examples") {}.buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // Create Plugin
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "hammer.fill").foregroundStyle(.orange)
                    Text("Create New Plugin").font(.headline)
                }
                
                HStack {
                    Button("Start from Template") {}.buttonStyle(.borderedProminent).tint(.pink)
                    Button("Import Existing") {}.buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // My Plugins
            VStack(alignment: .leading, spacing: 12) {
                Text("My Plugins").font(.headline)
                
                HStack {
                    Image(systemName: "puzzlepiece.fill").foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text("My Custom Plugin").font(.subheadline)
                        Text("v1.0.0 • Draft").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Edit") {}.buttonStyle(.bordered)
                    Button("Publish") {}.buttonStyle(.borderedProminent).tint(.green)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor).opacity(0.5)))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct PluginSettingsView: View {
    @State private var autoUpdate = true
    @State private var sandboxMode = true
    @State private var allowNetwork = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Plugin Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Auto-update plugins", isOn: $autoUpdate)
                Toggle("Sandbox mode (recommended)", isOn: $sandboxMode)
                Toggle("Allow network access", isOn: $allowNetwork)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plugin Permissions").font(.subheadline)
                    Text("Control what plugins can access").font(.caption).foregroundStyle(.secondary)
                    
                    HStack {
                        Toggle("File System", isOn: .constant(false))
                        Toggle("Clipboard", isOn: .constant(true))
                        Toggle("Notifications", isOn: .constant(true))
                    }
                    .font(.caption)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct Plugin: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var version: String
    var author: String
    var icon: String
    var color: Color
    var isEnabled: Bool
    var hasUpdate: Bool
    
    static var samples: [Plugin] {
        [
            Plugin(name: "Analytics Dashboard", description: "Advanced analytics and reporting", version: "2.1.0", author: "Official", icon: "chart.bar.fill", color: .purple, isEnabled: true, hasUpdate: false),
            Plugin(name: "Slack Integration", description: "Connect with Slack workspaces", version: "1.5.2", author: "Slack Inc.", icon: "bubble.left.fill", color: .green, isEnabled: true, hasUpdate: true),
            Plugin(name: "Dark Theme Pro", description: "Enhanced dark mode themes", version: "3.0.1", author: "ThemeCraft", icon: "moon.fill", color: .indigo, isEnabled: true, hasUpdate: false),
            Plugin(name: "Export Tools", description: "Export to PDF, CSV, and more", version: "1.2.0", author: "DataTools", icon: "square.and.arrow.up", color: .blue, isEnabled: false, hasUpdate: false),
        ]
    }
}

#Preview { PluginExtensionSystemView().frame(width: 1000, height: 700) }
