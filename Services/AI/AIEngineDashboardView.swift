//
//  AIEngineDashboardView.swift
//  HIG
//
//  Dashboard for monitoring and interacting with the Embedded AI Engine
//

import SwiftUI
import Charts

struct AIEngineDashboardView: View {
    @StateObject private var engine = EmbeddedAIEngine.shared
    @State private var promptText = ""
    @State private var selectedContext: GenerationCodeContext = .general
    @State private var generatedCode = ""
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView(selectedTab: $selectedTab, engine: engine)
        } detail: {
            // Main content
            detailContent
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case 0:
            NavigationStack {
                CodeGenerationView(
                    promptText: $promptText,
                    selectedContext: $selectedContext,
                    generatedCode: $generatedCode,
                    isGenerating: $isGenerating,
                    showError: $showError,
                    errorMessage: $errorMessage,
                    engine: engine
                )
            }
        case 1:
            NavigationStack {
                TemplatesView(engine: engine)
            }
        case 2:
            NavigationStack {
                SuggestionsView(engine: engine)
            }
        case 3:
            NavigationStack {
                HistoryView(engine: engine)
            }
        case 4:
            NavigationStack {
                AIEngineSettingsView(engine: engine)
            }
        default:
            NavigationStack {
                CodeGenerationView(
                    promptText: $promptText,
                    selectedContext: $selectedContext,
                    generatedCode: $generatedCode,
                    isGenerating: $isGenerating,
                    showError: $showError,
                    errorMessage: $errorMessage,
                    engine: engine
                )
            }
        }
    }
}

// MARK: - Suggestions View

struct SuggestionsView: View {
    @ObservedObject var engine: EmbeddedAIEngine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text("Code Suggestions")
                    .appText(.title, weight: .bold)
                
