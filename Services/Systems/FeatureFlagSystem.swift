//
//  FeatureFlagSystem.swift
//  HIG
//
//  Feature Flag System - Toggle features, A/B testing, staged rollouts
//

import SwiftUI

struct FeatureFlagSystemView: View {
    @State private var selectedTab = "Flags"
    @State private var flags: [FeatureFlag] = FeatureFlag.samples
    
    let tabs = ["Flags", "Experiments", "Segments", "Audit"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "flag.fill").font(.title2).foregroundStyle(.indigo)
                Text("Feature Flags").font(.title2.bold())
                Spacer()
                Text("\(flags.filter { $0.isEnabled }.count)/\(flags.count) enabled").font(.caption).foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.indigo.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Flags": FlagsListView(flags: $flags)
                case "Experiments": ExperimentsView()
                case "Segments": SegmentsView()
                case "Audit": FlagAuditView()
                default: EmptyView()
                }
            }
        }
    }
}

struct FlagsListView: View {
    @Binding var flags: [FeatureFlag]
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search flags...", text: $searchText).textFieldStyle(.roundedBorder).frame(width: 250)
                Spacer()
                Button("Create Flag") {}.buttonStyle(.borderedProminent).tint(.indigo)
            }
            .padding()
            
            List {
                ForEach($flags) { $flag in
                    FlagRow(flag: $flag)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct FlagRow: View {
    @Binding var flag: FeatureFlag
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(flag.name).font(.subheadline.bold())
                        Text(flag.key).font(.caption).foregroundStyle(.secondary).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color(.controlBackgroundColor)))
                    }
                    Text(flag.description).font(.caption).foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if flag.rolloutPercentage < 100 {
                    VStack(alignment: .trailing) {
                        Text("\(flag.rolloutPercentage)%").font(.caption.bold())
                        Text("rollout").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                
                Toggle("", isOn: $flag.isEnabled).labelsHidden()
                
                Button { showDetails.toggle() } label: {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)
            }
            
            if showDetails {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    HStack {
                        Text("Rollout").font(.caption)
                        Slider(value: Binding(get: { Double(flag.rolloutPercentage) }, set: { flag.rolloutPercentage = Int($0) }), in: 0...100, step: 5)
                        Text("\(flag.rolloutPercentage)%").font(.caption).frame(width: 40)
                    }
                    
                    HStack {
                        Text("Environment").font(.caption)
                        Picker("", selection: .constant(flag.environment)) {
                            Text("All").tag("All")
                            Text("Production").tag("Production")
                            Text("Staging").tag("Staging")
                            Text("Development").tag("Development")
                        }
                        .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Created: \(flag.createdDate)").font(.caption2).foregroundStyle(.secondary)
                        Spacer()
                        Button("Edit") {}.buttonStyle(.bordered).controlSize(.small)
                        Button("Delete") {}.buttonStyle(.bordered).controlSize(.small).tint(.red)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ExperimentsView: View {
    let experiments = [
        ("New Checkout Flow", "A/B", 50, "Running", "+12% conversion"),
        ("Pricing Page V2", "A/B/C", 33, "Running", "+5% signups"),
        ("Onboarding Redesign", "A/B", 50, "Completed", "+18% activation"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("A/B Experiments").font(.headline)
                Spacer()
                Button("Create Experiment") {}.buttonStyle(.borderedProminent).tint(.indigo)
            }
            
            List {
                ForEach(experiments, id: \.0) { exp in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(exp.0).font(.subheadline.bold())
                            Text(exp.1).font(.caption).padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(Color.indigo.opacity(0.2)))
                            Spacer()
                            Text(exp.3).font(.caption).foregroundStyle(exp.3 == "Running" ? .green : .secondary)
                        }
                        
                        HStack {
                            Text("Traffic: \(exp.2)%").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text(exp.4).font(.caption).foregroundStyle(.green)
                        }
                        
                        // Variants
                        HStack(spacing: 8) {
                            ExperimentVariant(name: "Control", percentage: 50, color: .blue)
                            ExperimentVariant(name: "Variant A", percentage: 50, color: .green)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct ExperimentVariant: View {
    let name: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 8)
            Text(name).font(.caption2)
            Text("\(percentage)%").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.1)))
    }
}

struct SegmentsView: View {
    let segments = [
        ("Beta Users", "Users who opted into beta", 1250),
        ("Premium", "Paid subscription users", 5600),
        ("New Users", "Signed up in last 30 days", 890),
        ("Power Users", "High engagement score", 2100),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("User Segments").font(.headline)
                Spacer()
                Button("Create Segment") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(segments, id: \.0) { segment in
                    HStack {
                        Image(systemName: "person.2.fill").foregroundStyle(.indigo)
                        VStack(alignment: .leading) {
                            Text(segment.0).font(.subheadline)
                            Text(segment.1).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(segment.2) users").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct FlagAuditView: View {
    let logs = [
        ("new_dashboard", "Enabled", "john@example.com", "2 min ago"),
        ("dark_mode", "Rollout 50% → 100%", "admin@example.com", "1 hour ago"),
        ("beta_features", "Disabled", "jane@example.com", "3 hours ago"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audit Log").font(.headline)
            
            List {
                ForEach(logs, id: \.0) { log in
                    HStack {
                        Image(systemName: "flag.fill").foregroundStyle(.indigo)
                        VStack(alignment: .leading) {
                            Text(log.0).font(.subheadline)
                            Text(log.1).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(log.2).font(.caption2)
                            Text(log.3).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct FeatureFlag: Identifiable {
    let id = UUID()
    var name: String
    var key: String
    var description: String
    var isEnabled: Bool
    var rolloutPercentage: Int
    var environment: String
    var createdDate: String
    
    static var samples: [FeatureFlag] {
        [
            FeatureFlag(name: "New Dashboard", key: "new_dashboard", description: "Redesigned dashboard with analytics", isEnabled: true, rolloutPercentage: 100, environment: "All", createdDate: "Nov 1, 2024"),
            FeatureFlag(name: "Dark Mode", key: "dark_mode", description: "Enable dark mode theme", isEnabled: true, rolloutPercentage: 50, environment: "Production", createdDate: "Oct 15, 2024"),
            FeatureFlag(name: "AI Assistant", key: "ai_assistant", description: "AI-powered help assistant", isEnabled: true, rolloutPercentage: 25, environment: "Staging", createdDate: "Nov 20, 2024"),
            FeatureFlag(name: "Beta Features", key: "beta_features", description: "Access to beta features", isEnabled: false, rolloutPercentage: 0, environment: "Development", createdDate: "Sep 1, 2024"),
        ]
    }
}

#Preview { FeatureFlagSystemView().frame(width: 900, height: 700) }
