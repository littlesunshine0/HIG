//
//  DNAStripView.swift
//  HIG
//
//  DNA Strip View: Files rendered as color-coded "genetic strips" based on token density and type
//  Allows instant visual identification of file complexity and composition
//

import SwiftUI


struct StatRow: View {
    let label: String
    let value: String
    var color: Color? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(color ?? .primary)
        }
    }
}
// MARK: - Token Types

enum TokenType: String, CaseIterable {
    case logic = "Logic"
    case data = "Data"
    case prose = "Prose"
    case boilerplate = "Boilerplate"
    case comment = "Comment"
    case whitespace = "Whitespace"
    case import_ = "Import"
    case declaration = "Declaration"
    
    var color: Color {
        switch self {
        case .logic: return .red
        case .data: return .blue
        case .prose: return .green
        case .boilerplate: return .gray
        case .comment: return .mint
        case .whitespace: return .clear
        case .import_: return .orange
        case .declaration: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .logic: return "brain"
        case .data: return "cylinder"
        case .prose: return "text.alignleft"
        case .boilerplate: return "doc.on.doc"
        case .comment: return "text.bubble"
        case .whitespace: return "space"
        case .import_: return "arrow.down.doc"
        case .declaration: return "curlybraces"
        }
    }
}

// MARK: - DNA Segment

struct DNASegment: Identifiable {
    let id = UUID()
    let tokenType: TokenType
    let density: Double // 0-1
    let lineStart: Int
    let lineEnd: Int
    let content: String
}

// MARK: - File DNA

struct FileDNA: Identifiable {
    let id = UUID()
    let fileName: String
    let filePath: String
    let segments: [DNASegment]
    let totalLines: Int
    let complexity: Double // 0-1 based on logic density
    let fileType: String
    
    var dominantType: TokenType {
        let typeCounts = Dictionary(grouping: segments, by: { $0.tokenType })
            .mapValues { $0.reduce(0) { $0 + ($1.lineEnd - $1.lineStart) } }
        return typeCounts.max(by: { $0.value < $1.value })?.key ?? .boilerplate
    }
    
    var typeDistribution: [TokenType: Double] {
        var distribution: [TokenType: Double] = [:]
        let total = Double(totalLines)
        
        for type in TokenType.allCases {
            let lines = segments.filter { $0.tokenType == type }
                .reduce(0) { $0 + ($1.lineEnd - $1.lineStart) }
            distribution[type] = Double(lines) / total
        }
        
        return distribution
    }
}

// MARK: - DNA Analyzer

