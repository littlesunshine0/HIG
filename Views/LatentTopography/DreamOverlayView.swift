//
//  DreamOverlayView.swift
//  HIG
//
//  Dream Overlay: Split-screen showing raw source code and AI's "Dream" (predicted output)
//  Left: Source code/markdown  |  Right: Simulated render/output
//

import SwiftUI

// MARK: - Dream Content Types

enum DreamContentType: String, CaseIterable {
    case swiftCode = "Swift"
    case python = "Python"
    case markdown = "Markdown"
    case json = "JSON"
    case screenplay = "Screenplay"
    case html = "HTML"
    
    var icon: String {
        switch self {
        case .swiftCode: return "swift"
        case .python: return "chevron.left.forwardslash.chevron.right"
        case .markdown: return "text.badge.checkmark"
        case .json: return "curlybraces"
        case .screenplay: return "film"
        case .html: return "globe"
        }
    }
    
    var dreamDescription: String {
        switch self {
        case .swiftCode: return "Predicted UI Preview"
        case .python: return "Console Output Prediction"
        case .markdown: return "Rendered Document"
        case .json: return "Structured Data View"
        case .screenplay: return "Storyboard Sketch"
        case .html: return "Browser Preview"
        }
    }
}

// MARK: - Dream Analysis Result

struct DreamAnalysis {
    let contentType: DreamContentType
    let confidence: Double
    let predictions: [DreamPrediction]
    let warnings: [String]
    let suggestions: [String]
}

struct DreamPrediction {
    let type: PredictionType
    let content: String
    let lineRange: Range<Int>?
    
    enum PredictionType {
        case output
        case uiElement
        case storyboardFrame
        case dataStructure
        case warning
    }
}

// MARK: - Dream Engine

@Observable
class DreamEngine {
    var sourceCode: String = ""
    var contentType: DreamContentType = .swiftCode
    var analysis: DreamAnalysis?
    var isAnalyzing = false
    var dreamOpacity: Double = 1.0
    
    func analyze() async {
        isAnalyzing = true
        
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let predictions = generatePredictions()
        let warnings = detectWarnings()
        let suggestions = generateSuggestions()
        
        analysis = DreamAnalysis(
            contentType: contentType,
            confidence: Double.random(in: 0.75...0.98),
            predictions: predictions,
            warnings: warnings,
            suggestions: suggestions
        )
        
        isAnalyzing = false
    }
    
    private func generatePredictions() -> [DreamPrediction] {
        switch contentType {
        case .swiftCode:
            return parseSwiftUI()
        case .python:
            return parsePython()
        case .markdown:
            return parseMarkdown()
        case .json:
            return parseJSON()
        case .screenplay:
            return parseScreenplay()
        case .html:
            return parseHTML()
        }
    }
    
    private func parseSwiftUI() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        
        if sourceCode.contains("VStack") || sourceCode.contains("HStack") {
            predictions.append(DreamPrediction(
                type: .uiElement,
                content: "Stack Layout Container",
                lineRange: nil
            ))
        }
        
        if sourceCode.contains("Text(") {
            let textMatches = sourceCode.matches(of: /Text\("([^"]+)"\)/)
            for match in textMatches {
                predictions.append(DreamPrediction(
                    type: .uiElement,
                    content: String(match.1),
                    lineRange: nil
                ))
            }
        }
        
        if sourceCode.contains("Button") {
            predictions.append(DreamPrediction(
                type: .uiElement,
                content: "Interactive Button",
                lineRange: nil
            ))
        }
        
        if sourceCode.contains("Image(") {
            predictions.append(DreamPrediction(
                type: .uiElement,
                content: "Image View",
                lineRange: nil
            ))
        }
        
