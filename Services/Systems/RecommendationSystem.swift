//
//  RecommendationSystem.swift
//  HIG
//
//  Recommendation System - Content suggestions based on user behavior
//

import SwiftUI

struct RecommendationSystemView: View {
    @State private var selectedTab = "For You"
    
    let tabs = ["For You", "Trending", "Similar", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "sparkles").font(.title2).foregroundStyle(.yellow)
                Text("Recommendation System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.yellow.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "For You": ForYouView()
                case "Trending": TrendingView()
                case "Similar": SimilarItemsView()
                case "Settings": RecommendationSettingsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct ForYouView: View {
    let recommendations = [
        ("Advanced SwiftUI Patterns", "Based on your recent views", "book.fill", Color.blue, 95),
        ("Project Management Tips", "Popular in your network", "folder.fill", Color.green, 88),
        ("Design System Guide", "Similar to items you liked", "paintbrush.fill", Color.purple, 82),
        ("API Best Practices", "Trending in your field", "server.rack", Color.orange, 79),
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Personalized Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Personalized for You").font(.headline)
                        Spacer()
                        Button("Refresh") {}.buttonStyle(.bordered)
                    }
                    
                    ForEach(recommendations, id: \.0) { rec in
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(rec.3.opacity(0.2)).frame(width: 60, height: 60)
                                Image(systemName: rec.2).font(.title2).foregroundStyle(rec.3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rec.0).font(.subheadline.bold())
                                Text(rec.1).font(.caption).foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(rec.4)%").font(.caption.bold()).foregroundStyle(.yellow)
                                Text("match").font(.caption2).foregroundStyle(.secondary)
                            }
                            
                            Button { } label: { Image(systemName: "plus.circle") }.buttonStyle(.bordered)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    }
                }
                
                // Why Recommended
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why These Recommendations?").font(.headline)
                    
                    HStack(spacing: 16) {
                        ReasonCard(icon: "eye.fill", title: "Viewing History", description: "Based on 45 items viewed")
                        ReasonCard(icon: "heart.fill", title: "Your Likes", description: "12 similar items liked")
                        ReasonCard(icon: "person.2.fill", title: "Network Activity", description: "Popular with connections")
                    }
                }
            }
            .padding()
        }
    }
}

struct ReasonCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(.yellow)
            Text(title).font(.caption.bold())
            Text(description).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct TrendingView: View {
    let trending = [
        ("AI Integration Guide", 1250, "+45%", "trending"),
        ("SwiftUI 5 Features", 980, "+32%", "hot"),
        ("Cloud Architecture", 756, "+28%", "trending"),
        ("Security Best Practices", 654, "+22%", "new"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trending Now").font(.headline)
                Spacer()
                Picker("Time", selection: .constant("Today")) {
                    Text("Today").tag("Today")
                    Text("This Week").tag("This Week")
                    Text("This Month").tag("This Month")
                }
                .frame(width: 120)
            }
            
            List {
                ForEach(Array(trending.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 16) {
                        Text("#\(index + 1)").font(.title2.bold()).foregroundStyle(.secondary).frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.0).font(.subheadline.bold())
                            HStack {
                                Text("\(item.1) views").font(.caption)
                                Text(item.2).font(.caption).foregroundStyle(.green)
                            }
                        }
                        
                        Spacer()
                        
                        Text(item.3.capitalized).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(item.3 == "hot" ? Color.red.opacity(0.2) : Color.yellow.opacity(0.2)))
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct SimilarItemsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Find Similar Items").font(.headline)
            
            HStack {
                TextField("Enter item name or ID...", text: .constant("")).textFieldStyle(.roundedBorder)
                Button("Search") {}.buttonStyle(.borderedProminent).tint(.yellow)
            }
            
            Divider()
            
            Text("Similar to: SwiftUI Fundamentals").font(.subheadline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 16) {
                ForEach(0..<6, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 8).fill(Color.yellow.opacity(0.2)).frame(height: 100)
                            .overlay(Image(systemName: "doc.fill").font(.largeTitle).foregroundStyle(.yellow.opacity(0.5)))
                        Text("Similar Item \(i + 1)").font(.caption.bold())
                        HStack {
                            Text("\(90 - i * 5)% similar").font(.caption2).foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "arrow.right.circle").foregroundStyle(.yellow)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct RecommendationSettingsView: View {
    @State private var personalizedEnabled = true
    @State private var historyEnabled = true
    @State private var networkEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommendation Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Personalized recommendations", isOn: $personalizedEnabled)
                Toggle("Use viewing history", isOn: $historyEnabled)
                Toggle("Include network activity", isOn: $networkEnabled)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interests").font(.subheadline)
                    Text("Select topics you're interested in").font(.caption).foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(["SwiftUI", "iOS", "Design", "Backend", "DevOps", "AI/ML", "Security", "Testing"], id: \.self) { topic in
                            Toggle(topic, isOn: .constant(["SwiftUI", "iOS", "Design"].contains(topic)))
                                .toggleStyle(.button)
                                .font(.caption)
                        }
                    }
                }
                
                Divider()
                
                Button("Clear Recommendation History") {}.buttonStyle(.bordered).tint(.red)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

#Preview { RecommendationSystemView().frame(width: 900, height: 700) }
