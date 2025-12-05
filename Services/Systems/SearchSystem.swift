//
//  SearchSystem.swift
//  HIG
//
//  Search System - Full-text, fuzzy, semantic search
//

import SwiftUI

struct SearchSystemView: View {
    @State private var searchText = ""
    @State private var selectedTab = "Search"
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var searchMode: SearchMode = .fullText
    
    enum SearchMode: String, CaseIterable {
        case fullText = "Full-Text"
        case fuzzy = "Fuzzy"
        case semantic = "Semantic"
        case regex = "Regex"
    }
    
    let tabs = ["Search", "Index", "Analytics", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "magnifyingglass").font(.title2).foregroundStyle(.teal)
                Text("Search System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 20).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.teal.opacity(0.2) : Color.clear)
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
                case "Search": SearchView(searchText: $searchText, results: $searchResults, isSearching: $isSearching, mode: $searchMode)
                case "Index": IndexManagementView()
                case "Analytics": SearchAnalyticsView()
                case "Settings": SearchSettingsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct SearchView: View {
    @Binding var searchText: String
    @Binding var results: [SearchResult]
    @Binding var isSearching: Bool
    @Binding var mode: SearchSystemView.SearchMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit { performSearch() }
                    
                    if isSearching {
                        ProgressView().scaleEffect(0.7)
                    }
                    
                    if !searchText.isEmpty {
                        Button { searchText = ""; results = [] } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.controlBackgroundColor)))
                
                // Search Mode
                HStack {
                    Text("Mode:").font(.caption).foregroundStyle(.secondary)
                    Picker("", selection: $mode) {
                        ForEach(SearchSystemView.SearchMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 350)
                    
                    Spacer()
                    
                    Button("Search") { performSearch() }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                }
            }
            .padding()
            
            Divider()
            
            // Results
            if results.isEmpty && !searchText.isEmpty && !isSearching {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("No results found").font(.title3)
                    Text("Try different keywords or search mode").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if results.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("Start searching").font(.title3)
                    Text("Enter keywords to search").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(results.count) results").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Picker("Sort", selection: .constant("Relevance")) {
                            Text("Relevance").tag("Relevance")
                            Text("Date").tag("Date")
                            Text("Title").tag("Title")
                        }
                        .frame(width: 120)
                    }
                    .padding(.horizontal)
                    
                    List {
                        ForEach(results) { result in
                            SystemSearchResultRow(result: result, query: searchText)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            results = SearchResult.samples.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
            if results.isEmpty {
                results = SearchResult.samples // Show all for demo
            }
            isSearching = false
        }
    }
}

struct SystemSearchResultRow: View {
    let result: SearchResult
    let query: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.type.icon).foregroundStyle(result.type.color)
                Text(result.title).font(.subheadline.bold())
                Spacer()
                Text("\(Int(result.score * 100))%").font(.caption).foregroundStyle(.teal)
            }
            
            Text(highlightedContent).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            
            HStack {
                Text(result.type.rawValue).font(.caption2)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Capsule().fill(result.type.color.opacity(0.2)))
                
                Text("•").foregroundStyle(.secondary)
                Text(result.date).font(.caption2).foregroundStyle(.secondary)
                
                Spacer()
                
                ForEach(result.tags.prefix(3), id: \.self) { tag in
                    Text(tag).font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.secondary.opacity(0.2)))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var highlightedContent: AttributedString {
        var content = AttributedString(result.content)
        if let range = content.range(of: query, options: .caseInsensitive) {
            content[range].backgroundColor = .yellow.opacity(0.3)
        }
        return content
    }
}

