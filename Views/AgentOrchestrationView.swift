//
//  AgentOrchestrationView.swift
//  HIG
//
//  Visual interface for AI Agent Orchestration System
//  Shows all workers, tasks, and architect activity
//

import SwiftUI
import UniformTypeIdentifiers
import Combine
import UserNotifications
import SwiftData

// MARK: - Scheduling Types (local to view)
fileprivate enum RepeatRule: String, CaseIterable, Codable {
    case none = "None"
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
}

fileprivate enum EventTrigger: String, CaseIterable, Codable {
    case none = "None"
    case onAppLaunch = "On App Launch"
    case onIndexingComplete = "On Indexing Complete"
    case onNetworkAvailable = "On Network Available"
}

final class SelectedProjectStore: ObservableObject {
    static let shared = SelectedProjectStore()
    @Published var selectedProjectID: UUID? = nil
    private init() {}
}

struct AgentOrchestrationView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var orchestrator = AIAgentOrchestrator.shared
    @State private var selectedWorker: AgentRole?
    @State private var showWorkflowPicker = false
    
    @State private var dragPreviewTask: AgentTask? = nil
    @State private var scheduledAt: Date? = nil
    @State private var repeatRule: RepeatRule = .none
    @State private var eventTrigger: EventTrigger = .none
    @State private var showScheduleEditor: Bool = false
    @State private var pendingDropTaskTemplate: (role: AgentRole, title: String, description: String, priority: AgentTask.Priority)? = nil

    @State private var showToast: Bool = false
    @StateObject private var taskBus = TaskEventBus.shared
    
    @State private var selectedProjectID: UUID? = nil
    @State private var availableProjects: [ProjectEntity] = []
    
    @State private var showProjectTasks = false
    
    @StateObject private var selectedProjectStore = SelectedProjectStore.shared

    var body: some View {
        NavigationSplitView {
            // Workers sidebar
            workersSidebar
        } content: {
            // Task queue and active tasks
            tasksView
        } detail: {
            // Worker detail or architect view
            detailView
        }
        .navigationTitle("AI Agent Orchestration")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    showWorkflowPicker = true
                } label: {
                    Label("Start Workflow", systemImage: "play.circle")
                }
                .disabled(orchestrator.isOrchestrating)
                
                if orchestrator.isOrchestrating {
                    Button {
                        orchestrator.stopOrchestration()
                    } label: {
                        Label("Stop", systemImage: "stop.circle")
                    }
                }
                
                Menu {
                    Picker("Project", selection: Binding(get: { selectedProjectStore.selectedProjectID ?? availableProjects.first?.id }, set: { selectedProjectStore.selectedProjectID = $0 })) {
                        ForEach(availableProjects, id: \.id) { p in
                            Text(p.title).tag(Optional.some(p.id))
                        }
                    }
                    Button("New Project") {
                        let project = TasksPersistenceBridge.shared.upsertProject(id: UUID(), title: "New Project", summary: "", in: modelContext)
                        refreshProjects()
                        selectedProjectStore.selectedProjectID = project.id
                    }
                    Button("Open Project Tasks") {
                        showProjectTasks = true
                    }
                    .disabled(selectedProjectStore.selectedProjectID == nil)
                } label: {
                    Label("Project", systemImage: "folder")
                }
            }
        }
        .sheet(isPresented: $showWorkflowPicker) {
            workflowPicker
        }
        .sheet(isPresented: $showScheduleEditor) {
            scheduleEditor
        }
        .sheet(isPresented: $showProjectTasks) {
            if let pid = selectedProjectStore.selectedProjectID {
                NavigationStack {
                    ProjectTasksView(projectID: pid)
                }
            }
        }
        .environmentObject(selectedProjectStore)
        .onAppear {
            _ = TaskEventNotificationBridge.shared
            TasksPersistenceBridge.shared.configure(context: modelContext)
            refreshProjects()
        }
        .overlay(alignment: .topLeading) { ChatOverlay() }
    }
    
    private func refreshProjects() {
        let descriptor = FetchDescriptor<ProjectEntity>()
        if let results = try? modelContext.fetch(descriptor) {
            availableProjects = results
        }
    }
    
    // MARK: - Workers Sidebar
    
    private var workersSidebar: some View {
        List(selection: $selectedWorker) {
            Section("Predefined Tasks") {
                let templates: [(AgentRole, String, String, AgentTask.Priority)] = [
                    (.dataFetcher, "Fetch Developer Resources", "Fetch latest Swift docs, WWDC sessions, and code examples", .high),
                    (.dataValidator, "Validate Fetched Data", "Ensure data integrity and completeness", .high),
                    (.categoryAssigner, "Organize into Categories", "Categorize content into code examples, patterns, errors, APIs", .medium),
                    (.topicAssigner, "Assign Topics", "Tag content with relevant topics", .medium),
                    (.contentCreator, "Generate Knowledge Base Content", "Create structured JSON files with examples and references", .high)
                ]
                ForEach(Array(templates.enumerated()), id: \.offset) { _, item in
                    let (role, title, desc, priority) = item
                    HStack {
                        Image(systemName: role.icon)
                            .foregroundStyle(role.color)
                        VStack(alignment: .leading) {
                            Text(title).font(.caption.weight(.medium))
                            Text(role.rawValue).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onDrag {
                        pendingDropTaskTemplate = (role, title, desc, priority)
                        return NSItemProvider(object: NSString(string: title))
                    }
                }
            }
            
            Section("Automation Journalism & Press") {
                let pressTemplates: [(AgentRole, String, String, AgentTask.Priority)] = [
                    (.summaryWriter, "Security & Ethics Brief", "Summarize potential security, ethical, and general risks for upcoming features", .high),
                    (.contentCreator, "Risk Register Update", "Generate or update a risk register with mitigations and owners", .high),
                    (.updateWriter, "Release Notes Draft", "Draft release notes focusing on changes, known issues, and mitigations", .medium),
                    (.readmeWriter, "Press Kit Overview", "Prepare a press kit outline including key messages, FAQs, and assets list", .medium),
                    (.dataValidator, "Compliance Checklist", "Validate features against compliance and policy checklists", .high)
                ]
                ForEach(Array(pressTemplates.enumerated()), id: \.offset) { _, item in
                    let (role, title, desc, priority) = item
                    HStack {
                        Image(systemName: role.icon)
                            .foregroundStyle(role.color)
                        VStack(alignment: .leading) {
                            Text(title).font(.caption.weight(.medium))
                            Text(role.rawValue).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onDrag {
                        pendingDropTaskTemplate = (role, title, desc, priority)
                        return NSItemProvider(object: NSString(string: title))
                    }
                }
            }
            
            Section("Architect") {
                NavigationLink(value: AgentRole.architect) {
                    WorkerRow(
                        role: .architect,
                        worker: orchestrator.workers[.architect]!,
                        status: orchestrator.architectStatus
                    )
                }
            }
            
            Section("Content Management") {
                ForEach([AgentRole.topicAssigner, .categoryAssigner, .contentCreator, .dataValidator, .dataFetcher], id: \.self) { role in
                    NavigationLink(value: role) {
                        WorkerRow(role: role, worker: orchestrator.workers[role]!)
                    }
                }
            }
            
            Section("Storage") {
                ForEach([AgentRole.localStorageManager, .digitalStorageManager, .virtualStorageManager], id: \.self) { role in
                    NavigationLink(value: role) {
                        WorkerRow(role: role, worker: orchestrator.workers[role]!)
                    }
                }
            }
            
            Section("Development") {
                ForEach([AgentRole.blueprintDeveloper, .guideCreator, .codeValidator, .errorReporter, .errorCorrector, .packageDesigner, .applicationDeveloper], id: \.self) { role in
                    NavigationLink(value: role) {
                        WorkerRow(role: role, worker: orchestrator.workers[role]!)
                    }
                }
            }
            
            Section("Documentation") {
                ForEach([AgentRole.summaryWriter, .readmeWriter, .updateWriter], id: \.self) { role in
                    NavigationLink(value: role) {
                        WorkerRow(role: role, worker: orchestrator.workers[role]!)
                    }
                }
            }
            
            Section("Design") {
                ForEach([AgentRole.iconMapper, .iconDesigner, .animator, .windowPatternResearcher, .workspaceDesigner], id: \.self) { role in
                    NavigationLink(value: role) {
                        WorkerRow(role: role, worker: orchestrator.workers[role]!)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    // MARK: - Tasks View
    
    private var tasksView: some View {
        List {
            Color.clear
                .frame(height: 0)
                .onDrop(of: [UTType.text.identifier], isTargeted: nil) { providers in
                    if let tpl = pendingDropTaskTemplate {
                        // Open schedule editor on drop
                        showScheduleEditor = true
                        return true
                    }
                    return false
                }
            
            if !orchestrator.activeTasks.isEmpty {
                Section("Active Tasks (\(orchestrator.activeTasks.count))") {
                    ForEach(orchestrator.activeTasks) { task in
                        TaskRow(task: task, isActive: true, availableProjects: availableProjects, selectedProjectID: $selectedProjectID)
                    }
                }
            }
            
            if !orchestrator.taskQueue.isEmpty {
                Section("Pending Tasks (\(orchestrator.taskQueue.count))") {
                    ForEach(orchestrator.taskQueue) { task in
                        TaskRow(task: task, isActive: false, availableProjects: availableProjects, selectedProjectID: $selectedProjectID)
                    }
                }
            }
            
            if !orchestrator.completedTasks.isEmpty {
                Section("Completed Tasks (\(orchestrator.completedTasks.count))") {
                    ForEach(orchestrator.completedTasks.suffix(20).reversed()) { task in
                        TaskRow(task: task, isActive: false, availableProjects: availableProjects, selectedProjectID: $selectedProjectID)
                    }
                }
            }
            
            Section("Kanban") {
                TasksColumnView(columns: kanbanColumns)
                    .listRowInsets(EdgeInsets())
            }
            
            if orchestrator.taskQueue.isEmpty && orchestrator.activeTasks.isEmpty && orchestrator.completedTasks.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("No Tasks", systemImage: "tray")
                    },
                    description: {
                        Text("Start a workflow to see tasks")
                    },
                    actions: {
                        Button("Start Workflow") {
                            showWorkflowPicker = true
                        }
                    }
                )
            }
        }
        .navigationTitle("Tasks")
        .overlay(alignment: .top) {
            if showToast, let event = taskBus.lastEvent {
                ToastView(event: event)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding()
            }
        }
        .onReceive(taskBus.$lastEvent.compactMap { $0 }) { _ in
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showToast = false }
            }
        }
    }
    
    private var kanbanColumns: [TaskColumn] {
        let all = orchestrator.activeTasks + orchestrator.taskQueue + orchestrator.completedTasks
        func map(_ status: AgentTask.Status) -> [TaskItem] {
            all.filter { $0.status == status }.map { TaskItem(from: $0) }
        }
        return [
            TaskColumn(title: "Pending", status: .pending, tasks: map(.pending)),
            TaskColumn(title: "Assigned", status: .assigned, tasks: map(.assigned)),
            TaskColumn(title: "In Progress", status: .inProgress, tasks: map(.inProgress)),
            TaskColumn(title: "Completed", status: .completed, tasks: map(.completed)),
            TaskColumn(title: "Blocked", status: .blocked, tasks: map(.blocked))
        ]
    }
    
    // MARK: - Detail View
    
    @ViewBuilder
    private var detailView: some View {
        if let role = selectedWorker {
            if role == .architect {
                architectDetailView
            } else if let worker = orchestrator.workers[role] {
                workerDetailView(worker: worker)
            }
        } else {
            overviewView
        }
    }
    
    private var architectDetailView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Architect status
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "building.columns")
                            .font(.system(size: 40))
                            .foregroundStyle(.yellow)
                    }
                    
                    Text("Architect")
                        .font(.title.bold())
                    
                    Text(orchestrator.architectStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if orchestrator.isOrchestrating {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                
                // Statistics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(orchestrator.getStatistics().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(spacing: 8) {
                            Text("\(value)")
                                .font(.title.bold().monospacedDigit())
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }
    
    private func workerDetailView(worker: AgentWorker) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Worker header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(worker.role.color.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: worker.role.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(worker.role.color)
                    }
                    
                    Text(worker.role.rawValue)
                        .font(.title.bold())
                    
                    HStack(spacing: 16) {
                        Label(worker.isActive ? "Active" : "Idle", systemImage: worker.isActive ? "circle.fill" : "circle")
                            .foregroundStyle(worker.isActive ? .green : .secondary)
                        
                        if let lastActivity = worker.lastActivity {
                            Text("Last: \(lastActivity, style: .relative)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Current task
                if let task = worker.currentTask {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Task")
                            .font(.headline)
                        
                        TaskCard(task: task)
                    }
                }
                
                // Completed tasks
                if !worker.completedTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completed Tasks (\(worker.completedTasks.count))")
                            .font(.headline)
                        
                        ForEach(worker.completedTasks.suffix(10).reversed()) { task in
                            TaskCard(task: task)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var overviewView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "cpu.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.purple)
                
                Text("Dashboard")
                    .font(.title.bold())
                
                Text("Quick access to Documentation, Workflows, and Developer Docs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // Quick stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    OrchestrationStatCard(icon: "person.3", value: "\(AgentRole.allCases.count)", label: "Workers")
                    OrchestrationStatCard(icon: "list.bullet", value: "\(orchestrator.taskQueue.count)", label: "Pending")
                    OrchestrationStatCard(icon: "checkmark.circle", value: "\(orchestrator.completedTasks.count)", label: "Completed")
                }
                
                // Dashboard quick access
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    DashboardCard(icon: "doc.richtext", title: "Documentation Hub", subtitle: "Open HIG Documentation Center") {
                        // Hook up to your Documentation Hub navigation if available
                        showWorkflowPicker = false
                        selectedWorker = nil
                    }
                    DashboardCard(icon: "gearshape.2", title: "Workflows", subtitle: "Start and monitor workflows") {
                        showWorkflowPicker = true
                    }
                    DashboardCard(icon: "book", title: "Developer Docs", subtitle: "Plan, store, and view dev docs") {
                        // Placeholder action; wire to your Developer Docs module
                        selectedWorker = .guideCreator
                    }
                }

                // Pipeline visualization
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pipeline")
                        .font(.headline)

                    // Stages list
                    VStack(spacing: 12) {
                        PipelineStageRow(
                            title: "Intake & Planning",
                            icon: "building.columns",
                            roles: [.architect],
                            responsibility: "Define scope, break into tasks, prioritize"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Fetch / Discovery",
                            icon: "tray.and.arrow.down",
                            roles: [.dataFetcher],
                            responsibility: "Collect inputs: docs, repos, APIs"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Validation / Compliance",
                            icon: "checkmark.shield",
                            roles: [.dataValidator],
                            responsibility: "Validate completeness, integrity, licensing"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Organization",
                            icon: "square.grid.2x2",
                            roles: [.categoryAssigner, .topicAssigner],
                            responsibility: "Categorize and tag items for retrieval"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Content Creation",
                            icon: "doc.append",
                            roles: [.contentCreator],
                            responsibility: "Produce structured JSON/Markdown outputs"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Documentation / Writing",
                            icon: "doc.text",
                            roles: [.summaryWriter, .readmeWriter, .updateWriter],
                            responsibility: "Summaries, READMEs, release notes"
                        )
                        PipelineConnector()
                        PipelineStageRow(
                            title: "Storage / Publication",
                            icon: "externaldrive",
                            roles: [.localStorageManager, .digitalStorageManager, .virtualStorageManager],
                            responsibility: "Persist, version, and publish artifacts"
                        )
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                    // Rules card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rules")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 6) {
                            RuleRow(text: "Single owner per stage; explicit handoffs")
                            RuleRow(text: "Definition of Done for each stage")
                            RuleRow(text: "Small batches; fast feedback")
                            RuleRow(text: "Risk-first gating: brief + register early")
                            RuleRow(text: "Blockers create unblock tasks; escalate to Architect")
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(40)
        }
    }
    
    // MARK: - Workflow Picker
    
    private var workflowPicker: some View {
        NavigationStack {
            List {
                Button {
                    orchestrator.startKnowledgeBaseWorkflow()
                    showWorkflowPicker = false
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Knowledge Base Workflow", systemImage: "brain")
                            .font(.headline)
                        Text("Fetch, validate, and organize developer resources")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button {
                    orchestrator.startUIDesignWorkflow()
                    showWorkflowPicker = false
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("UI Design Workflow", systemImage: "macwindow")
                            .font(.headline)
                        Text("Research, design, and implement workspace UI")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Start Workflow")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showWorkflowPicker = false
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    // MARK: - Schedule Editor
    private var scheduleEditor: some View {
        NavigationStack {
            Form {
                Section("When") {
                    Toggle("Schedule for later", isOn: Binding(get: { scheduledAt != nil }, set: { newValue in
                        scheduledAt = newValue ? Date().addingTimeInterval(3600) : nil
                    }))
                    if let bound = Binding($scheduledAt) {
                        DatePicker("Scheduled Time", selection: bound ?? .constant(Date()), displayedComponents: [.date, .hourAndMinute])
                            .disabled(scheduledAt == nil)
                    }
                }
                Section("Repeat") {
                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases, id: \.self) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                }
                Section("Event Trigger") {
                    Picker("Trigger", selection: $eventTrigger) {
                        ForEach(EventTrigger.allCases, id: \.self) { trig in
                            Text(trig.rawValue).tag(trig)
                        }
                    }
                }
            }
            .navigationTitle("Schedule Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showScheduleEditor = false; pendingDropTaskTemplate = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Queue") {
                        if let tpl = pendingDropTaskTemplate {
                            let task = orchestrator.createTask(
                                role: tpl.role,
                                title: tpl.title,
                                description: tpl.description,
                                priority: tpl.priority
                            )
                            // Store schedule metadata into result string for now (lightweight, no model change)
                            var meta: [String] = []
                            if let when = scheduledAt { meta.append("scheduled:\(when.ISO8601Format())") }
                            if repeatRule != .none { meta.append("repeat:\(repeatRule.rawValue)") }
                            if eventTrigger != .none { meta.append("event:\(eventTrigger.rawValue)") }
                            if !meta.isEmpty {
                                var updated = task
                                updated.result = "[schedule] " + meta.joined(separator: ", ")
                                // Note: Avoid mutating orchestrator.taskQueue here; rely on orchestrator to manage its queue internally.
                            }
                        }
                        // Reset
                        scheduledAt = nil
                        repeatRule = .none
                        eventTrigger = .none
                        pendingDropTaskTemplate = nil
                        showScheduleEditor = false
                    }
                }
            }
        }
    }
}

// MARK: - Component Views

struct WorkerRow: View {
    let role: AgentRole
    let worker: AgentWorker
    var status: String?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: role.icon)
                .foregroundStyle(role.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(role.rawValue)
                    .font(.subheadline.weight(.medium))
                
                if let status = status {
                    Text(status)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else if worker.isActive {
                    Text("Working...")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Text("Idle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if worker.isActive {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }
}

struct TaskRow: View {
    let task: AgentTask
    let isActive: Bool
    let availableProjects: [ProjectEntity]
    @Binding var selectedProjectID: UUID?

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var selectedProjectStore: SelectedProjectStore
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.role.icon)
                .foregroundStyle(task.role.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                
                Text(task.role.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            statusBadge
        }
        .contextMenu {
            if let pid = selectedProjectStore.selectedProjectID,
               let project = try? modelContext.fetch(FetchDescriptor<ProjectEntity>(predicate: #Predicate { $0.id == pid })).first {
                Button("Move to \(project.title)") {
                    let item = TaskItem(from: task)
                    TasksPersistenceBridge.shared.configure(context: modelContext)
                    if let entity = try? modelContext.fetch(FetchDescriptor<TaskEntity>(predicate: #Predicate { $0.id == item.id })).first {
                        entity.project = project
                        try? modelContext.save()
                        TaskEventBus.shared.publish(.updated(TaskItem(from: task)))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Text(task.status.rawValue)
                .font(.caption2.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2), in: Capsule())
                .foregroundStyle(statusColor)

            if let cl = TasksPersistenceBridge.shared.loadChecklist(taskID: task.id, in: modelContext) {
                let pct = Int(cl.progress * 100)
                Text("\(pct)%")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2), in: Capsule())
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .gray
        case .assigned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .failed: return .red
        case .blocked: return .yellow
        }
    }
}

struct TaskCard: View {
    let task: AgentTask
    
    @Environment(\.modelContext) private var _modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                
                Text(task.priority.rawValue)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2), in: Capsule())
                    .foregroundStyle(priorityColor)
            }
            
            Text(task.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let result = task.result {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Result:")
                        .font(.caption.weight(.medium))
                    Text(result)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            
            if let error = task.error {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error:")
                        .font(.caption.weight(.medium))
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            
            // Persisted checklist (if available)
            if let loaded = TasksPersistenceBridge.shared.loadChecklist(taskID: task.id, in: _modelContext) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Checklist").font(.caption.weight(.medium))
                    ChecklistView(taskID: task.id, checklist: loaded)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
}

struct OrchestrationStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title.bold().monospacedDigit())
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct DashboardCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct PipelineStageRow: View {
    let title: String
    let icon: String
    let roles: [AgentRole]
    let responsibility: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                // Roles chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(roles, id: \.self) { role in
                            HStack(spacing: 6) {
                                Image(systemName: role.icon)
                                Text(role.rawValue)
                            }
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(role.color.opacity(0.15), in: Capsule())
                            .foregroundStyle(role.color)
                        }
                    }
                }
                // Responsibility line
                Text(responsibility)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}

struct PipelineConnector: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 2)
    }
}

struct RuleRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ToastView: View {
    let event: TaskEvent
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell")
            Text(title)
                .font(.caption.weight(.medium))
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var title: String {
        switch event {
        case .created(let t): return "Created: \(t.title)"
        case .updated(let t): return "Updated: \(t.title)"
        case .statusChanged(_, _, let to): return "Status: \(to.rawValue.capitalized)"
        case .checklistUpdated(_, let p): return "Checklist: \(Int(p * 100))%"
        case .deleted: return "Deleted"
        }
    }
}

// MARK: - Preview

#Preview {
    AgentOrchestrationView()
        .frame(width: 1200, height: 800)
}

