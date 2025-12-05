//
//  WorkflowAutomationSystem.swift
//  HIG
//
//  Workflow / Automation System - IFTTT logic engine
//

import SwiftUI

struct WorkflowAutomationSystemView: View {
    @State private var selectedTab = "Workflows"
    @State private var workflows: [Workflow] = Workflow.samples
    
    let tabs = ["Workflows", "Builder", "Triggers", "History"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "gearshape.2.fill").font(.title2).foregroundStyle(.orange)
                Text("Workflow Automation").font(.title2.bold())
                Spacer()
                Text("\(workflows.filter { $0.isActive }.count) active").font(.caption).foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.orange.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Workflows": WorkflowsListView(workflows: $workflows)
                case "Builder": WorkflowBuilderView()
                case "Triggers": TriggersView()
                case "History": WorkflowHistoryView()
                default: EmptyView()
                }
            }
        }
    }
}

struct WorkflowsListView: View {
    @Binding var workflows: [Workflow]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search workflows...", text: .constant("")).textFieldStyle(.roundedBorder).frame(width: 250)
                Spacer()
                Button("Create Workflow") {}.buttonStyle(.borderedProminent).tint(.orange)
            }
            .padding()
            
            List {
                ForEach(workflows) { workflow in
                    WorkflowRow(workflow: workflow)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct WorkflowRow: View {
    let workflow: Workflow
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(workflow.color.opacity(0.2)).frame(width: 44, height: 44)
                Image(systemName: workflow.icon).foregroundStyle(workflow.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name).font(.subheadline.bold())
                Text(workflow.description).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label(workflow.trigger, systemImage: "bolt.fill").font(.caption2)
                    Text("→").foregroundStyle(.secondary)
                    Label("\(workflow.actions.count) actions", systemImage: "arrow.right.circle").font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Toggle("", isOn: .constant(workflow.isActive)).labelsHidden()
                Text("Ran \(workflow.lastRun)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct WorkflowBuilderView: View {
    @State private var selectedTrigger = "When form submitted"
    @State private var actions: [String] = ["Send email notification"]
    
    let triggers = ["When form submitted", "When file uploaded", "When user signs up", "On schedule", "When status changes"]
    let availableActions = ["Send email", "Create task", "Update record", "Send Slack message", "Call webhook", "Add to list"]
    
    var body: some View {
        HSplitView {
            // Builder Canvas
            VStack(spacing: 20) {
                Text("Workflow Builder").font(.headline)
                
                // Trigger
                VStack(spacing: 8) {
                    Text("TRIGGER").font(.caption.bold()).foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "bolt.fill").foregroundStyle(.orange)
                        Picker("", selection: $selectedTrigger) {
                            ForEach(triggers, id: \.self) { Text($0).tag($0) }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange, lineWidth: 2))
                }
                
                Image(systemName: "arrow.down").foregroundStyle(.secondary)
                
                // Actions
                VStack(spacing: 8) {
                    Text("ACTIONS").font(.caption.bold()).foregroundStyle(.secondary)
                    
                    ForEach(actions.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "arrow.right.circle.fill").foregroundStyle(.blue)
                            Text(actions[index])
                            Spacer()
                            Button { actions.remove(at: index) } label: { Image(systemName: "xmark.circle") }.buttonStyle(.plain)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                        
                        if index < actions.count - 1 {
                            Image(systemName: "arrow.down").foregroundStyle(.secondary)
                        }
                    }
                    
                    Button { actions.append("New action") } label: {
                        Label("Add Action", systemImage: "plus.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                HStack {
                    Button("Test Workflow") {}.buttonStyle(.bordered)
                    Button("Save & Activate") {}.buttonStyle(.borderedProminent).tint(.orange)
                }
            }
            .padding()
            
            // Actions Library
            VStack(alignment: .leading, spacing: 16) {
                Text("Actions Library").font(.headline)
                
                ForEach(availableActions, id: \.self) { action in
                    Button {
                        actions.append(action)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle").foregroundStyle(.orange)
                            Text(action)
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 250)
            .background(.regularMaterial)
        }
    }
}

struct TriggersView: View {
    let triggerCategories = [
        ("Events", ["Form submitted", "File uploaded", "User action", "Status change"]),
        ("Schedule", ["Daily", "Weekly", "Monthly", "Custom cron"]),
        ("Integrations", ["Webhook received", "Email received", "Slack message"]),
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(triggerCategories, id: \.0) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.0).font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                            ForEach(category.1, id: \.self) { trigger in
                                HStack {
                                    Image(systemName: "bolt.fill").foregroundStyle(.orange)
                                    Text(trigger).font(.subheadline)
                                    Spacer()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct WorkflowHistoryView: View {
    let history = [
        ("Welcome Email", "Success", "2 min ago", "12ms"),
        ("Slack Notification", "Success", "15 min ago", "45ms"),
        ("Create Task", "Failed", "1 hour ago", "timeout"),
        ("Update CRM", "Success", "2 hours ago", "89ms"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Execution History").font(.headline)
                Spacer()
                Button("Export") {}.buttonStyle(.bordered)
            }
            
            List {
                ForEach(history, id: \.0) { item in
                    HStack {
                        Image(systemName: item.1 == "Success" ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(item.1 == "Success" ? .green : .red)
                        VStack(alignment: .leading) {
                            Text(item.0).font(.subheadline)
                            Text(item.2).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.3).font(.caption).foregroundStyle(.secondary)
                        Text(item.1).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(item.1 == "Success" ? Color.green.opacity(0.2) : Color.red.opacity(0.2)))
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct Workflow: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let trigger: String
    let actions: [String]
    let isActive: Bool
    let lastRun: String
    let icon: String
    let color: Color
    
    static var samples: [Workflow] {
        [
            Workflow(name: "Welcome Email", description: "Send welcome email to new users", trigger: "User signs up", actions: ["Send email", "Add to list"], isActive: true, lastRun: "2 min ago", icon: "envelope.fill", color: .blue),
            Workflow(name: "Task Assignment", description: "Auto-assign tasks based on category", trigger: "Task created", actions: ["Check category", "Assign user", "Send notification"], isActive: true, lastRun: "15 min ago", icon: "person.badge.plus", color: .green),
            Workflow(name: "Daily Report", description: "Generate and send daily summary", trigger: "Daily at 9 AM", actions: ["Generate report", "Send email"], isActive: true, lastRun: "8 hours ago", icon: "chart.bar.fill", color: .purple),
            Workflow(name: "Slack Alerts", description: "Send alerts to Slack channel", trigger: "Error detected", actions: ["Format message", "Post to Slack"], isActive: false, lastRun: "2 days ago", icon: "bubble.left.fill", color: .orange),
        ]
    }
}

#Preview { WorkflowAutomationSystemView().frame(width: 1000, height: 700) }