                if engine.suggestions.isEmpty {
                    Text("No suggestions available")
                        .appText(.body, color: .secondary)
                } else {
                    ForEach(engine.suggestions) { suggestion in
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text(suggestion.title)
                                .appText(.body, weight: .semibold)
                            Text(suggestion.description)
                                .appText(.caption, color: .secondary)
                        }
                        .padding(DSSpacing.md)
                        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @Binding var selectedTab: Int
    @ObservedObject var engine: EmbeddedAIEngine
    
    var body: some View {
        List(selection: $selectedTab) {
            Section("AI Engine") {
                Label("Generate Code", systemImage: "wand.and.stars")
                    .tag(0)
                Label("Templates", systemImage: "doc.on.doc")
                    .tag(1)
                Label("History", systemImage: "clock.arrow.circlepath")
                    .tag(2)
                Label("Analytics", systemImage: "chart.xyaxis.line")
                    .tag(3)
                Label("Settings", systemImage: "gearshape")
                    .tag(4)
            }
            
            Section("Status") {
                HStack {
                    Circle()
                        .fill(engine.isReady ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(engine.isReady ? "Ready" : "Initializing...")
                        .appText(.caption)
                }
                
                if engine.isGenerating {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Generating...")
                            .appText(.caption)
                    }
                }
            }
            
            Section("Metrics") {
                MetricRow(
                    label: "Templates",
                    value: "\(engine.templateLibrary.count)"
                )
                MetricRow(
                    label: "Generations",
                    value: "\(engine.generationHistory.count)"
                )
                MetricRow(
                    label: "Success Rate",
                    value: String(format: "%.0f%%", engine.learningMetrics.successRate * 100)
                )
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .appText(.caption, color: .secondary)
            Spacer()
            Text(value)
                .appText(.caption, weight: .semibold)
        }
    }
}

// MARK: - Code Generation View

struct CodeGenerationView: View {
    @Binding var promptText: String
    @Binding var selectedContext: GenerationCodeContext
    @Binding var generatedCode: String
    @Binding var isGenerating: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    @ObservedObject var engine: EmbeddedAIEngine
    
    @State private var showVariations = false
    @State private var variations: [CodeVariation] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("AI Code Generation")
                        .appText(.title, weight: .bold)
                    Text("Generate Swift code from natural language descriptions")
                        .appText(.body, color: .secondary)
                }
                
                Divider()
                
                // Input Section
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Prompt")
                        .appText(.heading, weight: .semibold)
                    
                    TextEditor(text: $promptText)
                        .font(.system(.body))
                        .frame(minHeight: 100)
                        .padding(DSSpacing.sm)
                        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Context Picker
                    HStack {
                        Text("Context:")
                            .appText(.body, weight: .medium)
                        
                        Picker("Context", selection: $selectedContext) {
                            Text("General").tag(GenerationCodeContext.general)
                            Text("SwiftUI").tag(GenerationCodeContext.swiftUI)
                            Text("Service").tag(GenerationCodeContext.service)
                            Text("Model").tag(GenerationCodeContext.model)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Action Buttons
                    HStack(spacing: DSSpacing.md) {
                        Button(action: generateCode) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Generate")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!engine.isReady || isGenerating || promptText.isEmpty)
                        
                        Button(action: generateVariations) {
                            HStack {
                                Image(systemName: "square.on.square")
                                Text("Generate Variations")
                            }
                        }
                        .disabled(!engine.isReady || isGenerating || promptText.isEmpty)
                        
                        Button(action: clearAll) {
                            Text("Clear")
                        }
                        .disabled(promptText.isEmpty && generatedCode.isEmpty)
                        
                        Spacer()
                        
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                Divider()
                
                // Output Section
                if !generatedCode.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        HStack {
                            Text("Generated Code")
                                .appText(.heading, weight: .semibold)
                            
                            Spacer()
                            
                            Button(action: copyCode) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        ScrollView {
                            Text(generatedCode)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(DSSpacing.md)
                        }
                        .frame(minHeight: 300)
                        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Suggestions
                        if !engine.suggestions.isEmpty {
                            SuggestionsSection(suggestions: engine.suggestions)
                        }
                    }
                }
                
                // Variations Sheet
                if showVariations && !variations.isEmpty {
                    VariationsSection(variations: variations, onSelect: { code in
                        generatedCode = code
                        showVariations = false
                    })
                }
            }
            .padding(DSSpacing.xl)
        }
    }
    