        return predictions
    }
    
    private func parsePython() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        
        let printMatches = sourceCode.matches(of: /print\(([^)]+)\)/)
        for match in printMatches {
            let content = String(match.1).replacingOccurrences(of: "\"", with: "")
            predictions.append(DreamPrediction(
                type: .output,
                content: ">>> \(content)",
                lineRange: nil
            ))
        }
        
        if sourceCode.contains("def ") {
            predictions.append(DreamPrediction(
                type: .output,
                content: "Function defined successfully",
                lineRange: nil
            ))
        }
        
        return predictions
    }
    
    private func parseMarkdown() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        
        let lines = sourceCode.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("# ") {
                predictions.append(DreamPrediction(
                    type: .output,
                    content: "H1: \(line.dropFirst(2))",
                    lineRange: nil
                ))
            } else if line.hasPrefix("## ") {
                predictions.append(DreamPrediction(
                    type: .output,
                    content: "H2: \(line.dropFirst(3))",
                    lineRange: nil
                ))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                predictions.append(DreamPrediction(
                    type: .output,
                    content: "• \(line.dropFirst(2))",
                    lineRange: nil
                ))
            }
        }
        
        return predictions
    }
    
    private func parseJSON() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        
        if let data = sourceCode.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) {
            if let dict = json as? [String: Any] {
                for (key, value) in dict {
                    predictions.append(DreamPrediction(
                        type: .dataStructure,
                        content: "\(key): \(type(of: value))",
                        lineRange: nil
                    ))
                }
            }
        }
        
        return predictions
    }
    
    private func parseScreenplay() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        let lines = sourceCode.components(separatedBy: "\n")
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.uppercased() == trimmed && !trimmed.isEmpty && trimmed.count > 3 {
                // Scene heading or character name
                predictions.append(DreamPrediction(
                    type: .storyboardFrame,
                    content: "SCENE: \(trimmed)",
                    lineRange: nil
                ))
            }
        }
        
        return predictions
    }
    
    private func parseHTML() -> [DreamPrediction] {
        var predictions: [DreamPrediction] = []
        
        let tagPattern = /<(\w+)[^>]*>([^<]*)<\/\1>/
        let matches = sourceCode.matches(of: tagPattern)
        
        for match in matches {
            predictions.append(DreamPrediction(
                type: .uiElement,
                content: "<\(match.1)> \(match.2)",
                lineRange: nil
            ))
        }
        
        return predictions
    }
    
    private func detectWarnings() -> [String] {
        var warnings: [String] = []
        
        if sourceCode.contains("!") && contentType == .swiftCode {
            warnings.append("Force unwrap detected - potential crash risk")
        }
        
        if sourceCode.contains("TODO") || sourceCode.contains("FIXME") {
            warnings.append("Unresolved TODO/FIXME comments found")
        }
        
        if sourceCode.count > 500 && !sourceCode.contains("//") {
            warnings.append("Large code block without comments")
        }
        
        return warnings
    }
    
    private func generateSuggestions() -> [String] {
        var suggestions: [String] = []
        
        if contentType == .swiftCode {
            if !sourceCode.contains("@State") && sourceCode.contains("var ") {
                suggestions.append("Consider using @State for mutable view properties")
            }
            if sourceCode.contains("Color(") && !sourceCode.contains(".opacity") {
                suggestions.append("Add opacity modifiers for better visual hierarchy")
            }
        }
        
        return suggestions
    }
}


// MARK: - Dream Overlay View

struct DreamOverlayView: View {
    @State private var engine = DreamEngine()
    @State private var splitRatio: CGFloat = 0.5
    @State private var showDiff = false
    @State private var syncScroll = true
    @State private var sourceScrollOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            toolbar
            
            Divider()
            
            // Split view
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left: Source Code
                    sourcePanel
                        .frame(width: geometry.size.width * splitRatio)
                    
                    // Divider with drag handle
                    splitDivider
                    