@Observable
class DNAAnalyzer {
    var files: [FileDNA] = []
    var selectedFile: FileDNA?
    var sortOrder: SortOrder = .complexity
    var filterType: TokenType?
    var minComplexity: Double = 0
    
    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case complexity = "Complexity"
        case size = "Size"
        case type = "Type"
    }
    
    var sortedFiles: [FileDNA] {
        var result = files
        
        // Apply filter
        if let filter = filterType {
            result = result.filter { $0.dominantType == filter }
        }
        
        result = result.filter { $0.complexity >= minComplexity }
        
        // Apply sort
        switch sortOrder {
        case .name:
            result.sort { $0.fileName < $1.fileName }
        case .complexity:
            result.sort { $0.complexity > $1.complexity }
        case .size:
            result.sort { $0.totalLines > $1.totalLines }
        case .type:
            result.sort { $0.dominantType.rawValue < $1.dominantType.rawValue }
        }
        
        return result
    }
    
    func analyzeCode(_ code: String, fileName: String, filePath: String) -> FileDNA {
        let lines = code.components(separatedBy: "\n")
        var segments: [DNASegment] = []
        var currentType: TokenType = .whitespace
        var segmentStart = 0
        var logicLines = 0
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let newType = classifyLine(trimmed)
            
            if newType == .logic {
                logicLines += 1
            }
            
            if newType != currentType && index > 0 {
                // End current segment
                segments.append(DNASegment(
                    tokenType: currentType,
                    density: calculateDensity(lines[segmentStart..<index]),
                    lineStart: segmentStart,
                    lineEnd: index,
                    content: lines[segmentStart..<index].joined(separator: "\n")
                ))
                segmentStart = index
            }
            
            currentType = newType
        }
        
        // Add final segment
        if segmentStart < lines.count {
            segments.append(DNASegment(
                tokenType: currentType,
                density: calculateDensity(lines[segmentStart...]),
                lineStart: segmentStart,
                lineEnd: lines.count,
                content: lines[segmentStart...].joined(separator: "\n")
            ))
        }
        
        let complexity = Double(logicLines) / Double(max(lines.count, 1))
        let fileType = (fileName as NSString).pathExtension
        
        return FileDNA(
            fileName: fileName,
            filePath: filePath,
            segments: segments,
            totalLines: lines.count,
            complexity: complexity,
            fileType: fileType
        )
    }
    
    private func classifyLine(_ line: String) -> TokenType {
        if line.isEmpty {
            return .whitespace
        }
        
        // Comments
        if line.hasPrefix("//") || line.hasPrefix("/*") || line.hasPrefix("*") || line.hasPrefix("#") {
            return .comment
        }
        
        // Imports
        if line.hasPrefix("import ") || line.hasPrefix("from ") || line.hasPrefix("#include") {
            return .import_
        }
        
        // Declarations
        if line.hasPrefix("struct ") || line.hasPrefix("class ") || line.hasPrefix("enum ") ||
           line.hasPrefix("func ") || line.hasPrefix("def ") || line.hasPrefix("protocol ") ||
           line.hasPrefix("extension ") || line.hasPrefix("var ") || line.hasPrefix("let ") {
            return .declaration
        }
        
        // Logic (control flow, operations)
        let logicKeywords = ["if ", "else", "for ", "while ", "switch ", "guard ", "return ", "throw ", "try ", "catch ", "await ", "async "]
        if logicKeywords.contains(where: { line.contains($0) }) {
            return .logic
        }
        
        // Data (literals, constants)
        if line.contains("\"") || line.contains("[") || line.contains("{") && line.contains(":") {
            return .data
        }
        
        // Boilerplate (closing braces, simple statements)
        if line == "}" || line == "{" || line == ")" || line == "]" {
            return .boilerplate
        }
        
        // Default to prose for documentation-like content
        if line.count > 50 && !line.contains("(") {
            return .prose
        }
        
        return .boilerplate
    }
    
    private func calculateDensity(_ lines: ArraySlice<String>) -> Double {
        let nonEmpty = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return Double(nonEmpty.count) / Double(max(lines.count, 1))
    }
    
    func loadSampleFiles() {
        let sampleCodes: [(String, String, String)] = [
            ("ContentView.swift", "/HIG/ContentView.swift", sampleSwiftUI),
            ("AIKnowledgeBase.swift", "/HIG/Models/AIKnowledgeBase.swift", sampleModel),
            ("config.json", "/config.json", sampleJSON),
            ("README.md", "/README.md", sampleMarkdown),
            ("AnimationSystem.swift", "/HIG/Views/AnimationSystem.swift", sampleAnimation),
            ("Persistence.swift", "/HIG/Views/Persistence.swift", samplePersistence),
            ("Tests.swift", "/HIGTests/Tests.swift", sampleTests),
            ("Utils.swift", "/HIG/Utils.swift", sampleUtils),
        ]
        
        files = sampleCodes.map { analyzeCode($0.2, fileName: $0.0, filePath: $0.1) }
    }
    
    // Sample code snippets
    private var sampleSwiftUI: String {
        """
        import SwiftUI
        
        struct ContentView: View {
            @State private var count = 0
            @State private var isAnimating = false
            
            var body: some View {
                VStack(spacing: 20) {
                    // Header
                    Text("Welcome")
                        .font(.largeTitle)
                    
                    // Counter display
                    if count > 0 {
                        Text("Count: \\(count)")
                            .font(.title2)
                    } else {
                        Text("Start counting!")
                    }
                    
                    // Action buttons
                    HStack {
                        Button("Decrement") {
                            if count > 0 {
                                count -= 1
                            }
                        }
                        
                        Button("Increment") {
                            count += 1
                        }
                    }
                }
                .padding()
            }
        }
        """
    }
    
    private var sampleModel: String {
        """
        import Foundation
        
        // MARK: - Data Models
        
        struct User: Codable, Identifiable {
            let id: UUID
            let name: String
            let email: String
            let createdAt: Date
        }
        
        struct Settings: Codable {
            var theme: String = "system"
            var notifications: Bool = true
            var language: String = "en"
        }
        
        // MARK: - Manager
        
        @Observable
        class DataManager {
            static let shared = DataManager()
            
            private(set) var users: [User] = []
            private(set) var settings = Settings()
            
            func loadUsers() async throws {
                // Load from storage
                guard let data = UserDefaults.standard.data(forKey: "users") else {
                    return
                }
                users = try JSONDecoder().decode([User].self, from: data)
            }
            
            func saveUsers() throws {
                let data = try JSONEncoder().encode(users)
                UserDefaults.standard.set(data, forKey: "users")
            }
        }
        """
    }
    
    private var sampleJSON: String {
        """
        {
            "name": "HIG App",
            "version": "1.0.0",
            "settings": {
                "theme": "dark",
                "language": "en",
                "features": {
                    "ai": true,
                    "sync": false
                }
            },
            "endpoints": [
                "https://api.example.com/v1",
                "https://api.example.com/v2"
            ]
        }
        """
    }
    
    private var sampleMarkdown: String {
        """
        # HIG Application
        
        A comprehensive Human Interface Guidelines reference app.
        
        ## Features
        
        - AI-powered knowledge base
        - Interactive code examples
        - Design pattern library
        
        ## Installation
        
        Clone the repository and open in Xcode.
        
        ## Usage
        
        Launch the app and explore the various sections.
        """
    }
    
    private var sampleAnimation: String {
        """
        import SwiftUI
        
        // Animation System
        // Provides spring physics and gesture handling
        
        struct SpringConfig {
            let mass: CGFloat
            let stiffness: CGFloat
            let damping: CGFloat
        }
        
        @Observable
        class AnimationEngine {
            var isAnimating = false
            private var displayLink: CADisplayLink?
            
            func startAnimation(config: SpringConfig) {
                isAnimating = true
                
                // Calculate spring parameters
                let omega = sqrt(config.stiffness / config.mass)
                let zeta = config.damping / (2 * sqrt(config.stiffness * config.mass))
                
                // Run animation loop
                while isAnimating {
                    // Update position
                    // Apply forces
                    // Check settlement
                }
            }
            
            func stopAnimation() {
                isAnimating = false
                displayLink?.invalidate()
            }
        }
        """
    }
    
    private var samplePersistence: String {
        """
        import Foundation
        import SwiftData
        
        // Persistence layer for app data
        
        @Model
        class StoredItem {
            var id: UUID
            var title: String
            var content: String
            var createdAt: Date
            
            init(title: String, content: String) {
                self.id = UUID()
                self.title = title
                self.content = content
                self.createdAt = Date()
            }
        }
        
        class PersistenceController {
            static let shared = PersistenceController()
            
            let container: ModelContainer
            
            init() {
                container = try! ModelContainer(for: StoredItem.self)
            }
        }
        """
    }
    
    private var sampleTests: String {
        """
        import XCTest
        @testable import HIG
        
        final class HIGTests: XCTestCase {
            
            func testUserCreation() {
                let user = User(id: UUID(), name: "Test", email: "test@test.com", createdAt: Date())
                XCTAssertNotNil(user)
                XCTAssertEqual(user.name, "Test")
            }
            
            func testSettingsDefault() {
                let settings = Settings()
                XCTAssertEqual(settings.theme, "system")
                XCTAssertTrue(settings.notifications)
            }
            
            func testDataManagerSingleton() {
                let manager1 = DataManager.shared
                let manager2 = DataManager.shared
                XCTAssertTrue(manager1 === manager2)
            }
        }
        """
    }
    
    private var sampleUtils: String {
        """
        import Foundation
        
        // Utility functions
        
        extension String {
            var isValidEmail: Bool {
                let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
                return range(of: pattern, options: .regularExpression) != nil
            }
        }
        
        extension Date {
            var formatted: String {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: self)
            }
        }
        
        func debounce<T>(delay: TimeInterval, action: @escaping (T) -> Void) -> (T) -> Void {
            var task: Task<Void, Never>?
            return { input in
                task?.cancel()
                task = Task {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    if !Task.isCancelled {
                        action(input)
                    }
                }
            }
        }
        """
    }
}


