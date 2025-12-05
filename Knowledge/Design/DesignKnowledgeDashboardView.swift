//
//  DesignKnowledgeDashboardView.swift
//  HIG
//
//  Dashboard for browsing and managing design knowledge
//

import SwiftUI

struct DesignKnowledgeDashboardView: View {
    @StateObject private var knowledge = DesignKnowledgeSystem.shared
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedTab) {
                Section("Design Knowledge") {
                    Label("Patterns", systemImage: "square.grid.2x2")
                        .tag(0)
                    Label("Guidelines", systemImage: "list.bullet.clipboard")
                        .tag(1)
                    Label("Examples", systemImage: "doc.richtext")
                        .tag(2)
                    Label("Components", systemImage: "cube.box")
                        .tag(3)
                }
                
                Section("Statistics") {
                    HStack {
                        Text("Patterns")
                        Spacer()
                        Text("\(knowledge.patterns.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Guidelines")
                        Spacer()
                        Text("\(knowledge.guidelines.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Examples")
                        Spacer()
                        Text("\(knowledge.examples.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220)
        } detail: {
            TabView(selection: $selectedTab) {
                PatternsView(knowledge: knowledge, searchText: $searchText)
                    .tag(0)
                
                GuidelinesView(knowledge: knowledge, searchText: $searchText)
                    .tag(1)
                
                ExamplesView(knowledge: knowledge, searchText: $searchText)
                    .tag(2)
                
                ComponentsView(knowledge: knowledge)
                    .tag(3)
            }
            .tabViewStyle(.automatic)
            .searchable(text: $searchText, prompt: "Search knowledge base")
        }
        .navigationTitle("Design Knowledge")
    }
}

// MARK: - Patterns View

struct PatternsView: View {
    @ObservedObject var knowledge: DesignKnowledgeSystem
    @Binding var searchText: String
    
    var filteredPatterns: [UIDesignPattern] {
        if searchText.isEmpty {
            return knowledge.patterns
        }
        return knowledge.patterns.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Design Patterns")
                    .appText(.title, weight: .bold)
                
                if filteredPatterns.isEmpty {
                    Text("No patterns found")
                        .appText(.body, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(DSSpacing.xl)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DSSpacing.md) {
                        ForEach(filteredPatterns) { pattern in
                            PatternCard(pattern: pattern)
                        }
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct PatternCard: View {
    let pattern: UIDesignPattern
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(.blue)
                
                Text(pattern.name)
                    .appText(.body, weight: .semibold)
                
                Spacer()
            }
            
            Text(pattern.description)
                .appText(.caption, color: .secondary)
                .lineLimit(3)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Guidelines View

struct GuidelinesView: View {
    @ObservedObject var knowledge: DesignKnowledgeSystem
    @Binding var searchText: String
    
    var filteredGuidelines: [DesignGuideline] {
        if searchText.isEmpty {
            return knowledge.guidelines
        }
        return knowledge.guidelines.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Design Guidelines")
                    .appText(.title, weight: .bold)
                
                if filteredGuidelines.isEmpty {
                    Text("No guidelines found")
                        .appText(.body, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(DSSpacing.xl)
                } else {
                    ForEach(filteredGuidelines) { guideline in
                        GuidelineCard(guideline: guideline)
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct GuidelineCard: View {
    let guideline: DesignGuideline
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: categoryIcon)
                    .foregroundStyle(categoryColor)
                
                Text(guideline.title)
                    .appText(.body, weight: .semibold)
                
                Spacer()
                
                Text(String(describing: guideline.category))
                    .appText(.caption)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.2), in: Capsule())
            }
            
            Text(guideline.description)
                .appText(.body, color: .secondary)
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    private var categoryIcon: String {
        switch guideline.category.lowercased() {
        case "layout": return "rectangle.3.group"
        case "typography": return "textformat"
        case "color": return "paintpalette"
        case "interaction": return "hand.tap"
        case "accessibility": return "accessibility"
        case "animation": return "wand.and.stars"
        default: return "questionmark.circle"
        }
    }
    
    private var categoryColor: Color {
        switch guideline.category.lowercased() {
        case "layout": return .blue
        case "typography": return .purple
        case "color": return .orange
        case "interaction": return .green
        case "accessibility": return .cyan
        case "animation": return .pink
        default: return .gray
        }
    }
}

// MARK: - Examples View

struct ExamplesView: View {
    @ObservedObject var knowledge: DesignKnowledgeSystem
    @Binding var searchText: String
    
    var filteredExamples: [DesignExample] {
        if searchText.isEmpty {
            return knowledge.examples
        }
        return knowledge.examples.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Code Examples")
                    .appText(.title, weight: .bold)
                
                if filteredExamples.isEmpty {
                    Text("No examples found")
                        .appText(.body, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(DSSpacing.xl)
                } else {
                    ForEach(filteredExamples) { example in
                        ExampleCard(example: example)
                    }
                }
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct ExampleCard: View {
    let example: DesignExample
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "doc.richtext")
                        .foregroundStyle(.green)
                    
                    Text(example.title)
                        .appText(.body, weight: .semibold)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            Text(example.description)
                .appText(.caption, color: .secondary)
            
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(example.code)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(DSSpacing.sm)
                }
                .frame(maxHeight: 200)
                .background(Color.DSBackground.tertiary, in: RoundedRectangle(cornerRadius: DSRadius.sm))
            }
        }
        .padding(DSSpacing.md)
        .background(Color.DSBackground.secondary, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Components View

struct ComponentsView: View {
    @ObservedObject var knowledge: DesignKnowledgeSystem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                Text("Design Components")
                    .appText(.title, weight: .bold)
                
                Text("Component library coming soon")
                    .appText(.body, color: .secondary)
            }
            .padding(DSSpacing.xl)
        }
    }
}

#Preview {
    DesignKnowledgeDashboardView()
        .frame(width: 1200, height: 800)
}