                    // Right: Dream (Predicted Output)
                    dreamPanel
                        .frame(width: geometry.size.width * (1 - splitRatio) - 8)
                }
            }
            
            Divider()
            
            // Bottom status bar
            statusBar
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onChange(of: engine.sourceCode) {
            Task {
                await engine.analyze()
            }
        }
        .onAppear {
            loadSampleCode()
        }
    }
    
    // MARK: - Toolbar
    
    private var toolbar: some View {
        HStack(spacing: 16) {
            // Content type picker
            Picker("Type", selection: $engine.contentType) {
                ForEach(DreamContentType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 140)
            
            Divider()
                .frame(height: 20)
            
            // View controls
            Toggle(isOn: $showDiff) {
                Label("Show Diff", systemImage: "arrow.left.arrow.right")
            }
            .toggleStyle(.button)
            
            Toggle(isOn: $syncScroll) {
                Label("Sync Scroll", systemImage: "link")
            }
            .toggleStyle(.button)
            
            Spacer()
            
            // Dream opacity slider
            HStack(spacing: 8) {
                Image(systemName: "moon.stars")
                    .foregroundStyle(.secondary)
                Slider(value: $engine.dreamOpacity, in: 0...1)
                    .frame(width: 100)
                Text("\(Int(engine.dreamOpacity * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            // Refresh button
            Button {
                Task { await engine.analyze() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(engine.isAnalyzing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
    
    // MARK: - Source Panel
    
    private var sourcePanel: some View {
        VStack(spacing: 0) {
            // Panel header
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.blue)
                Text("Source")
                    .font(.headline)
                Spacer()
                Text("\(engine.sourceCode.count) chars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            
            // Code editor
            ScrollView {
                CodeEditorView(
                    code: $engine.sourceCode,
                    contentType: engine.contentType,
                    highlightRanges: showDiff ? diffHighlights : []
                )
                .padding(12)
            }
        }
    }
    
    // MARK: - Dream Panel
    
    private var dreamPanel: some View {
        VStack(spacing: 0) {
            // Panel header
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(.purple)
                Text("Dream")
                    .font(.headline)
                Text("(\(engine.contentType.dreamDescription))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                
                if engine.isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.7)
                } else if let analysis = engine.analysis {
                    Text("\(Int(analysis.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.1))
            
            // Dream content
            ScrollView {
                DreamContentView(
                    analysis: engine.analysis,
                    contentType: engine.contentType,
                    sourceCode: engine.sourceCode
                )
                .opacity(engine.dreamOpacity)
                .padding(12)
            }
        }
    }
    
    // MARK: - Split Divider
    
    private var splitDivider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 8)
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 4, height: 40)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newRatio = splitRatio + value.translation.width / 1000
                        splitRatio = max(0.2, min(0.8, newRatio))
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
    
    // MARK: - Status Bar
    
    private var statusBar: some View {
        HStack(spacing: 16) {
            // Warnings
            if let analysis = engine.analysis, !analysis.warnings.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("\(analysis.warnings.count) warnings")
                        .font(.caption)
                }
            }
            
            // Suggestions
            if let analysis = engine.analysis, !analysis.suggestions.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("\(analysis.suggestions.count) suggestions")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Predictions count
            if let analysis = engine.analysis {
                Text("\(analysis.predictions.count) predictions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
    
    private var diffHighlights: [Range<Int>] {
        // Return line ranges that differ from prediction
        []
    }
    
    private func loadSampleCode() {
        engine.sourceCode = """
        struct ContentView: View {
            @State private var count = 0
            
            var body: some View {
                VStack(spacing: 20) {
                    Text("Hello, World!")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    
                    Text("Count: \\(count)")
                        .font(.title2)
                    
                    Button("Increment") {
                        count += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        """
        
        Task { await engine.analyze() }
    }
}

// MARK: - Code Editor View

struct CodeEditorView: View {
    @Binding var code: String
    let contentType: DreamContentType
    let highlightRanges: [Range<Int>]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let lines = code.components(separatedBy: "\n")
            
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(alignment: .top, spacing: 8) {
                    // Line number
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .frame(width: 30, alignment: .trailing)
                    
                    // Code line with syntax highlighting
                    SyntaxHighlightedText(text: line, contentType: contentType)
                }
                .padding(.vertical, 2)
                .background(
                    highlightRanges.contains(where: { $0.contains(index) })
                    ? Color.yellow.opacity(0.2)
                    : Color.clear
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SyntaxHighlightedText: View {
    let text: String
    let contentType: DreamContentType
    
    var body: some View {
        Text(attributedString)
            .font(.system(.body, design: .monospaced))
    }
    
    private var attributedString: AttributedString {
        var result = AttributedString(text)
        
        // Keywords
        let keywords = ["struct", "var", "let", "func", "if", "else", "for", "while", "return", "import", "class", "enum", "case", "switch", "guard", "private", "public", "static", "@State", "@Binding", "@Observable", "some", "View", "body"]
        
        for keyword in keywords {
            if let range = result.range(of: keyword) {
                result[range].foregroundColor = .purple
                result[range].font = .system(.body, design: .monospaced).bold()
            }
        }
        
        // Strings
        let stringPattern = /"[^"]*"/
        for match in text.matches(of: stringPattern) {
            if let range = result.range(of: String(match.0)) {
                result[range].foregroundColor = .red
            }
        }
        
        // Numbers
        let numberPattern = /\b\d+\b/
        for match in text.matches(of: numberPattern) {
            if let range = result.range(of: String(match.0)) {
                result[range].foregroundColor = .cyan
            }
        }
        
        // Comments
        if text.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
            result.foregroundColor = .green
        }
        
        return result
    }
}

// MARK: - Dream Content View

struct DreamContentView: View {
    let analysis: DreamAnalysis?
    let contentType: DreamContentType
    let sourceCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysis {
                switch contentType {
                case .swiftCode:
                    SwiftUIDreamPreview(predictions: analysis.predictions)
                case .python:
                    PythonConsoleDream(predictions: analysis.predictions)
                case .markdown:
                    MarkdownDreamPreview(predictions: analysis.predictions, source: sourceCode)
                case .json:
                    JSONStructureDream(predictions: analysis.predictions, source: sourceCode)
                case .screenplay:
                    StoryboardDream(predictions: analysis.predictions)
                case .html:
                    HTMLPreviewDream(source: sourceCode)
                }
                
                // Warnings section
                if !analysis.warnings.isEmpty {
                    Divider()
                    WarningsSection(warnings: analysis.warnings)
                }
                
                // Suggestions section
                if !analysis.suggestions.isEmpty {
                    DreamSuggestionsSection(suggestions: analysis.suggestions)
                }
            } else {
                DreamLoadingView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Dream Preview Components

struct SwiftUIDreamPreview: View {
    let predictions: [DreamPrediction]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Predicted UI")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            // Simulated device frame
            VStack(spacing: 12) {
                ForEach(Array(predictions.enumerated()), id: \.offset) { _, prediction in
                    switch prediction.type {
                    case .uiElement:
                        if prediction.content.contains("Stack") {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(height: 100)
                                .overlay {
                                    Text(prediction.content)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                        } else if prediction.content.contains("Button") {
                            Button(prediction.content) {}
                                .buttonStyle(.borderedProminent)
                        } else if prediction.content.contains("Image") {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .frame(width: 60, height: 60)
                                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        } else {
                            Text(prediction.content)
                                .padding(8)
                                .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 4))
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            .padding(20)
            .background(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            }
        }
    }
}

struct PythonConsoleDream: View {
    let predictions: [DreamPrediction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Console Output")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(predictions.enumerated()), id: \.offset) { _, prediction in
                    Text(prediction.content)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.green)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct MarkdownDreamPreview: View {
    let predictions: [DreamPrediction]
    let source: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rendered Document")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(predictions.enumerated()), id: \.offset) { _, prediction in
                    if prediction.content.hasPrefix("H1:") {
                        Text(prediction.content.dropFirst(4))
                            .font(.title.bold())
                    } else if prediction.content.hasPrefix("H2:") {
                        Text(prediction.content.dropFirst(4))
                            .font(.title2.bold())
                    } else if prediction.content.hasPrefix("•") {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(prediction.content.dropFirst(2))
                        }
                    } else {
                        Text(prediction.content)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct JSONStructureDream: View {
    let predictions: [DreamPrediction]
    let source: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Structure")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(predictions.enumerated()), id: \.offset) { _, prediction in
                    HStack {
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(prediction.content)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct StoryboardDream: View {
    let predictions: [DreamPrediction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storyboard Frames")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(predictions.enumerated()), id: \.offset) { index, prediction in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 80)
                            .overlay {
                                Image(systemName: "film")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            }
                        
                        Text(prediction.content)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
}

struct HTMLPreviewDream: View {
    let source: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browser Preview")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack {
                // Browser chrome
                HStack(spacing: 6) {
                    Circle().fill(.red).frame(width: 10, height: 10)
                    Circle().fill(.yellow).frame(width: 10, height: 10)
                    Circle().fill(.green).frame(width: 10, height: 10)
                    Spacer()
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                
                // Content area
                Text("HTML Preview")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            }
        }
    }
}

struct WarningsSection: View {
    let warnings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Warnings", systemImage: "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
            
            ForEach(warnings, id: \.self) { warning in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.orange)
                    Text(warning)
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DreamSuggestionsSection: View {
    let suggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Suggestions", systemImage: "lightbulb.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.yellow)
            
            ForEach(suggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.yellow)
                    Text(suggestion)
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DreamLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Dreaming...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DreamOverlayView()
        .frame(width: 1200, height: 800)
}