// MARK: - DNA Strip View

struct DNAStripView: View {
    @State private var analyzer = DNAAnalyzer()
    @State private var viewMode: ViewMode = .strips
    @State private var showLegend = true
    @State private var stripHeight: CGFloat = 24
    
    enum ViewMode: String, CaseIterable {
        case strips = "Strips"
        case grid = "Grid"
        case list = "List"
        
        var icon: String {
            switch self {
            case .strips: return "rectangle.split.1x2"
            case .grid: return "square.grid.3x3"
            case .list: return "list.bullet"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar
            
            Divider()
            
            HStack(spacing: 0) {
                // Main content
                mainContent
                
                // Detail panel
                if let selected = analyzer.selectedFile {
                    Divider()
                    detailPanel(selected)
                        .frame(width: 320)
                }
            }
            
            Divider()
            
            // Legend
            if showLegend {
                legendBar
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            analyzer.loadSampleFiles()
        }
    }
    
    // MARK: - Toolbar
    
    private var toolbar: some View {
        HStack(spacing: 16) {
            // Title
            HStack(spacing: 8) {
                Image(systemName: "dna")
                    .foregroundStyle(.purple)
                Text("DNA Strip View")
                    .font(.headline)
            }
            
            Divider()
                .frame(height: 20)
            
            // View mode picker
            Picker("View", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            // Sort order
            Picker("Sort", selection: $analyzer.sortOrder) {
                ForEach(DNAAnalyzer.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .frame(width: 120)
            
            // Filter by type
            Menu {
                Button("All Types") { analyzer.filterType = nil }
                Divider()
                ForEach(TokenType.allCases, id: \.self) { type in
                    Button {
                        analyzer.filterType = type
                    } label: {
                        Label(type.rawValue, systemImage: type.icon)
                    }
                }
            } label: {
                Label(analyzer.filterType?.rawValue ?? "All Types", systemImage: "line.3.horizontal.decrease.circle")
            }
            
            Spacer()
            
            // Complexity threshold
            HStack(spacing: 8) {
                Text("Min Complexity:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $analyzer.minComplexity, in: 0...1)
                    .frame(width: 100)
                Text("\(Int(analyzer.minComplexity * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }
            
            // Strip height
            HStack(spacing: 8) {
                Text("Height:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $stripHeight, in: 12...48)
                    .frame(width: 80)
            }
            
            Toggle(isOn: $showLegend) {
                Image(systemName: "info.circle")
            }
            .toggleStyle(.button)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        switch viewMode {
        case .strips:
            stripsView
        case .grid:
            gridView
        case .list:
            listView
        }
    }
    
    // MARK: - Strips View
    
    private var stripsView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(analyzer.sortedFiles) { file in
                    DNAStripRow(
                        file: file,
                        height: stripHeight,
                        isSelected: analyzer.selectedFile?.id == file.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            analyzer.selectedFile = file
                        }
                    }
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
            ], spacing: 16) {
                ForEach(analyzer.sortedFiles) { file in
                    DNAGridCard(
                        file: file,
                        isSelected: analyzer.selectedFile?.id == file.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            analyzer.selectedFile = file
                        }
                    }
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        List(analyzer.sortedFiles, selection: Binding(
            get: { analyzer.selectedFile?.id },
            set: { id in
                analyzer.selectedFile = analyzer.files.first { $0.id == id }
            }
        )) { file in
            DNAListRow(file: file)
                .tag(file.id)
        }
    }
    
    // MARK: - Detail Panel
    
    private func detailPanel(_ file: FileDNA) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.fileName)
                            .font(.headline)
                        Text(file.filePath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        analyzer.selectedFile = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                // Stats
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(label: "Lines", value: "\(file.totalLines)")
                    StatRow(label: "Complexity", value: "\(Int(file.complexity * 100))%")
                    StatRow(label: "Dominant Type", value: file.dominantType.rawValue, color: file.dominantType.color)
                    StatRow(label: "File Type", value: file.fileType.uppercased())
                }
                
                Divider()
                
                // Type distribution
                Text("Type Distribution")
                    .font(.caption.weight(.semibold))
                
                VStack(spacing: 8) {
                    ForEach(TokenType.allCases, id: \.self) { type in
                        let percentage = file.typeDistribution[type] ?? 0
                        if percentage > 0 {
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 8, height: 8)
                                Text(type.rawValue)
                                    .font(.caption)
                                Spacer()
                                Text("\(Int(percentage * 100))%")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(type.color.opacity(0.3))
                                    .frame(width: geo.size.width * percentage)
                            }
                            .frame(height: 4)
                        }
                    }
                }
                
                Divider()
                
                // Expanded DNA strip
                Text("DNA Sequence")
                    .font(.caption.weight(.semibold))
                
                ExpandedDNAStrip(file: file)
                
                Divider()
                
                // Segment list
                Text("Segments (\(file.segments.count))")
                    .font(.caption.weight(.semibold))
                
                ForEach(file.segments) { segment in
                    SegmentRow(segment: segment)
                }
            }
            .padding(16)
        }
        .background(Color.secondary.opacity(0.05))
    }
    
    // MARK: - Legend Bar
    
    private var legendBar: some View {
        HStack(spacing: 20) {
            ForEach(TokenType.allCases, id: \.self) { type in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(type.color)
                        .frame(width: 16, height: 12)
                    Text(type.rawValue)
                        .font(.caption2)
                }
            }
            
            Spacer()
            
            Text("\(analyzer.sortedFiles.count) files")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
}

// MARK: - DNA Strip Row

struct DNAStripRow: View {
    let file: FileDNA
    let height: CGFloat
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // File info
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                    Text("\(file.totalLines) lines")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 140, alignment: .leading)
                
                // DNA strip
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(file.segments) { segment in
                            let width = geo.size.width * CGFloat(segment.lineEnd - segment.lineStart) / CGFloat(file.totalLines)
                            Rectangle()
                                .fill(segment.tokenType.color.opacity(0.3 + segment.density * 0.7))
                                .frame(width: max(1, width))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: height)
                
                // Complexity indicator
                ComplexityBadge(complexity: file.complexity)
                    .frame(width: 50)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : (isHovered ? Color.secondary.opacity(0.05) : Color.clear))
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - DNA Grid Card

struct DNAGridCard: View {
    let file: FileDNA
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: file.dominantType.icon)
                        .foregroundStyle(file.dominantType.color)
                    Text(file.fileName)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    ComplexityBadge(complexity: file.complexity)
                }
                
