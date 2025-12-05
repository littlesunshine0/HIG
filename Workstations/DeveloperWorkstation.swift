//
//  DeveloperWorkstation.swift
//  HIG
//
//  Developer workstation: Code editor + Terminal + Documentation
//  Physics-based animations with liquid glass materials
//

import SwiftUI
import Observation

// MARK: - Developer State

@MainActor
@Observable
final class DeveloperState {
    var currentFile: String = "ContentView.swift"
    var terminalOutput: [String] = ["$ swift build", "Building..."]
    var selectedDoc: String? = nil
    var isCompiling: Bool = false
    
    func compile() async {
        isCompiling = true
        terminalOutput.append("Compiling \(currentFile)...")
        
        try? await Task.sleep(for: .seconds(2))
        
        terminalOutput.append("✓ Build succeeded")
        isCompiling = false
    }
}

// MARK: - Developer Workstation

struct DeveloperWorkstation: View {
    @State private var state = DeveloperState()
    @Namespace private var editorSpace
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Left: File tree + Editor
                VStack(spacing: 12) {
                    fileTreePanel
                        .frame(height: geometry.size.height * 0.3)
                    
                    codeEditorPanel
                        .frame(maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.5)
                
                // Right: Terminal + Docs
                VStack(spacing: 12) {
                    terminalPanel
                        .frame(height: geometry.size.height * 0.4)
                    
                    documentationPanel
                        .frame(maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.5)
            }
            .padding(12)
        }
    }
    
    // MARK: - File Tree
    
    private var fileTreePanel: some View {
        LiquidGlassPanel(
            title: "Files",
            icon: "folder.fill",
            color: .blue
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    FileRow(name: "ContentView.swift", icon: "doc.text", isSelected: true)
                    FileRow(name: "Models.swift", icon: "doc.text", isSelected: false)
                    FileRow(name: "Networking.swift", icon: "doc.text", isSelected: false)
                }
                .padding(12)
            }
        }
    }
    
    // MARK: - Code Editor
    
    private var codeEditorPanel: some View {
        LiquidGlassPanel(
            title: state.currentFile,
            icon: "chevron.left.forwardslash.chevron.right",
            color: .blue
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    CodeLine(number: 1, text: "import SwiftUI")
                    CodeLine(number: 2, text: "")
                    CodeLine(number: 3, text: "struct ContentView: View {")
                    CodeLine(number: 4, text: "    var body: some View {")
                    CodeLine(number: 5, text: "        Text(\"Hello, World!\")")
                    CodeLine(number: 6, text: "    }")
                    CodeLine(number: 7, text: "}")
                }
                .padding(12)
            }
            .background(Color.black.opacity(0.05))
        }
    }
    
    // MARK: - Terminal
    
    private var terminalPanel: some View {
        LiquidGlassPanel(
            title: "Terminal",
            icon: "terminal.fill",
            color: .green
        ) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(state.terminalOutput, id: \.self) { line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                        
                        if state.isCompiling {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Compiling...")
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                }
                .background(Color.black.opacity(0.05))
                
                Divider()
                
                HStack {
                    Text("$")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.green)
                    
                    TextField("command", text: .constant(""))
                        .textFieldStyle(.plain)
                        .font(.system(.caption, design: .monospaced))
                    
                    Button {
                        Task {
                            await state.compile()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
            }
        }
    }
    
    // MARK: - Documentation
    
    private var documentationPanel: some View {
        LiquidGlassPanel(
            title: "Documentation",
            icon: "book.fill",
            color: .orange
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DocSection(title: "SwiftUI", items: ["View", "State", "Binding"])
                    DocSection(title: "Foundation", items: ["String", "Array", "Dictionary"])
                    DocSection(title: "Combine", items: ["Publisher", "Subscriber"])
                }
                .padding(12)
            }
        }
    }
}

// MARK: - Supporting Views

struct FileRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: 4))
    }
}

struct CodeLine: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 24, alignment: .trailing)
            
            Text(text)
                .font(.system(.caption, design: .monospaced))
        }
    }
}

struct DocSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(item)
                        .font(.caption)
                }
                .padding(.leading, 12)
            }
        }
    }
}

// MARK: - Previews

#Preview("Developer Workstation") {
    DeveloperWorkstation()
        .frame(width: 1200, height: 800)
}

#Preview("File Row - Selected") {
    FileRow(name: "ContentView.swift", icon: "doc.text", isSelected: true)
        .padding()
}

#Preview("File Row - Unselected") {
    FileRow(name: "Models.swift", icon: "doc.text", isSelected: false)
        .padding()
}

#Preview("Code Line") {
    VStack(alignment: .leading, spacing: 4) {
        CodeLine(number: 1, text: "import SwiftUI")
        CodeLine(number: 2, text: "")
        CodeLine(number: 3, text: "struct ContentView: View {")
        CodeLine(number: 4, text: "    var body: some View {")
        CodeLine(number: 5, text: "        Text(\"Hello, World!\")")
        CodeLine(number: 6, text: "    }")
        CodeLine(number: 7, text: "}")
    }
    .padding()
    .background(Color.black.opacity(0.05))
}

#Preview("Doc Section") {
    DocSection(title: "SwiftUI", items: ["View", "State", "Binding", "ObservableObject"])
        .padding()
}