struct IndexManagementView: View {
    let indexes = [
        ("documents", 12458, "2.4 GB", "Healthy"),
        ("users", 8234, "156 MB", "Healthy"),
        ("products", 45678, "890 MB", "Rebuilding"),
        ("logs", 1234567, "12 GB", "Healthy"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Search Indexes").font(.headline)
                Spacer()
                Button("Create Index") {}.buttonStyle(.bordered)
                Button("Rebuild All") {}.buttonStyle(.borderedProminent).tint(.teal)
            }
            
            List {
                ForEach(indexes, id: \.0) { index in
                    HStack {
                        Image(systemName: "cylinder.fill").foregroundStyle(.teal)
                        
                        VStack(alignment: .leading) {
                            Text(index.0).font(.subheadline.bold())
                            Text("\(index.1) documents • \(index.2)").font(.caption2).foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(index.3).font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(index.3 == "Healthy" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)))
                        
                        Menu {
                            Button("Rebuild") {}
                            Button("Optimize") {}
                            Button("Delete", role: .destructive) {}
                        } label: {
                            Image(systemName: "ellipsis")
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

struct SearchAnalyticsView: View {
    let topQueries = [
        ("product features", 1234),
        ("pricing", 987),
        ("how to", 876),
        ("documentation", 654),
        ("api reference", 543),
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Stats
            HStack(spacing: 16) {
                SearchStatCard(title: "Total Searches", value: "45,678", change: "+12%", icon: "magnifyingglass")
                SearchStatCard(title: "Avg. Results", value: "23.4", change: "+5%", icon: "list.bullet")
                SearchStatCard(title: "Click Rate", value: "68%", change: "+3%", icon: "cursorarrow.click")
                SearchStatCard(title: "Zero Results", value: "4.2%", change: "-1%", icon: "xmark.circle")
            }
            
            HStack(spacing: 16) {
                // Top Queries
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top Queries").font(.headline)
                    
                    ForEach(topQueries, id: \.0) { query in
                        HStack {
                            Text(query.0).font(.subheadline)
                            Spacer()
                            Text("\(query.1)").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                
                // Search Trends
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Trends").font(.headline)
                    SearchTrendChart()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            }
        }
        .padding()
    }
}

struct SearchStatCard: View {
    let title: String
    let value: String
    let change: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundStyle(.teal)
                Spacer()
                Text(change).font(.caption).foregroundStyle(change.hasPrefix("+") ? .green : .red)
            }
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct SearchTrendChart: View {
    let data: [Double] = [20, 35, 25, 45, 30, 50, 40, 55, 45, 60, 50, 65]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 100
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            
            Path { path in
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height * (1 - CGFloat(value) / maxValue)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.teal, lineWidth: 2)
        }
        .frame(height: 150)
    }
}

struct SearchSettingsView: View {
    @State private var fuzzyEnabled = true
    @State private var semanticEnabled = false
    @State private var minScore = 0.5
    @State private var maxResults = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Search Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Fuzzy Search", isOn: $fuzzyEnabled)
                Toggle("Semantic Search (AI)", isOn: $semanticEnabled)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Minimum Score: \(Int(minScore * 100))%")
                    Slider(value: $minScore, in: 0...1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Results: \(maxResults)")
                    Slider(value: Binding(get: { Double(maxResults) }, set: { maxResults = Int($0) }), in: 10...200, step: 10)
                }
                
                Divider()
                
                Text("Synonyms").font(.subheadline)
                Text("Configure search synonyms to improve results").font(.caption).foregroundStyle(.secondary)
                Button("Manage Synonyms") {}.buttonStyle(.bordered)
                
                Text("Stop Words").font(.subheadline)
                Text("Words to ignore during search").font(.caption).foregroundStyle(.secondary)
                Button("Manage Stop Words") {}.buttonStyle(.bordered)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let type: ResultType
    let score: Double
    let date: String
    let tags: [String]
    
    enum ResultType: String {
        case document = "Document"
        case page = "Page"
        case product = "Product"
        case user = "User"
        
        var icon: String {
            switch self {
            case .document: return "doc.fill"
            case .page: return "globe"
            case .product: return "shippingbox.fill"
            case .user: return "person.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .document: return .blue
            case .page: return .green
            case .product: return .orange
            case .user: return .purple
            }
        }
    }
    
    static var samples: [SearchResult] {
        [
            SearchResult(title: "Getting Started Guide", content: "Learn how to set up your account and start using our platform with this comprehensive guide.", type: .document, score: 0.95, date: "Nov 25, 2024", tags: ["Guide", "Tutorial"]),
            SearchResult(title: "API Documentation", content: "Complete reference for all API endpoints, authentication, and best practices.", type: .page, score: 0.88, date: "Nov 20, 2024", tags: ["API", "Reference"]),
            SearchResult(title: "Premium Subscription", content: "Unlock all features with our premium subscription plan. Includes priority support.", type: .product, score: 0.82, date: "Nov 15, 2024", tags: ["Premium", "Subscription"]),
            SearchResult(title: "John Smith", content: "Senior Developer at Acme Corp. Expert in Swift and iOS development.", type: .user, score: 0.75, date: "Nov 10, 2024", tags: ["Developer", "iOS"]),
        ]
    }
}

#Preview {
    SearchSystemView()
        .frame(width: 1000, height: 700)
}