                // DNA strip
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(file.segments) { segment in
                            let width = geo.size.width * CGFloat(segment.lineEnd - segment.lineStart) / CGFloat(file.totalLines)
                            Rectangle()
                                .fill(segment.tokenType.color.opacity(0.3 + segment.density * 0.7))
                                .frame(width: max(1, width))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 40)
                
                // Stats
                HStack {
                    Text("\(file.totalLines) lines")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(file.fileType.uppercased())
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1), in: Capsule())
                }
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - DNA List Row

struct DNAListRow: View {
    let file: FileDNA
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.dominantType.icon)
                .foregroundStyle(file.dominantType.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.body)
                Text(file.filePath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(file.totalLines)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            
            ComplexityBadge(complexity: file.complexity)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Views

struct ComplexityBadge: View {
    let complexity: Double
    
    var color: Color {
        if complexity < 0.3 { return .green }
        if complexity < 0.6 { return .yellow }
        return .red
    }
    
    var body: some View {
        Text("\(Int(complexity * 100))%")
            .font(.caption2.weight(.semibold).monospacedDigit())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2), in: Capsule())
            .foregroundStyle(color)
    }
}

struct DNAStatRow: View {
    let label: String
    let value: String
    var color: Color? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if let color = color {
                HStack(spacing: 4) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(value)
                        .font(.caption.weight(.medium))
                }
            } else {
                Text(value)
                    .font(.caption.weight(.medium))
            }
        }
    }
}

struct ExpandedDNAStrip: View {
    let file: FileDNA
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<min(file.totalLines, 50), id: \.self) { line in
                let segment = file.segments.first { line >= $0.lineStart && line < $0.lineEnd }
                Rectangle()
                    .fill(segment?.tokenType.color ?? .clear)
                    .frame(height: 3)
            }
            
            if file.totalLines > 50 {
                Text("... \(file.totalLines - 50) more lines")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct SegmentRow: View {
    let segment: DNASegment
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(segment.tokenType.color)
                .frame(width: 4, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(segment.tokenType.rawValue)
                    .font(.caption.weight(.medium))
                Text("Lines \(segment.lineStart + 1)-\(segment.lineEnd)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(segment.density * 100))%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    DNAStripView()
        .frame(width: 1200, height: 800)
}
