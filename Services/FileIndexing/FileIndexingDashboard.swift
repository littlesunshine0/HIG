//
//  FileIndexingDashboard.swift
//  HIG
//
//  Dashboard for file system indexing and search
//

import SwiftUI

struct FileIndexingDashboard: View {
    @StateObject private var service = FileIndexingService.shared
    @State private var searchQuery = ""
    @State private var selectedFile: IndexedFile?
    @State private var showSettings = false
    @State private var selectedFilter: FileType?
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            mainContent
        } detail: {
            detailView
        }
        .navigationTitle("File Index")
        .sheet(isPresented: $showSettings) {
            IndexingSettingsView()
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        List(selection: $selectedFilter) {
            Section("Quick Actions") {
                Button(action: { Task { await service.startAutomaticIndexing() } }) {
                    Label("Start Indexing", systemImage: "arrow.clockwise")
                }
                .disabled(service.isIndexing)
                
                Button(action: { showSettings = true }) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            
            Section("Statistics") {
                FileIndexStatRow(label: "Total Files", value: "\(service.statistics.totalFiles)")
                FileIndexStatRow(label: "Total Size", value: service.statistics.displaySize)
                FileIndexStatRow(label: "Repositories", value: "\(service.indexedRepositories.count)")
                
                if let lastIndexed = service.statistics.lastIndexed {
                    FileIndexStatRow(label: "Last Indexed", value: lastIndexed.formatted(date: .abbreviated, time: .shortened))
                }
            }
            
            Section("Filter by Type") {
                ForEach([FileType.code, .documentation, .configuration, .image, .video, .audio, .other], id: \.self) { type in
                    Button(action: { selectedFilter = type }) {
                        HStack {
                            Image(systemName: type.icon)
                            Text(type.rawValue.capitalized)
                            Spacer()
                            Text("\(service.files(ofType: type).count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(type as FileType?)
                }
                
                Button(action: { selectedFilter = nil }) {
                    HStack {
                        Image(systemName: "square.grid.2x2")
                        Text("All Files")
                        Spacer()
                        Text("\(service.indexedFiles.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                .tag(nil as FileType?)
            }
            
            Section("GitHub Repositories") {
                ForEach(service.indexedRepositories) { repo in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repo.name)
                            .font(.headline)
                        Text(repo.localPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .searchable(text: $searchQuery)
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Indexing progress
            if service.isIndexing {
                indexingProgress
            }
            
            // File list
            fileList
        }
    }
    
    private var indexingProgress: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView(value: service.progress)
                .progressViewStyle(.linear)
            
            Text(service.currentOperation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(DSSpacing.md)
        .background(Color.accentColor.opacity(0.1))
    }
    
    private var fileList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.sm) {
                ForEach(filteredFiles) { file in
                    IndexedFileRow(file: file, isSelected: selectedFile?.id == file.id)
                        .onTapGesture {
                            selectedFile = file
                        }
                }
            }
            .padding(DSSpacing.md)
        }
    }
    
    private var filteredFiles: [IndexedFile] {
        var files = service.indexedFiles
        
        // Apply type filter
        if let filter = selectedFilter {
            files = files.filter { $0.type == filter }
        }
        
        // Apply search
        if !searchQuery.isEmpty {
            files = service.search(query: searchQuery)
        }
        
        return files
    }
    
    // MARK: - Detail View
    
    private var detailView: some View {
        Group {
            if let file = selectedFile {
                FileDetailView(file: file)
            } else {
                ContentUnavailableView(
                    "Select a File",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Choose a file to view its details")
                )
            }
        }
    }
}

// MARK: - File Row

struct IndexedFileRow: View {
    let file: IndexedFile
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: file.type.icon)
                .font(.title2)
                .foregroundStyle(isSelected ? .white : .blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(file.name)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(file.path)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(file.displaySize)
                    Text("•")
                    Text(file.modifiedDate.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption2)
                .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

// MARK: - File Detail View

struct FileDetailView: View {
    let file: IndexedFile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                // Header
                HStack {
                    Image(systemName: file.type.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(file.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(file.type.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { openInFinder() }) {
                        Label("Show in Finder", systemImage: "folder")
                    }
                }
                
                Divider()
                
                // Metadata
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Information")
                        .font(.headline)
                    
                    FileInfoRow(label: "Path", value: file.path)
                    FileInfoRow(label: "Size", value: file.displaySize)
                    FileInfoRow(label: "Modified", value: file.modifiedDate.formatted(date: .long, time: .shortened))
                    FileInfoRow(label: "Type", value: file.type.rawValue.capitalized)
                }
                
                // Keywords
                if !file.keywords.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        Text("Keywords")
                            .font(.headline)
                        
                        FlowLayout(spacing: DSSpacing.xs) {
                            ForEach(file.keywords.prefix(20), id: \.self) { keyword in
                                Text(keyword)
                                    .font(.caption)
                                    .padding(.horizontal, DSSpacing.sm)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Content preview
                if let content = file.content, file.type.isTextBased {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        Text("Preview")
                            .font(.headline)
                        
                        Text(content.prefix(1000))
                            .font(.system(.body, design: .monospaced))
                            .padding(DSSpacing.md)
                            .background(Color.secondary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }
    
    private func openInFinder() {
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
    }
}

// MARK: - Settings View

struct IndexingSettingsView: View {
    @StateObject private var service = FileIndexingService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Indexing Options") {
                    Toggle("Index Home Directory", isOn: $service.config.indexHomeDirectory)
                    Toggle("Index Apple Documentation", isOn: $service.config.indexAppleDocs)
                    Toggle("Index Swift Documentation", isOn: $service.config.indexSwiftDocs)
                    Toggle("Index GitHub Repositories", isOn: $service.config.indexGitHubRepos)
                }
                
                Section("Performance") {
                    Stepper("Max Depth: \(service.config.maxDepth)", value: $service.config.maxDepth, in: 1...20)
                    
                    HStack {
                        Text("Max File Size")
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: Int64(service.config.maxFileSizeBytes), countStyle: .file))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Auto-Reindex") {
                    Picker("Interval", selection: $service.config.autoReindexInterval) {
                        Text("Never").tag(TimeInterval.infinity)
                        Text("Daily").tag(TimeInterval(86400))
                        Text("Weekly").tag(TimeInterval(604800))
                        Text("Monthly").tag(TimeInterval(2592000))
                    }
                }
            }
            .navigationTitle("Indexing Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        service.config.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FileIndexStatRow: View {
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

struct FileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

// Simple flow layout for keywords
struct FileIndexingFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    FileIndexingDashboard()
        .frame(width: 1200, height: 800)
}