    private func generateCode() {
        Task {
            isGenerating = true
            defer { isGenerating = false }
            
            do {
                let code = try await engine.generateCode(from: promptText, context: selectedContext)
                generatedCode = code
                
                // Get suggestions
                _ = await engine.suggestImprovements(for: code, context: selectedContext)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func generateVariations() {
        Task {
            isGenerating = true
            defer { isGenerating = false }
            
            do {
                variations = try await engine.generateVariations(from: promptText, count: 3, context: selectedContext)
                showVariations = true
                if let best = variations.first {
                    generatedCode = best.code
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func copyCode() {
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedCode, forType: .string)
        #endif
    }
    
    private func clearAll() {
        promptText = ""
        generatedCode = ""
        variations = []
        showVariations = false
    }
}

// MARK: - Suggestions Section

struct SuggestionsSection: View {
    let suggestions: [IntelligentSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Suggestions")
                .appText(.heading, weight: .semibold)
            
            ForEach(suggestions.prefix(5)) { suggestion in
                SuggestionCard(suggestion: suggestion)
            }
        }
    }
}

struct SuggestionCard: View {
    let suggestion: IntelligentSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: iconForType(suggestion.type))
                    .foregroundStyle(colorForPriority(suggestion.priority))
                
                Text(suggestion.title)
                    .appText(.body, weight: .semibold)
                
                Spacer()
                
                Text(suggestion.priority.description)
                    .appText(.caption)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 2)
                    .background(colorForPriority(suggestion.priority).opacity(0.2), in: Capsule())
            }
            
            Text(suggestion.description)
                .appText(.caption, color: .secondary)
            
            if !suggestion.suggestedFix.isEmpty {
                Text(suggestion.suggestedFix)
                    .appText(.caption)
                    .font(.system(.caption, design: .monospaced))
                    .padding(DSSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.DSBackground.tertiary, in: RoundedRectangle(cornerRadius: DSRadius.sm))
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private func iconForType(_ type: IntelligentSuggestion.SuggestionType) -> String {
        switch type {
        case .designRule: return "ruler"
        case .pattern: return "square.grid.2x2"
        case .optimization: return "speedometer"
        case .accessibility: return "accessibility"
        case .security: return "lock.shield"
        case .performance: return "gauge"
        }
    }
    
    private func colorForPriority(_ priority: RuleViolation.Priority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

extension RuleViolation.Priority {
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// MARK: - Variations Section

struct VariationsSection: View {
    let variations: [CodeVariation]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Code Variations")
                .appText(.heading, weight: .semibold)
            
            ForEach(Array(variations.enumerated()), id: \.offset) { index, variation in
                VariationCard(
                    variation: variation,
                    index: index + 1,
                    onSelect: { onSelect(variation.code) }
                )
            }
        }
    }
}

struct VariationCard: View {
    let variation: CodeVariation
    let index: Int
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Variation \(index)")
                    .appText(.body, weight: .semibold)
                
                Text(styleDescription)
                    .appText(.caption, color: .secondary)
                
                Spacer()
                
                Text(String(format: "Score: %.2f", variation.score))
                    .appText(.caption, weight: .medium)
                
                Button("Use This") {
                    onSelect()
                }
                .buttonStyle(.bordered)
            }
            
            ScrollView {
                Text(variation.code)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 150)
            .padding(DSSpacing.sm)
            .background(Color.DSBackground.tertiary, in: RoundedRectangle(cornerRadius: DSRadius.sm))
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private var styleDescription: String {
        switch variation.style {
        case .concise: return "Concise"
        case .balanced: return "Balanced"
        case .verbose: return "Verbose"
        }
    }
}

// MARK: - Templates View

struct TemplatesView: View {
    @ObservedObject var engine: EmbeddedAIEngine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Code Templates")
                    .appText(.title, weight: .bold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DSSpacing.md) {
                    ForEach(engine.templateLibrary, id: \.id) { template in
                        TemplateCard(template: template)
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct TemplateCard: View {
    let template: CodeTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: iconForCategory(template.category))
                    .foregroundStyle(.blue)
                
                Text(template.name)
                    .appText(.body, weight: .semibold)
                
                Spacer()
            }
            
            Text("Keywords: \(template.keywords.joined(separator: ", "))")
                .appText(.caption, color: .secondary)
            
            Text(String(format: "Relevance: %.0f%%", template.relevanceScore * 100))
                .appText(.caption, weight: .medium)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private func iconForCategory(_ category: TemplateCategory) -> String {
        switch category {
        case .view: return "rectangle.on.rectangle"
        case .model: return "cube"
        case .service: return "gearshape.2"
        case .function: return "function"
        case .general: return "doc"
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @ObservedObject var engine: EmbeddedAIEngine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Generation History")
                    .appText(.title, weight: .bold)
                
                if engine.generationHistory.isEmpty {
                    Text("No generation history yet")
                        .appText(.body, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(DSSpacing.xl)
                } else {
                    ForEach(engine.generationHistory.reversed()) { record in
                        HistoryCard(record: record)
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct HistoryCard: View {
    let record: GenerationRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Text(record.prompt)
                    .appText(.body, weight: .semibold)
                    .lineLimit(2)
                
                Spacer()
                
                Text(record.timestamp, style: .relative)
                    .appText(.caption, color: .secondary)
            }
            
            HStack {
                Label(contextDescription, systemImage: "tag")
                    .appText(.caption, color: .secondary)
                
                if let quality = record.quality {
                    Label(String(format: "Quality: %.0f%%", quality.score * 100), systemImage: "star")
                        .appText(.caption, color: .secondary)
                }
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private var contextDescription: String {
        switch record.context {
        case .swiftUI: return "SwiftUI"
        case .service: return "Service"
        case .model: return "Model"
        case .general: return "General"
        }
    }
}

// MARK: - Analytics View

struct AnalyticsView: View {
    @ObservedObject var engine: EmbeddedAIEngine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("AI Engine Analytics")
                    .appText(.title, weight: .bold)
                
                // Metrics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DSSpacing.md) {
                    AnalyticCard(
                        title: "Total Generations",
                        value: "\(engine.learningMetrics.totalGenerations)",
                        icon: "wand.and.stars",
                        color: .blue
                    )
                    
                    AnalyticCard(
                        title: "Successful",
                        value: "\(engine.learningMetrics.successfulGenerations)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                    
                    AnalyticCard(
                        title: "Failed",
                        value: "\(engine.learningMetrics.failedGenerations)",
                        icon: "xmark.circle",
                        color: .red
                    )
                    
                    AnalyticCard(
                        title: "Success Rate",
                        value: String(format: "%.0f%%", engine.learningMetrics.successRate * 100),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .purple
                    )
                    
                    AnalyticCard(
                        title: "Avg Rating",
                        value: String(format: "%.1f", engine.learningMetrics.averageRating),
                        icon: "star.fill",
                        color: .orange
                    )
                    
                    AnalyticCard(
                        title: "Total Feedback",
                        value: "\(engine.learningMetrics.totalFeedback)",
                        icon: "bubble.left.and.bubble.right",
                        color: .cyan
                    )
                }
                
                Divider()
                
                // Pattern Usage
                if !engine.learningMetrics.patternUsage.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        Text("Pattern Usage")
                            .appText(.heading, weight: .semibold)
                        
                        ForEach(Array(engine.learningMetrics.patternUsage.sorted(by: { $0.value > $1.value })), id: \.key) { pattern, count in
                            HStack {
                                Text(pattern)
                                    .appText(.body)
                                Spacer()
                                Text("\(count)")
                                    .appText(.body, weight: .semibold)
                            }
                            .padding(DSSpacing.sm)
                            .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.sm))
                        }
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 24))
            
            Text(value)
                .appText(.title, weight: .bold)
            
            Text(title)
                .appText(.caption, color: .secondary)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Settings View

struct AIEngineSettingsView: View {
    @ObservedObject var engine: EmbeddedAIEngine
    @State private var enableAutoSuggestions = true
    @State private var maxVariations = 3
    @State private var confidenceThreshold = 0.7
    @State private var enableLearning = true
    
    var body: some View {
        Form {
            Section("Generation Settings") {
                Toggle("Enable Auto Suggestions", isOn: $enableAutoSuggestions)
                
                HStack {
                    Text("Max Variations")
                    Spacer()
                    Stepper("\(maxVariations)", value: $maxVariations, in: 1...5)
                }
                
                VStack(alignment: .leading) {
                    Text("Confidence Threshold: \(String(format: "%.0f%%", confidenceThreshold * 100))")
                    Slider(value: $confidenceThreshold, in: 0.5...1.0)
                }
            }
            
            Section("Learning") {
                Toggle("Enable Learning", isOn: $enableLearning)
                
                Button("Clear History") {
                    // Clear history action
                }
                .foregroundStyle(.red)
                
                Button("Reset Metrics") {
                    // Reset metrics action
                }
                .foregroundStyle(.orange)
            }
            
            Section("Cache") {
                HStack {
                    Text("Template Cache")
                    Spacer()
                    Text("\(engine.templateLibrary.count) items")
                        .foregroundStyle(.secondary)
                }
                
                Button("Clear Cache") {
                    // Clear cache action
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Status", value: engine.isReady ? "Ready" : "Initializing")
                LabeledContent("Templates", value: "\(engine.templateLibrary.count)")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("AI Engine Settings")
    }
}

#Preview {
    AIEngineDashboardView()
        .frame(width: 1400, height: 900)
}
