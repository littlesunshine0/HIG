//
//  AIKnowledgeSettingsView.swift
//  HIG
//
//  AI Knowledge Base Settings with Liquid Glass Design
//  100% HIG-Compliant
//

import SwiftUI

struct AIKnowledgeSettingsView: View {
    @Environment(\.aiKnowledgeBase) private var knowledgeBase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var updateManager = ResourceUpdateManager.shared
    @State private var showingUpdateSheet = false
    @State private var selectedTab: Tab = .overview
    
    enum Tab: String, CaseIterable {
        case overview = "Overview"
        case resources = "Resources"
        case updates = "Updates"
        case advanced = "Advanced"
        
        var icon: String {
            switch self {
            case .overview: return "brain"
            case .resources: return "books.vertical"
            case .updates: return "arrow.triangle.2.circlepath"
            case .advanced: return "gearshape.2"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Tab Bar
            tabBar
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .resources:
                        resourcesContent
                    case .updates:
                        updatesContent
                    case .advanced:
                        advancedContent
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 700, height: 600)
        .background(.background)
        .sheet(isPresented: $showingUpdateSheet) {
            UpdateSheet(updateManager: updateManager)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.15))
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.purple)
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Knowledge Base")
                        .font(.title2.bold())
                    
                    Text("Offline resources for enhanced AI responses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .help("Close")
        }
        .padding(24)
    }
    
    // MARK: - Tab Bar
    
    @Namespace private var tabNamespace
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.body.weight(.medium))
                        
                        Text(tab.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
                    .background {
                        if selectedTab == tab {
                            Rectangle()
                                .fill(Color.accentColor.opacity(0.1))
                                .matchedGeometryEffect(id: "tab", in: tabNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.secondary.opacity(0.05))
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Status Card
            LiquidGlassContainer(elevation: .raised) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: statusIcon)
                            .font(.title.weight(.semibold))
                            .foregroundStyle(statusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(knowledgeBase.isLoaded ? "Knowledge Base Loaded" : "Not Loaded")
                            .font(.headline)
                        
                        if let metadata = knowledgeBase.metadata {
                            Text("Version \(metadata.version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("Updated \(formatDate(metadata.buildDate))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Statistics Grid
            if knowledgeBase.isLoaded {
                let stats = knowledgeBase.getStatistics()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(stats.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        StatCard(title: key, value: "\(value)", icon: iconForStat(key))
                    }
                }
            }
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Button {
                        Task {
                            await updateManager.checkForUpdates()
                        }
                    } label: {
                        Label("Check Updates", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCheckingOrDownloading)
                    
                    Button {
                        Task {
                            await knowledgeBase.loadKnowledgeBase()
                        }
                    } label: {
                        Label("Reload", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Resources Content
    
    private var resourcesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Available Resources")
                .font(.headline)
            
            ResourceCard(
                title: "Code Examples",
                description: "SwiftUI, UIKit, and async patterns",
                icon: "chevron.left.forwardslash.chevron.right",
                color: .blue,
                count: knowledgeBase.getStatistics()["Code Examples"] ?? 0
            )
            
            ResourceCard(
                title: "API References",
                description: "Foundation, SwiftUI, Combine quick refs",
                icon: "book.closed",
                color: .green,
                count: knowledgeBase.getStatistics()["API References"] ?? 0
            )
            
            ResourceCard(
                title: "Error Solutions",
                description: "Compiler, runtime, and build fixes",
                icon: "exclamationmark.triangle",
                color: .orange,
                count: knowledgeBase.getStatistics()["Error Solutions"] ?? 0
            )
            
            ResourceCard(
                title: "Design Patterns",
                description: "MVVM, MVC, Singleton, Factory, and more",
                icon: "square.grid.3x3",
                color: .purple,
                count: knowledgeBase.getStatistics()["Design Patterns"] ?? 0
            )
            
            ResourceCard(
                title: "Conversation Templates",
                description: "Structured response formats",
                icon: "bubble.left.and.bubble.right",
                color: .cyan,
                count: knowledgeBase.getStatistics()["Conversation Templates"] ?? 0
            )
        }
    }
    
    // MARK: - Updates Content
    
    private var updatesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Auto-update settings
            LiquidGlassContainer {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Automatic Updates")
                                .font(.headline)
                            Text("Keep knowledge base current")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $updateManager.config.autoUpdateEnabled)
                            .labelsHidden()
                            .onChange(of: updateManager.config.autoUpdateEnabled) { _, _ in
                                updateManager.config.save()
                            }
                    }
                    
                    if updateManager.config.autoUpdateEnabled {
                        Divider()
                        
                        Picker("Check for updates", selection: $updateManager.config.updateFrequency) {
                            ForEach(UpdateConfig.UpdateFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: updateManager.config.updateFrequency) { _, _ in
                            updateManager.config.save()
                        }
                    }
                }
            }
            
            // Update status
            LiquidGlassContainer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: updateStatusIcon)
                            .foregroundStyle(updateStatusColor)
                        Text(updateManager.status.message)
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    if updateManager.progress > 0 && updateManager.progress < 1 {
                        ProgressView(value: updateManager.progress)
                    }
                    
                    if let lastUpdate = updateManager.config.lastSuccessfulUpdate {
                        Text("Last updated: \(lastUpdate.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            // Update actions
            if updateManager.updateAvailable {
                Button {
                    showingUpdateSheet = true
                } label: {
                    Label("Install Update", systemImage: "arrow.down.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
    
    // MARK: - Advanced Content
    
    private var advancedContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Advanced Settings")
                .font(.headline)
            
            // Backups
            let archives = updateManager.listArchives()
            if !archives.isEmpty {
                LiquidGlassContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.blue)
                            Text("Backups")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        ForEach(archives.prefix(5), id: \.self) { archive in
                            Button {
                                Task {
                                    try? await updateManager.restoreFromArchive(archiveName: archive)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "archivebox")
                                        .foregroundStyle(.secondary)
                                    Text(archive)
                                        .font(.caption.monospacedDigit())
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
            
            // Danger zone
            LiquidGlassContainer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text("Danger Zone")
                            .font(.headline)
                    }
                    
                    Text("These actions cannot be undone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        // Clear cache
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var statusIcon: String {
        knowledgeBase.isLoaded ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
    
    private var statusColor: Color {
        knowledgeBase.isLoaded ? .green : .orange
    }
    
    private var updateStatusIcon: String {
        switch updateManager.status {
        case .idle: return "checkmark.circle.fill"
        case .checking: return "arrow.triangle.2.circlepath"
        case .updateAvailable: return "exclamationmark.circle.fill"
        case .downloading, .installing: return "arrow.down.circle"
        case .complete: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    private var updateStatusColor: Color {
        switch updateManager.status {
        case .idle, .complete: return .green
        case .checking, .downloading, .installing: return .blue
        case .updateAvailable: return .orange
        case .error: return .red
        }
    }
    
    private var isCheckingOrDownloading: Bool {
        switch updateManager.status {
        case .checking, .downloading:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ isoString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: isoString) else {
            return isoString
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func iconForStat(_ key: String) -> String {
        switch key {
        case "Code Examples": return "chevron.left.forwardslash.chevron.right"
        case "API References": return "book.closed"
        case "Error Solutions": return "exclamationmark.triangle"
        case "Design Patterns": return "square.grid.3x3"
        case "Conversation Templates": return "bubble.left.and.bubble.right"
        default: return "doc"
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        LiquidGlassContainer(padding: 16, elevation: .subtle) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title.bold().monospacedDigit())
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Resource Card

struct ResourceCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let count: Int
    
    var body: some View {
        LiquidGlassContainer(elevation: .subtle, isInteractive: true) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                    
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(color)
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(count)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(color)
            }
        }
    }
}

// MARK: - Update Sheet

struct UpdateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var updateManager: ResourceUpdateManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Update Available")
                        .font(.title2.bold())
                    Text("New knowledge base content is ready")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 20)
                    
                    // Description
                    VStack(spacing: 8) {
                        Text("This update includes:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            UpdateFeatureRow(icon: "sparkles", text: "Latest code examples and patterns")
                            UpdateFeatureRow(icon: "book.closed", text: "Updated API references")
                            UpdateFeatureRow(icon: "wrench.and.screwdriver", text: "New error solutions")
                            UpdateFeatureRow(icon: "arrow.triangle.branch", text: "Enhanced design patterns")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Progress
                    if updateManager.status == .downloading || updateManager.status == .installing {
                        VStack(spacing: 12) {
                            ProgressView(value: updateManager.progress)
                            
                            Text(updateManager.status.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                }
                .padding(24)
            }
            
            Divider()
            
            // Footer
            HStack(spacing: 12) {
                Button("Later") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button {
                    Task {
                        await updateManager.performUpdate()
                        if updateManager.status == .complete {
                            dismiss()
                        }
                    }
                } label: {
                    Text("Install Update")
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .disabled(updateManager.status == .downloading || updateManager.status == .installing)
            }
            .padding(24)
        }
        .frame(width: 500, height: 550)
        .background(.background)
    }
}

struct UpdateFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    AIKnowledgeSettingsView()
}
