//
//  CreativeWorkstations.swift
//  HIG
//
//  Creative professional workstations:
//  - Animator, Author, Artist, Designer, Graphic Designer
//

import SwiftUI

// MARK: - Creative Workstation Types

enum CreativeWorkstationType: String, CaseIterable, Identifiable {
    case animator = "Animator"
    case author = "Author"
    case artist = "Artist"
    case designer = "Designer"
    case graphicDesigner = "Graphic Designer"
    case enterpriseDev = "Enterprise Developer"
    case saasDev = "SaaS Developer"
    case businessDev = "Business Developer"
    case gameDev = "Game Developer"
    case virtualCasino = "Virtual Casino"
    case mascotCreator = "Mascot Creator"
    case appBuilder = "App Builder"
    case iconCreator = "Icon Creator"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .animator: return "film.stack"
        case .author: return "text.book.closed.fill"
        case .artist: return "paintpalette.fill"
        case .designer: return "ruler.fill"
        case .graphicDesigner: return "paintbrush.pointed.fill"
        case .enterpriseDev: return "building.2.fill"
        case .saasDev: return "cloud.fill"
        case .businessDev: return "briefcase.fill"
        case .gameDev: return "gamecontroller.fill"
        case .virtualCasino: return "suit.spade.fill"
        case .mascotCreator: return "face.smiling.fill"
        case .appBuilder: return "hammer.fill"
        case .iconCreator: return "app.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .animator: return .purple
        case .author: return .brown
        case .artist: return .pink
        case .designer: return .blue
        case .graphicDesigner: return .orange
        case .enterpriseDev: return .indigo
        case .saasDev: return .cyan
        case .businessDev: return .green
        case .gameDev: return .red
        case .virtualCasino: return .yellow
        case .mascotCreator: return .mint
        case .appBuilder: return .teal
        case .iconCreator: return Color(red: 0.6, green: 0.4, blue: 0.8)
        }
    }
    
    var description: String {
        switch self {
        case .animator: return "Animation timeline, keyframes & motion"
        case .author: return "Writing, chapters & manuscript tools"
        case .artist: return "Digital canvas, brushes & layers"
        case .designer: return "UI/UX design, prototyping & specs"
        case .graphicDesigner: return "Visual design, typography & branding"
        case .enterpriseDev: return "Large-scale systems, microservices & compliance"
        case .saasDev: return "Cloud platforms, subscriptions & multi-tenancy"
        case .businessDev: return "ERP, CRM & business process automation"
        case .gameDev: return "Game engines, physics & real-time rendering"
        case .virtualCasino: return "Slots, poker, roulette & casino games"
        case .mascotCreator: return "Character design, expressions & branding"
        case .appBuilder: return "File ingestion, asset conversion & appraisal"
        case .iconCreator: return "App icons, batch export & automation"
        }
    }
}

// MARK: - Creative Workstations Hub

struct CreativeWorkstationsHub: View {
    @State private var selected: CreativeWorkstationType = .animator
    
    var body: some View {
        HSplitView {
            sidebar.frame(minWidth: 220, maxWidth: 280)
            content
        }
    }
    
    private var sidebar: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(CreativeWorkstationType.allCases) { type in
                    CreativeSidebarRow(type: type, isSelected: selected == type) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selected = type }
                    }
                }
            }
            .padding(12)
        }
        .background(.regularMaterial)
    }
    
    @ViewBuilder
    private var content: some View {
        switch selected {
        case .animator: AnimatorWorkstation()
        case .author: AuthorWorkstation()
        case .artist: ArtistWorkstation()
        case .designer: DesignerWorkstationView()
        case .graphicDesigner: GraphicDesignerWorkstation()
        case .enterpriseDev: EnterpriseDeveloperWorkstation()
        case .saasDev: SaaSDeveloperWorkstation()
        case .businessDev: BusinessDeveloperWorkstation()
        case .gameDev: GameDeveloperWorkstation()
        case .virtualCasino: VirtualCasinoWorkstation()
        case .mascotCreator: MascotCreatorWorkstation()
        case .appBuilder: AppBuilderWorkstation()
        case .iconCreator: IconCreatorWorkstation()
        }
    }
}

struct CreativeSidebarRow: View {
    let type: CreativeWorkstationType
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: type.icon).foregroundStyle(isSelected ? type.color : .secondary).frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue).font(.subheadline.weight(isSelected ? .semibold : .regular))
                    Text(type.description).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? type.color.opacity(0.15) : (isHovered ? Color.secondary.opacity(0.1) : Color.clear)))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}


// MARK: - Animator Workstation

struct AnimatorWorkstation: View {
    @State private var currentFrame = 1
    @State private var totalFrames = 60
    @State private var isPlaying = false
    @State private var fps = 24
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Animator", icon: "film.stack", color: .purple)
            
            HSplitView {
                // Canvas
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.9))
                        VStack {
                            Image(systemName: "figure.walk").font(.system(size: 80)).foregroundStyle(.purple)
                            Text("Frame \(currentFrame)").font(.caption).foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .padding()
                }
                
                // Properties
                VStack(alignment: .leading, spacing: 16) {
                    Text("Properties").font(.headline)
                    
                    Group {
                        HStack { Text("Position X"); Spacer(); Text("120").foregroundStyle(.secondary) }
                        HStack { Text("Position Y"); Spacer(); Text("80").foregroundStyle(.secondary) }
                        HStack { Text("Rotation"); Spacer(); Text("0°").foregroundStyle(.secondary) }
                        HStack { Text("Scale"); Spacer(); Text("100%").foregroundStyle(.secondary) }
                        HStack { Text("Opacity"); Spacer(); Text("100%").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Text("Easing").font(.headline)
                    Picker("Easing", selection: .constant("ease-in-out")) {
                        Text("Linear").tag("linear")
                        Text("Ease In").tag("ease-in")
                        Text("Ease Out").tag("ease-out")
                        Text("Ease In-Out").tag("ease-in-out")
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(minWidth: 200)
            }
            
            Divider()
            
            // Timeline
            VStack(spacing: 8) {
                HStack {
                    Button { isPlaying.toggle() } label: { Image(systemName: isPlaying ? "pause.fill" : "play.fill") }.buttonStyle(.bordered)
                    Button { currentFrame = 1 } label: { Image(systemName: "backward.end.fill") }.buttonStyle(.bordered)
                    Button { currentFrame = totalFrames } label: { Image(systemName: "forward.end.fill") }.buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Text("\(currentFrame) / \(totalFrames)").font(.caption.monospacedDigit())
                    
                    Spacer()
                    
                    Text("FPS:"); Picker("", selection: $fps) { ForEach([12, 24, 30, 60], id: \.self) { Text("\($0)").tag($0) } }.frame(width: 80)
                }
                
                // Timeline scrubber
                Slider(value: Binding(get: { Double(currentFrame) }, set: { currentFrame = Int($0) }), in: 1...Double(totalFrames), step: 1)
                
                // Keyframe track
                HStack(spacing: 2) {
                    ForEach(1...totalFrames, id: \.self) { frame in
                        Rectangle().fill(frame == currentFrame ? Color.purple : (frame % 10 == 0 ? Color.purple.opacity(0.5) : Color.secondary.opacity(0.3)))
                            .frame(height: frame % 10 == 0 ? 20 : 12)
                    }
                }
                .frame(height: 20)
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}

// MARK: - Author Workstation

struct AuthorWorkstation: View {
    @State private var title = "My Novel"
    @State private var content = "Chapter 1\n\nIt was a dark and stormy night..."
    @State private var wordCount = 0
    @State private var selectedChapter = 1
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Author", icon: "text.book.closed.fill", color: .brown)
            
            HSplitView {
                // Chapters
                VStack(spacing: 0) {
                    HStack { Text("Chapters").font(.headline); Spacer(); Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered) }.padding()
                    Divider()
                    List(selection: $selectedChapter) {
                        ForEach(1...10, id: \.self) { ch in
                            Label("Chapter \(ch)", systemImage: "doc.text").tag(ch)
                        }
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 180)
                
                // Editor
                VStack(spacing: 0) {
                    TextField("Title", text: $title).font(.title.bold()).textFieldStyle(.plain).padding()
                    Divider()
                    TextEditor(text: $content).font(.system(.body, design: .serif)).padding()
                    Divider()
                    HStack {
                        Text("\(content.split(separator: " ").count) words").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("Chapter \(selectedChapter)").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal).padding(.vertical, 8)
                    .background(.regularMaterial)
                }
                
                // Outline
                VStack(alignment: .leading, spacing: 12) {
                    Text("Outline").font(.headline)
                    
                    ForEach(["Characters", "Settings", "Plot Points", "Notes"], id: \.self) { section in
                        DisclosureGroup(section) {
                            Text("Add \(section.lowercased())...").font(.caption).foregroundStyle(.secondary).padding(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    Text("Stats").font(.headline)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text("Total Words"); Spacer(); Text("12,450").foregroundStyle(.secondary) }
                        HStack { Text("Chapters"); Spacer(); Text("10").foregroundStyle(.secondary) }
                        HStack { Text("Progress"); Spacer(); Text("45%").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                }
                .padding()
                .frame(minWidth: 200)
            }
        }
    }
}


// MARK: - Artist Workstation

struct ArtistWorkstation: View {
    @State private var brushSize: Double = 20
    @State private var selectedColor = Color.pink
    @State private var selectedTool = "brush"
    
    let tools = [("brush", "paintbrush.fill"), ("pencil", "pencil"), ("eraser", "eraser.fill"), ("fill", "drop.fill"), ("select", "lasso"), ("move", "arrow.up.and.down.and.arrow.left.and.right")]
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black, .white]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Artist", icon: "paintpalette.fill", color: .pink)
            
            HSplitView {
                // Tools
                VStack(spacing: 16) {
                    Text("Tools").font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                        ForEach(tools, id: \.0) { tool, icon in
                            Button { selectedTool = tool } label: { Image(systemName: icon).frame(width: 40, height: 40) }
                            .buttonStyle(.bordered).tint(selectedTool == tool ? .pink : .secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text("Colors").font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], spacing: 6) {
                        ForEach(colors, id: \.self) { color in
                            Circle().fill(color).frame(width: 28, height: 28)
                                .overlay(Circle().stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2))
                                .onTapGesture { selectedColor = color }
                        }
                    }
                    
                    Divider()
                    
                    Text("Brush: \(Int(brushSize))px").font(.caption)
                    Slider(value: $brushSize, in: 1...100)
                    
                    Spacer()
                }
                .padding()
                .frame(width: 160)
                
                // Canvas
                ZStack {
                    Color.white
                    Text("Canvas").font(.title).foregroundStyle(.secondary.opacity(0.3))
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
                
                // Layers
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("Layers").font(.headline); Spacer(); Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered) }
                    
                    ForEach(["Background", "Layer 1", "Layer 2", "Sketch"], id: \.self) { layer in
                        HStack {
                            Image(systemName: "eye").foregroundStyle(.secondary)
                            Text(layer).font(.caption)
                            Spacer()
                        }
                        .padding(8)
                        .background(layer == "Layer 1" ? Color.pink.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 160)
            }
        }
    }
}

// MARK: - Designer Workstation

struct DesignerWorkstationView: View {
    @State private var selectedScreen = "Home"
    let screens = ["Home", "Profile", "Settings", "Detail", "List"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "UI/UX Designer", icon: "ruler.fill", color: .blue)
            
            HSplitView {
                // Screens
                VStack(spacing: 0) {
                    HStack { Text("Screens").font(.headline); Spacer(); Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered) }.padding()
                    Divider()
                    List(screens, id: \.self, selection: $selectedScreen) { screen in
                        Label(screen, systemImage: "rectangle.portrait").tag(screen)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 160)
                
                // Canvas
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 40).fill(Color(.controlBackgroundColor)).frame(width: 280, height: 560)
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.2)).frame(height: 44)
                            RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.1)).frame(height: 120)
                            HStack(spacing: 12) { ForEach(0..<3, id: \.self) { _ in RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.1)) } }.frame(height: 80)
                            Spacer()
                        }
                        .padding(20)
                        .frame(width: 260, height: 520)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Properties
                VStack(alignment: .leading, spacing: 16) {
                    Text("Properties").font(.headline)
                    
                    Group {
                        Text("Layout").font(.subheadline.weight(.medium))
                        HStack { Text("Width"); Spacer(); Text("280pt").foregroundStyle(.secondary) }
                        HStack { Text("Height"); Spacer(); Text("560pt").foregroundStyle(.secondary) }
                        HStack { Text("Padding"); Spacer(); Text("20pt").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Text("Components").font(.subheadline.weight(.medium))
                    ForEach(["Header", "Card", "Grid", "Tab Bar"], id: \.self) { comp in
                        Label(comp, systemImage: "square").font(.caption)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
}

// MARK: - Graphic Designer Workstation

struct GraphicDesignerWorkstation: View {
    @State private var selectedAsset = "Logo"
    let assets = ["Logo", "Banner", "Social Post", "Business Card", "Poster"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Graphic Designer", icon: "paintbrush.pointed.fill", color: .orange)
            
            HSplitView {
                // Assets
                VStack(spacing: 0) {
                    HStack { Text("Assets").font(.headline); Spacer() }.padding()
                    Divider()
                    List(assets, id: \.self, selection: $selectedAsset) { asset in
                        Label(asset, systemImage: "doc.richtext").tag(asset)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 160)
                
                // Canvas
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 16) {
                            Text("BRAND").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
                            Text("Your tagline here").font(.title3).foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 400)
                    .padding()
                }
                .frame(maxWidth: .infinity)
                
                // Typography & Colors
                VStack(alignment: .leading, spacing: 16) {
                    Text("Typography").font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heading").font(.system(.title, design: .rounded).bold())
                        Text("Body Text").font(.system(.body, design: .default))
                        Text("Caption").font(.caption)
                    }
                    
                    Divider()
                    
                    Text("Brand Colors").font(.headline)
                    HStack(spacing: 8) {
                        ForEach([Color.orange, .pink, .white, .black], id: \.self) { color in
                            Circle().fill(color).frame(width: 32, height: 32).overlay(Circle().stroke(Color.secondary.opacity(0.3)))
                        }
                    }
                    
                    Divider()
                    
                    Text("Export").font(.headline)
                    Button("Export PNG") {}.buttonStyle(.borderedProminent)
                    Button("Export SVG") {}.buttonStyle(.bordered)
                    Button("Export PDF") {}.buttonStyle(.bordered)
                    
                    Spacer()
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
}

// MARK: - Creative Header

struct CreativeHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(title).font(.title3.bold())
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }
}

// MARK: - Enterprise Developer Workstation

struct EnterpriseDeveloperWorkstation: View {
    @State private var selectedModule = "Core Services"
    @State private var selectedEnvironment = "Production"
    
    let modules = ["Core Services", "Auth Module", "Payment Gateway", "Reporting", "Integration Hub", "Admin Portal"]
    let environments = ["Development", "Staging", "Production"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Enterprise Developer", icon: "building.2.fill", color: .indigo)
            
            HSplitView {
                // Modules
                VStack(spacing: 0) {
                    HStack { Text("Modules").font(.headline); Spacer(); Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered) }.padding()
                    Divider()
                    List(modules, id: \.self, selection: $selectedModule) { module in
                        Label(module, systemImage: "cube.box.fill").tag(module)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 180)
                
                // Architecture View
                VStack(spacing: 16) {
                    HStack {
                        Picker("Environment", selection: $selectedEnvironment) {
                            ForEach(environments, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Microservices Diagram
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor))
                        VStack(spacing: 20) {
                            Text("Microservices Architecture").font(.headline)
                            HStack(spacing: 30) {
                                EnterpriseServiceBox(name: "API Gateway", status: .healthy)
                                EnterpriseServiceBox(name: "Auth Service", status: .healthy)
                                EnterpriseServiceBox(name: "User Service", status: .warning)
                            }
                            HStack(spacing: 30) {
                                EnterpriseServiceBox(name: "Order Service", status: .healthy)
                                EnterpriseServiceBox(name: "Payment Service", status: .healthy)
                                EnterpriseServiceBox(name: "Notification", status: .healthy)
                            }
                            HStack(spacing: 30) {
                                EnterpriseServiceBox(name: "PostgreSQL", status: .healthy)
                                EnterpriseServiceBox(name: "Redis Cache", status: .healthy)
                                EnterpriseServiceBox(name: "Kafka", status: .warning)
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
                
                // Metrics & Compliance
                VStack(alignment: .leading, spacing: 16) {
                    Text("System Health").font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        EnterpriseMetricRow(label: "Uptime", value: "99.97%", color: .green)
                        EnterpriseMetricRow(label: "Latency", value: "45ms", color: .green)
                        EnterpriseMetricRow(label: "Error Rate", value: "0.02%", color: .green)
                        EnterpriseMetricRow(label: "Throughput", value: "12K/s", color: .blue)
                    }
                    
                    Divider()
                    
                    Text("Compliance").font(.headline)
                    VStack(alignment: .leading, spacing: 6) {
                        Label("SOC 2 Type II", systemImage: "checkmark.shield.fill").foregroundStyle(.green)
                        Label("GDPR Compliant", systemImage: "checkmark.shield.fill").foregroundStyle(.green)
                        Label("HIPAA Ready", systemImage: "checkmark.shield.fill").foregroundStyle(.green)
                        Label("ISO 27001", systemImage: "checkmark.shield.fill").foregroundStyle(.green)
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Text("CI/CD Pipeline").font(.headline)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Circle().fill(.green).frame(width: 8); Text("Build").font(.caption); Spacer(); Text("2m 34s").font(.caption2).foregroundStyle(.secondary) }
                        HStack { Circle().fill(.green).frame(width: 8); Text("Test").font(.caption); Spacer(); Text("5m 12s").font(.caption2).foregroundStyle(.secondary) }
                        HStack { Circle().fill(.green).frame(width: 8); Text("Security Scan").font(.caption); Spacer(); Text("1m 45s").font(.caption2).foregroundStyle(.secondary) }
                        HStack { Circle().fill(.blue).frame(width: 8); Text("Deploy").font(.caption); Spacer(); Text("Running...").font(.caption2).foregroundStyle(.secondary) }
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 220)
            }
        }
    }
}

struct EnterpriseServiceBox: View {
    let name: String
    let status: ServiceStatus
    
    enum ServiceStatus { case healthy, warning, error }
    
    var statusColor: Color {
        switch status {
        case .healthy: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "cube.fill").font(.title2).foregroundStyle(.indigo)
            Text(name).font(.caption2).lineLimit(1)
            Circle().fill(statusColor).frame(width: 8, height: 8)
        }
        .frame(width: 90, height: 80)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)).shadow(radius: 2))
    }
}

struct EnterpriseMetricRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label).font(.caption)
            Spacer()
            Text(value).font(.caption.monospacedDigit().bold()).foregroundStyle(color)
        }
    }
}

// MARK: - SaaS Developer Workstation

struct SaaSDeveloperWorkstation: View {
    @State private var selectedTenant = "Acme Corp"
    @State private var selectedPlan = "Enterprise"
    
    let tenants = ["Acme Corp", "TechStart Inc", "Global Systems", "DataFlow Ltd", "CloudNine"]
    let plans = ["Free", "Starter", "Professional", "Enterprise"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "SaaS Developer", icon: "cloud.fill", color: .cyan)
            
            HSplitView {
                // Tenants
                VStack(spacing: 0) {
                    HStack { Text("Tenants").font(.headline); Spacer(); Text("\(tenants.count)").foregroundStyle(.secondary) }.padding()
                    Divider()
                    List(tenants, id: \.self, selection: $selectedTenant) { tenant in
                        HStack {
                            Label(tenant, systemImage: "building.2")
                            Spacer()
                            Circle().fill(.green).frame(width: 8)
                        }
                        .tag(tenant)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 180)
                
                // Dashboard
                VStack(spacing: 16) {
                    // KPIs
                    HStack(spacing: 16) {
                        SaaSKPICard(title: "MRR", value: "$124,500", change: "+12%", icon: "dollarsign.circle.fill", color: .green)
                        SaaSKPICard(title: "Active Users", value: "8,432", change: "+8%", icon: "person.2.fill", color: .blue)
                        SaaSKPICard(title: "Churn Rate", value: "2.1%", change: "-0.3%", icon: "arrow.down.circle.fill", color: .orange)
                        SaaSKPICard(title: "NPS Score", value: "72", change: "+5", icon: "star.fill", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    HSplitView {
                        // Subscription Plans
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Subscription Plans").font(.headline)
                            ForEach(plans, id: \.self) { plan in
                                HStack {
                                    Text(plan).font(.subheadline)
                                    Spacer()
                                    Text(planPrice(plan)).font(.caption).foregroundStyle(.secondary)
                                    Text("\(planUsers(plan)) users").font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 8).fill(selectedPlan == plan ? Color.cyan.opacity(0.15) : Color.clear))
                                .onTapGesture { selectedPlan = plan }
                            }
                            Spacer()
                        }
                        .padding()
                        
                        // Feature Flags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feature Flags").font(.headline)
                            FeatureFlagRow(name: "New Dashboard", enabled: true, rollout: 100)
                            FeatureFlagRow(name: "AI Assistant", enabled: true, rollout: 50)
                            FeatureFlagRow(name: "Advanced Analytics", enabled: true, rollout: 25)
                            FeatureFlagRow(name: "Beta Export", enabled: false, rollout: 0)
                            Spacer()
                        }
                        .padding()
                    }
                }
                
                // Tenant Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tenant: \(selectedTenant)").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text("Plan"); Spacer(); Text("Enterprise").foregroundStyle(.cyan) }
                        HStack { Text("Users"); Spacer(); Text("245").foregroundStyle(.secondary) }
                        HStack { Text("Storage"); Spacer(); Text("12.4 GB").foregroundStyle(.secondary) }
                        HStack { Text("API Calls"); Spacer(); Text("1.2M/mo").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Text("Integrations").font(.headline)
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Slack", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Label("Salesforce", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Label("Jira", systemImage: "xmark.circle").foregroundStyle(.secondary)
                        Label("Zapier", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    Button("Manage Tenant") {}.buttonStyle(.borderedProminent).tint(.cyan)
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
    
    func planPrice(_ plan: String) -> String {
        switch plan {
        case "Free": return "$0"
        case "Starter": return "$29/mo"
        case "Professional": return "$99/mo"
        case "Enterprise": return "$299/mo"
        default: return ""
        }
    }
    
    func planUsers(_ plan: String) -> Int {
        switch plan {
        case "Free": return 156
        case "Starter": return 423
        case "Professional": return 892
        case "Enterprise": return 234
        default: return 0
        }
    }
}

struct SaaSKPICard: View {
    let title: String
    let value: String
    let change: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundStyle(color)
                Spacer()
                Text(change).font(.caption2).foregroundStyle(change.hasPrefix("+") || change.hasPrefix("-0") ? .green : .red)
            }
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct FeatureFlagRow: View {
    let name: String
    let enabled: Bool
    let rollout: Int
    
    var body: some View {
        HStack {
            Circle().fill(enabled ? .green : .secondary).frame(width: 8)
            Text(name).font(.caption)
            Spacer()
            if enabled {
                Text("\(rollout)%").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Business Developer Workstation

struct BusinessDeveloperWorkstation: View {
    @State private var selectedModule = "CRM"
    
    let modules = ["CRM", "ERP", "HR", "Inventory", "Finance", "Reports"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Business Developer", icon: "briefcase.fill", color: .green)
            
            HSplitView {
                // Modules
                VStack(spacing: 0) {
                    HStack { Text("Modules").font(.headline); Spacer() }.padding()
                    Divider()
                    List(modules, id: \.self, selection: $selectedModule) { module in
                        Label(module, systemImage: moduleIcon(module)).tag(module)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 160)
                
                // Workflow Designer
                VStack(spacing: 16) {
                    HStack {
                        Text("Business Process: Lead to Customer").font(.headline)
                        Spacer()
                        Button("Edit Flow") {}.buttonStyle(.bordered)
                        Button("Run") {}.buttonStyle(.borderedProminent).tint(.green)
                    }
                    .padding(.horizontal)
                    
                    // Process Flow
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            BusinessProcessNode(title: "Lead Created", type: .trigger, color: .blue)
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            BusinessProcessNode(title: "Qualify Lead", type: .action, color: .green)
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            BusinessProcessNode(title: "Score > 50?", type: .decision, color: .orange)
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            BusinessProcessNode(title: "Create Opportunity", type: .action, color: .green)
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            BusinessProcessNode(title: "Send Email", type: .action, color: .green)
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            BusinessProcessNode(title: "Assign Rep", type: .action, color: .green)
                        }
                        .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    .padding(.horizontal)
                    
                    // Data Model
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Model: \(selectedModule)").font(.headline)
                        
                        HStack(spacing: 20) {
                            BusinessEntityCard(name: "Contact", fields: ["Name", "Email", "Phone", "Company"])
                            BusinessEntityCard(name: "Account", fields: ["Name", "Industry", "Revenue", "Employees"])
                            BusinessEntityCard(name: "Opportunity", fields: ["Name", "Amount", "Stage", "Close Date"])
                            BusinessEntityCard(name: "Activity", fields: ["Type", "Subject", "Due Date", "Status"])
                        }
                    }
                    .padding()
                }
                
                // Integrations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Integrations").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BusinessIntegrationRow(name: "QuickBooks", status: .connected)
                        BusinessIntegrationRow(name: "Stripe", status: .connected)
                        BusinessIntegrationRow(name: "Mailchimp", status: .connected)
                        BusinessIntegrationRow(name: "Twilio", status: .pending)
                        BusinessIntegrationRow(name: "DocuSign", status: .disconnected)
                    }
                    
                    Divider()
                    
                    Text("Automation Rules").font(.headline)
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Auto-assign leads", systemImage: "bolt.fill").foregroundStyle(.green)
                        Label("Send welcome email", systemImage: "bolt.fill").foregroundStyle(.green)
                        Label("Update inventory", systemImage: "bolt.fill").foregroundStyle(.green)
                        Label("Generate invoice", systemImage: "bolt.fill").foregroundStyle(.green)
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    Button("Add Integration") {}.buttonStyle(.bordered)
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
    
    func moduleIcon(_ module: String) -> String {
        switch module {
        case "CRM": return "person.2.fill"
        case "ERP": return "gearshape.2.fill"
        case "HR": return "person.crop.rectangle.stack.fill"
        case "Inventory": return "shippingbox.fill"
        case "Finance": return "dollarsign.circle.fill"
        case "Reports": return "chart.bar.fill"
        default: return "folder.fill"
        }
    }
}

struct BusinessProcessNode: View {
    let title: String
    let type: NodeType
    let color: Color
    
    enum NodeType { case trigger, action, decision }
    
    var shape: some View {
        Group {
            switch type {
            case .trigger: Circle().fill(color.opacity(0.2)).overlay(Circle().stroke(color, lineWidth: 2))
            case .action: RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.2)).overlay(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 2))
            case .decision: Diamond().fill(color.opacity(0.2)).overlay(Diamond().stroke(color, lineWidth: 2))
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            shape.frame(width: 60, height: 60)
            Text(title).font(.caption2).multilineTextAlignment(.center).frame(width: 80)
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct BusinessEntityCard: View {
    let name: String
    let fields: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.subheadline.bold())
            ForEach(fields, id: \.self) { field in
                HStack {
                    Text(field).font(.caption2)
                    Spacer()
                    Text("String").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 140)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
    }
}

struct BusinessIntegrationRow: View {
    let name: String
    let status: IntegrationStatus
    
    enum IntegrationStatus { case connected, pending, disconnected }
    
    var statusColor: Color {
        switch status {
        case .connected: return .green
        case .pending: return .orange
        case .disconnected: return .secondary
        }
    }
    
    var body: some View {
        HStack {
            Circle().fill(statusColor).frame(width: 8)
            Text(name).font(.caption)
            Spacer()
            Text(status == .connected ? "Active" : (status == .pending ? "Pending" : "Off")).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Game Developer Workstation

struct GameDeveloperWorkstation: View {
    @State private var selectedScene = "Main Level"
    @State private var isPlaying = false
    @State private var fps = 60
    
    let scenes = ["Main Menu", "Main Level", "Boss Arena", "Cutscene 1", "Game Over"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Game Developer", icon: "gamecontroller.fill", color: .red)
            
            HSplitView {
                // Scene Hierarchy
                VStack(spacing: 0) {
                    HStack { Text("Hierarchy").font(.headline); Spacer(); Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered) }.padding()
                    Divider()
                    List {
                        DisclosureGroup("Scene: \(selectedScene)") {
                            DisclosureGroup("Player") {
                                Label("Sprite", systemImage: "photo")
                                Label("Collider", systemImage: "square.dashed")
                                Label("Controller", systemImage: "gamecontroller")
                            }
                            DisclosureGroup("Enemies") {
                                Label("Enemy_01", systemImage: "figure.stand")
                                Label("Enemy_02", systemImage: "figure.stand")
                                Label("Boss", systemImage: "figure.stand")
                            }
                            DisclosureGroup("Environment") {
                                Label("Ground", systemImage: "rectangle.fill")
                                Label("Platforms", systemImage: "square.stack.3d.up")
                                Label("Background", systemImage: "photo.stack")
                            }
                            Label("Camera", systemImage: "camera.fill")
                            Label("Lights", systemImage: "light.max")
                            Label("Audio", systemImage: "speaker.wave.2.fill")
                        }
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 200)
                
                // Game View
                VStack(spacing: 0) {
                    // Toolbar
                    HStack {
                        Button { } label: { Image(systemName: "arrow.uturn.backward") }.buttonStyle(.bordered)
                        Button { } label: { Image(systemName: "arrow.uturn.forward") }.buttonStyle(.bordered)
                        Divider().frame(height: 20)
                        Button { isPlaying.toggle() } label: { Image(systemName: isPlaying ? "stop.fill" : "play.fill") }.buttonStyle(.borderedProminent).tint(.red)
                        Button { } label: { Image(systemName: "pause.fill") }.buttonStyle(.bordered)
                        Spacer()
                        Text("FPS: \(fps)").font(.caption.monospacedDigit()).foregroundStyle(.green)
                        Picker("Scene", selection: $selectedScene) {
                            ForEach(scenes, id: \.self) { Text($0).tag($0) }
                        }
                        .frame(width: 150)
                    }
                    .padding(8)
                    .background(.regularMaterial)
                    
                    // Game Canvas
                    ZStack {
                        Color.black
                        VStack {
                            // Sky gradient
                            LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                                .frame(height: 200)
                            Spacer()
                        }
                        
                        // Ground
                        VStack {
                            Spacer()
                            Rectangle().fill(.brown).frame(height: 60)
                        }
                        
                        // Player
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "figure.run").font(.system(size: 50)).foregroundStyle(.red)
                                    .offset(y: -60)
                                Spacer()
                            }
                            .padding(.leading, 100)
                        }
                        
                        // UI Overlay
                        VStack {
                            HStack {
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        Image(systemName: "heart.fill").foregroundStyle(.red)
                                    }
                                }
                                Spacer()
                                Text("Score: 12,450").font(.headline).foregroundStyle(.white)
                            }
                            .padding()
                            Spacer()
                        }
                        
                        if !isPlaying {
                            Text("Press Play to Start").font(.title2).foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                }
                
                // Inspector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Inspector").font(.headline)
                    
                    Text("Player").font(.subheadline.bold())
                    
                    Group {
                        Text("Transform").font(.caption.weight(.medium))
                        HStack { Text("Position"); Spacer(); Text("(100, 80)").foregroundStyle(.secondary) }
                        HStack { Text("Rotation"); Spacer(); Text("0°").foregroundStyle(.secondary) }
                        HStack { Text("Scale"); Spacer(); Text("(1, 1)").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Group {
                        Text("Physics").font(.caption.weight(.medium))
                        HStack { Text("Mass"); Spacer(); Text("1.0").foregroundStyle(.secondary) }
                        HStack { Text("Gravity"); Spacer(); Text("9.8").foregroundStyle(.secondary) }
                        HStack { Text("Friction"); Spacer(); Text("0.5").foregroundStyle(.secondary) }
                    }
                    .font(.caption)
                    
                    Divider()
                    
                    Text("Components").font(.caption.weight(.medium))
                    VStack(alignment: .leading, spacing: 4) {
                        Label("SpriteRenderer", systemImage: "photo").font(.caption)
                        Label("BoxCollider2D", systemImage: "square.dashed").font(.caption)
                        Label("Rigidbody2D", systemImage: "arrow.down.circle").font(.caption)
                        Label("PlayerController", systemImage: "gearshape").font(.caption)
                    }
                    
                    Spacer()
                    
                    Button("Add Component") {}.buttonStyle(.bordered)
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
}

// MARK: - Virtual Casino Workstation

struct VirtualCasinoWorkstation: View {
    @State private var selectedGame = "Slots"
    @State private var balance: Double = 10000
    @State private var currentBet: Double = 100
    
    let games = ["Slots", "Poker", "Blackjack", "Roulette", "Baccarat"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Virtual Casino", icon: "suit.spade.fill", color: .yellow)
            
            HSplitView {
                // Game Selection
                VStack(spacing: 0) {
                    HStack {
                        Text("Games").font(.headline)
                        Spacer()
                    }
                    .padding()
                    Divider()
                    
                    List(games, id: \.self, selection: $selectedGame) { game in
                        Label(game, systemImage: gameIcon(game)).tag(game)
                    }
                    .listStyle(.sidebar)
                    
                    Divider()
                    
                    // Balance
                    VStack(spacing: 8) {
                        Text("Balance").font(.caption).foregroundStyle(.secondary)
                        Text("$\(balance, specifier: "%.2f")").font(.title2.bold()).foregroundStyle(.green)
                    }
                    .padding()
                }
                .frame(minWidth: 160)
                
                // Game Area
                Group {
                    switch selectedGame {
                    case "Slots": SlotMachineView(balance: $balance, bet: $currentBet)
                    case "Poker": PokerTableView(balance: $balance, bet: $currentBet)
                    default: ComingSoonGameView(game: selectedGame)
                    }
                }
                
                // Stats & History
                VStack(alignment: .leading, spacing: 16) {
                    Text("Session Stats").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CasinoStatRow(label: "Hands Played", value: "47")
                        CasinoStatRow(label: "Win Rate", value: "52%")
                        CasinoStatRow(label: "Biggest Win", value: "$2,500")
                        CasinoStatRow(label: "Session P/L", value: "+$1,250")
                    }
                    
                    Divider()
                    
                    Text("Bet Amount").font(.headline)
                    HStack {
                        ForEach([50, 100, 250, 500], id: \.self) { amount in
                            Button("$\(amount)") { currentBet = Double(amount) }
                                .buttonStyle(.bordered)
                                .tint(currentBet == Double(amount) ? .yellow : .secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text("Recent Activity").font(.headline)
                    VStack(alignment: .leading, spacing: 6) {
                        CasinoActivityRow(game: "Slots", result: "+$500", isWin: true)
                        CasinoActivityRow(game: "Poker", result: "-$100", isWin: false)
                        CasinoActivityRow(game: "Slots", result: "+$250", isWin: true)
                        CasinoActivityRow(game: "Blackjack", result: "+$200", isWin: true)
                        CasinoActivityRow(game: "Roulette", result: "-$50", isWin: false)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
    
    func gameIcon(_ game: String) -> String {
        switch game {
        case "Slots": return "dollarsign.circle.fill"
        case "Poker": return "suit.spade.fill"
        case "Blackjack": return "suit.club.fill"
        case "Roulette": return "circle.grid.3x3.fill"
        case "Baccarat": return "suit.diamond.fill"
        default: return "gamecontroller.fill"
        }
    }
}

// MARK: - Slot Machine

struct SlotMachineView: View {
    @Binding var balance: Double
    @Binding var bet: Double
    @State private var reels: [String] = ["🍒", "🍋", "🍊"]
    @State private var isSpinning = false
    @State private var lastWin: Double = 0
    
    let symbols = ["🍒", "🍋", "🍊", "🍇", "⭐️", "7️⃣", "💎", "🔔"]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("MEGA JACKPOT SLOTS").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.yellow)
            
            // Jackpot Display
            HStack {
                Text("JACKPOT:").font(.headline)
                Text("$125,000").font(.title.bold()).foregroundStyle(.yellow)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.8)))
            
            // Slot Reels
            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16).fill(Color.white).frame(width: 120, height: 140)
                        RoundedRectangle(cornerRadius: 16).stroke(Color.yellow, lineWidth: 4)
                        Text(reels[index]).font(.system(size: 70))
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(isSpinning ? .linear(duration: 0.1).repeatForever(autoreverses: false) : .default, value: isSpinning)
                    }
                    .frame(width: 120, height: 140)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .purple.opacity(0.5), radius: 20)
            )
            
            // Win Display
            if lastWin > 0 {
                Text("WIN: $\(lastWin, specifier: "%.0f")").font(.title.bold()).foregroundStyle(.green)
                    .transition(.scale)
            }
            
            // Controls
            HStack(spacing: 20) {
                VStack {
                    Text("BET").font(.caption).foregroundStyle(.secondary)
                    Text("$\(bet, specifier: "%.0f")").font(.title3.bold())
                }
                .frame(width: 80)
                
                Button {
                    spin()
                } label: {
                    Text("SPIN")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 150, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom))
                        )
                }
                .buttonStyle(.plain)
                .disabled(isSpinning || balance < bet)
                
                VStack {
                    Text("BALANCE").font(.caption).foregroundStyle(.secondary)
                    Text("$\(balance, specifier: "%.0f")").font(.title3.bold()).foregroundStyle(.green)
                }
                .frame(width: 100)
            }
            
            // Paytable
            HStack(spacing: 24) {
                PaytableItem(symbols: "7️⃣7️⃣7️⃣", multiplier: "100x")
                PaytableItem(symbols: "💎💎💎", multiplier: "50x")
                PaytableItem(symbols: "⭐️⭐️⭐️", multiplier: "25x")
                PaytableItem(symbols: "🍒🍒🍒", multiplier: "10x")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
    
    func spin() {
        guard balance >= bet else { return }
        balance -= bet
        isSpinning = true
        lastWin = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSpinning = false
            reels = (0..<3).map { _ in symbols.randomElement()! }
            calculateWin()
        }
    }
    
    func calculateWin() {
        if reels[0] == reels[1] && reels[1] == reels[2] {
            let multiplier: Double
            switch reels[0] {
            case "7️⃣": multiplier = 100
            case "💎": multiplier = 50
            case "⭐️": multiplier = 25
            default: multiplier = 10
            }
            lastWin = bet * multiplier
            balance += lastWin
        } else if reels[0] == reels[1] || reels[1] == reels[2] {
            lastWin = bet * 2
            balance += lastWin
        }
    }
}

struct PaytableItem: View {
    let symbols: String
    let multiplier: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(symbols).font(.title3)
            Text(multiplier).font(.caption.bold()).foregroundStyle(.yellow)
        }
    }
}

// MARK: - Poker Table

struct PokerTableView: View {
    @Binding var balance: Double
    @Binding var bet: Double
    @State private var playerHand: [PlayingCard] = []
    @State private var communityCards: [PlayingCard] = []
    @State private var pot: Double = 0
    @State private var gamePhase = "waiting"
    @State private var heldCards: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TEXAS HOLD'EM POKER").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(.white)
            
            // Pot
            HStack {
                Text("POT:").font(.headline).foregroundStyle(.white)
                Text("$\(pot, specifier: "%.0f")").font(.title.bold()).foregroundStyle(.yellow)
            }
            
            // Poker Table
            ZStack {
                // Table
                Ellipse().fill(Color.green.opacity(0.8)).frame(width: 600, height: 300)
                Ellipse().stroke(Color.brown, lineWidth: 20).frame(width: 620, height: 320)
                
                VStack(spacing: 30) {
                    // Community Cards
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            if index < communityCards.count {
                                PokerCardView(card: communityCards[index])
                            } else {
                                CardBackView()
                            }
                        }
                    }
                    
                    // Player Hand
                    HStack(spacing: 8) {
                        ForEach(Array(playerHand.enumerated()), id: \.offset) { index, card in
                            PokerCardView(card: card, isHeld: heldCards.contains(index))
                                .onTapGesture {
                                    if gamePhase == "draw" {
                                        if heldCards.contains(index) {
                                            heldCards.remove(index)
                                        } else {
                                            heldCards.insert(index)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .frame(height: 350)
            
            // Hand Rank
            if !playerHand.isEmpty {
                Text(evaluateHand()).font(.title3.bold()).foregroundStyle(.yellow)
            }
            
            // Controls
            HStack(spacing: 16) {
                if gamePhase == "waiting" {
                    Button("DEAL ($\(bet, specifier: "%.0f"))") {
                        deal()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(balance < bet)
                } else if gamePhase == "draw" {
                    Button("HOLD & DRAW") {
                        draw()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    Button("NEW HAND") {
                        resetHand()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                
                HStack(spacing: 8) {
                    Button("FOLD") { resetHand() }.buttonStyle(.bordered).tint(.red)
                    Button("CHECK") {}.buttonStyle(.bordered)
                    Button("RAISE") {}.buttonStyle(.bordered).tint(.green)
                }
                .disabled(gamePhase == "waiting")
            }
            
            // Balance
            HStack {
                Text("Balance:").foregroundStyle(.secondary)
                Text("$\(balance, specifier: "%.0f")").font(.headline).foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.1), Color(red: 0.05, green: 0.1, blue: 0.05)], startPoint: .top, endPoint: .bottom))
    }
    
    func deal() {
        guard balance >= bet else { return }
        balance -= bet
        pot = bet * 2
        playerHand = (0..<5).map { _ in PlayingCard.random() }
        communityCards = []
        gamePhase = "draw"
        heldCards = []
    }
    
    func draw() {
        for i in 0..<5 {
            if !heldCards.contains(i) {
                playerHand[i] = PlayingCard.random()
            }
        }
        communityCards = (0..<5).map { _ in PlayingCard.random() }
        gamePhase = "showdown"
        
        // Simple win logic
        let winAmount = pot * Double.random(in: 0...2)
        balance += winAmount
    }
    
    func resetHand() {
        playerHand = []
        communityCards = []
        pot = 0
        gamePhase = "waiting"
        heldCards = []
    }
    
    func evaluateHand() -> String {
        let ranks = playerHand.map { $0.rank }
        let suits = playerHand.map { $0.suit }
        
        let isFlush = Set(suits).count == 1
        let rankCounts = Dictionary(grouping: ranks, by: { $0 }).mapValues { $0.count }
        let maxCount = rankCounts.values.max() ?? 0
        
        if isFlush { return "FLUSH!" }
        if maxCount == 4 { return "FOUR OF A KIND!" }
        if maxCount == 3 && rankCounts.values.contains(2) { return "FULL HOUSE!" }
        if maxCount == 3 { return "THREE OF A KIND" }
        if rankCounts.values.filter({ $0 == 2 }).count == 2 { return "TWO PAIR" }
        if maxCount == 2 { return "ONE PAIR" }
        return "HIGH CARD"
    }
}

struct PlayingCard: Identifiable {
    let id = UUID()
    let rank: String
    let suit: String
    
    var display: String { "\(rank)\(suit)" }
    var color: Color { suit == "♥️" || suit == "♦️" ? .red : .primary }
    
    static func random() -> PlayingCard {
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suits = ["♠️", "♥️", "♦️", "♣️"]
        return PlayingCard(rank: ranks.randomElement()!, suit: suits.randomElement()!)
    }
}

struct PokerCardView: View {
    let card: PlayingCard
    var isHeld: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color.white).frame(width: 60, height: 84)
            RoundedRectangle(cornerRadius: 8).stroke(isHeld ? Color.yellow : Color.gray, lineWidth: isHeld ? 3 : 1)
            VStack {
                Text(card.rank).font(.headline.bold()).foregroundStyle(card.color)
                Text(card.suit).font(.title2)
            }
        }
        .frame(width: 60, height: 84)
        .shadow(radius: isHeld ? 5 : 2)
    }
}

struct CardBackView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color.blue).frame(width: 60, height: 84)
            RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2)
            Image(systemName: "suit.spade.fill").font(.title).foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 60, height: 84)
    }
}

// MARK: - Coming Soon Game

struct ComingSoonGameView: View {
    let game: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill").font(.system(size: 60)).foregroundStyle(.yellow)
            Text("\(game)").font(.largeTitle.bold())
            Text("Coming Soon!").font(.title2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - Casino Helper Views

struct CasinoStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).font(.caption)
            Spacer()
            Text(value).font(.caption.bold()).foregroundStyle(.yellow)
        }
    }
}

struct CasinoActivityRow: View {
    let game: String
    let result: String
    let isWin: Bool
    
    var body: some View {
        HStack {
            Text(game).font(.caption2)
            Spacer()
            Text(result).font(.caption2.bold()).foregroundStyle(isWin ? .green : .red)
        }
    }
}

// MARK: - Mascot Creator Workstation

struct MascotCreatorWorkstation: View {
    @State private var selectedPart = "Head"
    @State private var mascotName = "Buddy"
    @State private var selectedExpression = "happy"
    @State private var primaryColor = Color.blue
    @State private var secondaryColor = Color.yellow
    
    let bodyParts = ["Head", "Eyes", "Mouth", "Body", "Arms", "Legs", "Accessories"]
    let expressions = ["happy", "sad", "excited", "angry", "surprised", "wink", "cool", "sleepy"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Mascot Creator", icon: "face.smiling.fill", color: .mint)
            
            HSplitView {
                // Parts Library
                VStack(spacing: 0) {
                    HStack { Text("Parts").font(.headline); Spacer() }.padding()
                    Divider()
                    List(bodyParts, id: \.self, selection: $selectedPart) { part in
                        Label(part, systemImage: partIcon(part)).tag(part)
                    }
                    .listStyle(.sidebar)
                }
                .frame(minWidth: 160)
                
                // Canvas
                VStack(spacing: 16) {
                    // Mascot Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 20).fill(Color(.controlBackgroundColor))
                        
                        VStack(spacing: 0) {
                            // Head
                            ZStack {
                                Circle().fill(primaryColor).frame(width: 160, height: 160)
                                
                                // Face
                                VStack(spacing: 12) {
                                    // Eyes
                                    HStack(spacing: 30) {
                                        MascotEye(expression: selectedExpression)
                                        MascotEye(expression: selectedExpression, isRight: true)
                                    }
                                    
                                    // Mouth
                                    MascotMouth(expression: selectedExpression)
                                }
                                .offset(y: 10)
                                
                                // Accessories based on expression
                                if selectedExpression == "cool" {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.black)
                                        .frame(width: 100, height: 20)
                                        .offset(y: -10)
                                }
                            }
                            
                            // Body
                            ZStack {
                                Capsule().fill(primaryColor).frame(width: 120, height: 100)
                                
                                // Arms
                                HStack(spacing: 100) {
                                    Capsule().fill(primaryColor).frame(width: 30, height: 60).rotationEffect(.degrees(-20))
                                    Capsule().fill(primaryColor).frame(width: 30, height: 60).rotationEffect(.degrees(20))
                                }
                            }
                            .offset(y: -20)
                            
                            // Legs
                            HStack(spacing: 20) {
                                Capsule().fill(primaryColor).frame(width: 35, height: 50)
                                Capsule().fill(primaryColor).frame(width: 35, height: 50)
                            }
                            .offset(y: -30)
                        }
                    }
                    .frame(height: 400)
                    .padding()
                    
                    // Name
                    HStack {
                        Text("Name:").font(.headline)
                        TextField("Mascot Name", text: $mascotName).textFieldStyle(.roundedBorder).frame(width: 200)
                    }
                    
                    // Expression Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expression").font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(expressions, id: \.self) { expr in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { selectedExpression = expr }
                                    } label: {
                                        VStack {
                                            Text(expressionEmoji(expr)).font(.largeTitle)
                                            Text(expr.capitalized).font(.caption2)
                                        }
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(selectedExpression == expr ? Color.mint.opacity(0.3) : Color.clear))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Properties
                VStack(alignment: .leading, spacing: 16) {
                    Text("Properties").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Primary Color").font(.subheadline)
                        ColorPicker("", selection: $primaryColor).labelsHidden()
                        
                        Text("Secondary Color").font(.subheadline)
                        ColorPicker("", selection: $secondaryColor).labelsHidden()
                    }
                    
                    Divider()
                    
                    Text("Presets").font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 8) {
                        MascotPresetButton(name: "Ocean", primary: .blue, secondary: .cyan) { primaryColor = .blue; secondaryColor = .cyan }
                        MascotPresetButton(name: "Forest", primary: .green, secondary: .mint) { primaryColor = .green; secondaryColor = .mint }
                        MascotPresetButton(name: "Sunset", primary: .orange, secondary: .red) { primaryColor = .orange; secondaryColor = .red }
                        MascotPresetButton(name: "Royal", primary: .purple, secondary: .pink) { primaryColor = .purple; secondaryColor = .pink }
                    }
                    
                    Divider()
                    
                    Text("Part: \(selectedPart)").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(partOptions(selectedPart), id: \.self) { option in
                            HStack {
                                Circle().fill(Color.mint).frame(width: 8)
                                Text(option).font(.caption)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button("Export PNG") {}.buttonStyle(.borderedProminent).tint(.mint).frame(maxWidth: .infinity)
                        Button("Export SVG") {}.buttonStyle(.bordered).frame(maxWidth: .infinity)
                        Button("Save to Library") {}.buttonStyle(.bordered).frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(width: 200)
            }
        }
    }
    
    func partIcon(_ part: String) -> String {
        switch part {
        case "Head": return "circle.fill"
        case "Eyes": return "eye.fill"
        case "Mouth": return "mouth.fill"
        case "Body": return "figure.stand"
        case "Arms": return "hand.raised.fill"
        case "Legs": return "figure.walk"
        case "Accessories": return "star.fill"
        default: return "square.fill"
        }
    }
    
    func expressionEmoji(_ expr: String) -> String {
        switch expr {
        case "happy": return "😊"
        case "sad": return "😢"
        case "excited": return "🤩"
        case "angry": return "😠"
        case "surprised": return "😮"
        case "wink": return "😉"
        case "cool": return "😎"
        case "sleepy": return "😴"
        default: return "😊"
        }
    }
    
    func partOptions(_ part: String) -> [String] {
        switch part {
        case "Head": return ["Round", "Square", "Oval", "Heart"]
        case "Eyes": return ["Round", "Oval", "Anime", "Dot"]
        case "Mouth": return ["Smile", "Grin", "Open", "Line"]
        case "Body": return ["Round", "Tall", "Wide", "Slim"]
        case "Arms": return ["Short", "Long", "Wavy", "None"]
        case "Legs": return ["Short", "Long", "Stubby", "None"]
        case "Accessories": return ["Hat", "Glasses", "Bow", "Cape"]
        default: return []
        }
    }
}

struct MascotEye: View {
    let expression: String
    var isRight: Bool = false
    
    var body: some View {
        ZStack {
            // Eye white
            Ellipse().fill(Color.white).frame(width: 35, height: eyeHeight)
            
            // Pupil
            Circle().fill(Color.black).frame(width: 15, height: 15).offset(x: pupilOffset, y: pupilYOffset)
            
            // Highlight
            Circle().fill(Color.white).frame(width: 6, height: 6).offset(x: -3, y: -3)
            
            // Closed eye line
            if expression == "sleepy" || expression == "wink" && isRight {
                Capsule().fill(Color.black).frame(width: 30, height: 4)
            }
        }
    }
    
    var eyeHeight: CGFloat {
        switch expression {
        case "surprised": return 40
        case "angry": return 25
        case "sleepy": return 15
        default: return 30
        }
    }
    
    var pupilOffset: CGFloat {
        switch expression {
        case "wink" where !isRight: return 0
        default: return 0
        }
    }
    
    var pupilYOffset: CGFloat {
        switch expression {
        case "sad": return 5
        case "excited": return -3
        default: return 0
        }
    }
}

struct MascotMouth: View {
    let expression: String
    
    var body: some View {
        Group {
            switch expression {
            case "happy", "excited":
                MouthArc(isSmile: true).stroke(Color.black, lineWidth: 4).frame(width: 50, height: 25)
            case "sad":
                MouthArc(isSmile: false).stroke(Color.black, lineWidth: 4).frame(width: 50, height: 25)
            case "surprised":
                Ellipse().fill(Color.black).frame(width: 30, height: 40)
            case "angry":
                Rectangle().fill(Color.black).frame(width: 40, height: 6)
            case "wink", "cool":
                MouthArc(isSmile: true).stroke(Color.black, lineWidth: 4).frame(width: 40, height: 20)
            case "sleepy":
                Capsule().fill(Color.black).frame(width: 20, height: 8)
            default:
                MouthArc(isSmile: true).stroke(Color.black, lineWidth: 4).frame(width: 50, height: 25)
            }
        }
    }
}

struct MouthArc: Shape {
    let isSmile: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isSmile {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.minY))
        }
        return path
    }
}

struct MascotPresetButton: View {
    let name: String
    let primary: Color
    let secondary: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    Circle().fill(primary).frame(width: 16, height: 16)
                    Circle().fill(secondary).frame(width: 16, height: 16)
                }
                Text(name).font(.caption2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Builder Workstation

struct AppBuilderWorkstation: View {
    @State private var selectedTab = "Ingest"
    @State private var ingestedFiles: [IngestedFile] = IngestedFile.samples
    @State private var convertedAssets: [ConvertedAsset] = ConvertedAsset.samples
    @State private var selectedFile: IngestedFile?
    @State private var isProcessing = false
    
    let tabs = ["Ingest", "Convert", "Appraise", "Export"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "App Builder", icon: "hammer.fill", color: .teal)
            
            // Tab Bar
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedTab = tab }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tabIcon(tab)).font(.title3)
                            Text(tab).font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? Color.teal.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case "Ingest": FileIngestionView(files: $ingestedFiles, isProcessing: $isProcessing)
                case "Convert": AssetConversionView(files: ingestedFiles, assets: $convertedAssets, isProcessing: $isProcessing)
                case "Appraise": AssetAppraisalView(assets: convertedAssets)
                case "Export": AssetExportView(assets: convertedAssets)
                default: EmptyView()
                }
            }
        }
    }
    
    func tabIcon(_ tab: String) -> String {
        switch tab {
        case "Ingest": return "square.and.arrow.down.fill"
        case "Convert": return "arrow.triangle.2.circlepath"
        case "Appraise": return "star.fill"
        case "Export": return "square.and.arrow.up.fill"
        default: return "folder.fill"
        }
    }
}

// MARK: - File Ingestion View

struct FileIngestionView: View {
    @Binding var files: [IngestedFile]
    @Binding var isProcessing: Bool
    @State private var isDragging = false
    
    var body: some View {
        HSplitView {
            // Drop Zone
            VStack(spacing: 20) {
                Text("File Ingestion").font(.title2.bold())
                
                // Drop Area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
                        .foregroundStyle(isDragging ? .teal : .secondary)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(isDragging ? .teal : .secondary)
                        
                        Text("Drop files here").font(.title3)
                        Text("or click to browse").font(.caption).foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(["PDF", "JSON", "CSV", "XML", "IMG"], id: \.self) { type in
                                Text(type).font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Color.teal.opacity(0.2)))
                            }
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .onTapGesture { addSampleFile() }
                
                // Quick Actions
                HStack(spacing: 12) {
                    Button("Import Folder") { addSampleFile() }.buttonStyle(.bordered)
                    Button("From URL") {}.buttonStyle(.bordered)
                    Button("From API") {}.buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            // File List
            VStack(spacing: 0) {
                HStack {
                    Text("Ingested Files").font(.headline)
                    Spacer()
                    Text("\(files.count) files").font(.caption).foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(files) { file in
                        IngestedFileRow(file: file)
                    }
                    .onDelete { files.remove(atOffsets: $0) }
                }
                .listStyle(.plain)
                
                Divider()
                
                HStack {
                    Text("Total: \(totalSize)").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button("Clear All") { files.removeAll() }.buttonStyle(.bordered).tint(.red)
                }
                .padding()
            }
            .frame(minWidth: 300)
        }
    }
    
    var totalSize: String {
        let total = files.reduce(0) { $0 + $1.size }
        if total > 1_000_000 { return String(format: "%.1f MB", Double(total) / 1_000_000) }
        return String(format: "%.1f KB", Double(total) / 1_000)
    }
    
    func addSampleFile() {
        let types = ["pdf", "json", "csv", "xml", "png", "jpg"]
        let names = ["document", "data", "export", "config", "image", "report"]
        files.append(IngestedFile(
            name: "\(names.randomElement()!)_\(Int.random(in: 100...999)).\(types.randomElement()!)",
            type: types.randomElement()!,
            size: Int.random(in: 10_000...5_000_000),
            status: .ready
        ))
    }
}

struct IngestedFileRow: View {
    let file: IngestedFile
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.icon).font(.title2).foregroundStyle(file.color).frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).font(.subheadline)
                Text(file.formattedSize).font(.caption2).foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Circle().fill(file.statusColor).frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Asset Conversion View

struct AssetConversionView: View {
    let files: [IngestedFile]
    @Binding var assets: [ConvertedAsset]
    @Binding var isProcessing: Bool
    @State private var selectedFormat = "Swift Model"
    @State private var conversionProgress: Double = 0
    
    let formats = ["Swift Model", "Core Data", "JSON Schema", "GraphQL", "Protobuf", "TypeScript"]
    
    var body: some View {
        HSplitView {
            // Conversion Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("Asset Conversion").font(.title2.bold())
                
                // Source Files
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source Files").font(.headline)
                    Text("\(files.count) files ready for conversion").font(.caption).foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(files.prefix(5)) { file in
                                HStack(spacing: 4) {
                                    Image(systemName: file.icon).foregroundStyle(file.color)
                                    Text(file.name).font(.caption).lineLimit(1)
                                }
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color(.controlBackgroundColor)))
                            }
                            if files.count > 5 {
                                Text("+\(files.count - 5) more").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Output Format
                VStack(alignment: .leading, spacing: 8) {
                    Text("Output Format").font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(formats, id: \.self) { format in
                            Button {
                                selectedFormat = format
                            } label: {
                                HStack {
                                    Image(systemName: formatIcon(format))
                                    Text(format).font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 8).fill(selectedFormat == format ? Color.teal.opacity(0.3) : Color(.controlBackgroundColor)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                
                // Options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Options").font(.headline)
                    Toggle("Generate documentation", isOn: .constant(true))
                    Toggle("Include validation", isOn: .constant(true))
                    Toggle("Optimize for size", isOn: .constant(false))
                    Toggle("Generate tests", isOn: .constant(false))
                }
                .font(.caption)
                
                Spacer()
                
                // Convert Button
                if isProcessing {
                    VStack(spacing: 8) {
                        ProgressView(value: conversionProgress)
                        Text("Converting... \(Int(conversionProgress * 100))%").font(.caption)
                    }
                } else {
                    Button {
                        startConversion()
                    } label: {
                        Label("Convert Assets", systemImage: "arrow.triangle.2.circlepath")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(files.isEmpty)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            // Converted Assets
            VStack(spacing: 0) {
                HStack {
                    Text("Converted Assets").font(.headline)
                    Spacer()
                    Text("\(assets.count) assets").font(.caption).foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(assets) { asset in
                        ConvertedAssetRow(asset: asset)
                    }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 350)
        }
    }
    
    func formatIcon(_ format: String) -> String {
        switch format {
        case "Swift Model": return "swift"
        case "Core Data": return "cylinder.fill"
        case "JSON Schema": return "curlybraces"
        case "GraphQL": return "point.3.connected.trianglepath.dotted"
        case "Protobuf": return "doc.badge.gearshape.fill"
        case "TypeScript": return "t.square.fill"
        default: return "doc.fill"
        }
    }
    
    func startConversion() {
        isProcessing = true
        conversionProgress = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            conversionProgress += 0.02
            if conversionProgress >= 1.0 {
                timer.invalidate()
                isProcessing = false
                
                // Add converted assets
                for file in files {
                    assets.append(ConvertedAsset(
                        name: file.name.replacingOccurrences(of: ".\(file.type)", with: ""),
                        sourceFile: file.name,
                        outputFormat: selectedFormat,
                        quality: Double.random(in: 0.7...1.0),
                        linesOfCode: Int.random(in: 50...500),
                        complexity: ["Low", "Medium", "High"].randomElement()!
                    ))
                }
            }
        }
    }
}

struct ConvertedAssetRow: View {
    let asset: ConvertedAsset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text(asset.name).font(.subheadline.bold())
                Spacer()
                Text(asset.outputFormat).font(.caption).padding(.horizontal, 8).padding(.vertical, 2)
                    .background(Capsule().fill(Color.teal.opacity(0.2)))
            }
            
            HStack(spacing: 16) {
                Label("\(asset.linesOfCode) LOC", systemImage: "text.alignleft").font(.caption2)
                Label(asset.complexity, systemImage: "gauge.medium").font(.caption2)
                Label(String(format: "%.0f%%", asset.quality * 100), systemImage: "star.fill").font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Asset Appraisal View

struct AssetAppraisalView: View {
    let assets: [ConvertedAsset]
    @State private var selectedAsset: ConvertedAsset?
    
    var body: some View {
        HSplitView {
            // Asset List
            VStack(spacing: 0) {
                HStack {
                    Text("Asset Appraisal").font(.headline)
                    Spacer()
                }
                .padding()
                
                Divider()
                
                List(assets, selection: $selectedAsset) { asset in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(asset.name).font(.subheadline)
                            Text(asset.outputFormat).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        AppraisalBadge(quality: asset.quality)
                    }
                    .tag(asset)
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 250)
            
            // Appraisal Details
            if let asset = selectedAsset ?? assets.first {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(asset.name).font(.title2.bold())
                            Text("From: \(asset.sourceFile)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        AppraisalScoreCircle(score: asset.quality)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    
                    // Metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AppraisalMetricCard(title: "Code Quality", value: String(format: "%.0f%%", asset.quality * 100), icon: "checkmark.seal.fill", color: .green)
                        AppraisalMetricCard(title: "Complexity", value: asset.complexity, icon: "gauge.medium", color: complexityColor(asset.complexity))
                        AppraisalMetricCard(title: "Lines of Code", value: "\(asset.linesOfCode)", icon: "text.alignleft", color: .blue)
                        AppraisalMetricCard(title: "Maintainability", value: maintainabilityScore(asset), icon: "wrench.and.screwdriver.fill", color: .orange)
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations").font(.headline)
                        
                        ForEach(recommendations(for: asset), id: \.self) { rec in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: rec.hasPrefix("✓") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundStyle(rec.hasPrefix("✓") ? .green : .orange)
                                Text(rec.replacingOccurrences(of: "✓ ", with: "").replacingOccurrences(of: "⚠ ", with: ""))
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    
                    Spacer()
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "doc.text.magnifyingglass").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("Select an asset to appraise").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    func complexityColor(_ complexity: String) -> Color {
        switch complexity {
        case "Low": return .green
        case "Medium": return .orange
        case "High": return .red
        default: return .secondary
        }
    }
    
    func maintainabilityScore(_ asset: ConvertedAsset) -> String {
        let score = asset.quality * 0.6 + (asset.complexity == "Low" ? 0.4 : asset.complexity == "Medium" ? 0.2 : 0)
        return String(format: "%.0f%%", score * 100)
    }
    
    func recommendations(for asset: ConvertedAsset) -> [String] {
        var recs: [String] = []
        if asset.quality > 0.8 { recs.append("✓ Code quality meets standards") }
        else { recs.append("⚠ Consider refactoring for better quality") }
        
        if asset.complexity == "Low" { recs.append("✓ Complexity is manageable") }
        else if asset.complexity == "High" { recs.append("⚠ High complexity - consider breaking into smaller units") }
        
        if asset.linesOfCode < 200 { recs.append("✓ File size is appropriate") }
        else { recs.append("⚠ Consider splitting into multiple files") }
        
        recs.append("✓ Documentation generated")
        return recs
    }
}

struct AppraisalBadge: View {
    let quality: Double
    
    var body: some View {
        Text(quality > 0.8 ? "A" : quality > 0.6 ? "B" : "C")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(Circle().fill(quality > 0.8 ? .green : quality > 0.6 ? .orange : .red))
    }
}

struct AppraisalScoreCircle: View {
    let score: Double
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 8)
            Circle().trim(from: 0, to: score).stroke(score > 0.8 ? Color.green : score > 0.6 ? Color.orange : Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
            Text(String(format: "%.0f", score * 100)).font(.title2.bold())
        }
        .frame(width: 80, height: 80)
    }
}

struct AppraisalMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

// MARK: - Asset Export View

struct AssetExportView: View {
    let assets: [ConvertedAsset]
    @State private var selectedAssets: Set<UUID> = []
    @State private var exportFormat = "Xcode Project"
    
    let exportFormats = ["Xcode Project", "Swift Package", "CocoaPods", "Carthage", "ZIP Archive"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Assets").font(.title2.bold())
            
            HSplitView {
                // Asset Selection
                VStack(spacing: 0) {
                    HStack {
                        Text("Select Assets").font(.headline)
                        Spacer()
                        Button("Select All") { selectedAssets = Set(assets.map { $0.id }) }.buttonStyle(.bordered)
                    }
                    .padding()
                    
                    Divider()
                    
                    List {
                        ForEach(assets) { asset in
                            HStack {
                                Image(systemName: selectedAssets.contains(asset.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedAssets.contains(asset.id) ? .teal : .secondary)
                                    .onTapGesture {
                                        if selectedAssets.contains(asset.id) {
                                            selectedAssets.remove(asset.id)
                                        } else {
                                            selectedAssets.insert(asset.id)
                                        }
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text(asset.name).font(.subheadline)
                                    Text(asset.outputFormat).font(.caption2).foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(asset.linesOfCode) LOC").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .frame(minWidth: 300)
                
                // Export Options
                VStack(alignment: .leading, spacing: 20) {
                    Text("Export Options").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Format").font(.subheadline)
                        Picker("", selection: $exportFormat) {
                            ForEach(exportFormats, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.radioGroup)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Include").font(.subheadline)
                        Toggle("README.md", isOn: .constant(true))
                        Toggle("Unit Tests", isOn: .constant(true))
                        Toggle("Documentation", isOn: .constant(true))
                        Toggle("Example Usage", isOn: .constant(false))
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Summary").font(.headline)
                        Text("\(selectedAssets.count) assets selected").font(.caption)
                        Text("Format: \(exportFormat)").font(.caption)
                        Text("Est. size: \(estimatedSize)").font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                    
                    Button {
                        // Export action
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(selectedAssets.isEmpty)
                }
                .padding()
                .frame(width: 280)
            }
        }
        .padding()
    }
    
    var estimatedSize: String {
        let totalLOC = assets.filter { selectedAssets.contains($0.id) }.reduce(0) { $0 + $1.linesOfCode }
        let sizeKB = totalLOC * 50 // rough estimate
        if sizeKB > 1000 { return String(format: "%.1f MB", Double(sizeKB) / 1000) }
        return "\(sizeKB) KB"
    }
}

// MARK: - Data Models

struct IngestedFile: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let size: Int
    let status: FileStatus
    
    enum FileStatus { case ready, processing, error }
    
    var icon: String {
        switch type {
        case "pdf": return "doc.fill"
        case "json": return "curlybraces"
        case "csv": return "tablecells.fill"
        case "xml": return "chevron.left.forwardslash.chevron.right"
        case "png", "jpg": return "photo.fill"
        default: return "doc.fill"
        }
    }
    
    var color: Color {
        switch type {
        case "pdf": return .red
        case "json": return .orange
        case "csv": return .green
        case "xml": return .purple
        case "png", "jpg": return .blue
        default: return .secondary
        }
    }
    
    var statusColor: Color {
        switch status {
        case .ready: return .green
        case .processing: return .orange
        case .error: return .red
        }
    }
    
    var formattedSize: String {
        if size > 1_000_000 { return String(format: "%.1f MB", Double(size) / 1_000_000) }
        return String(format: "%.1f KB", Double(size) / 1_000)
    }
    
    static var samples: [IngestedFile] {
        [
            IngestedFile(name: "user_data.json", type: "json", size: 245_000, status: .ready),
            IngestedFile(name: "products.csv", type: "csv", size: 1_200_000, status: .ready),
            IngestedFile(name: "config.xml", type: "xml", size: 45_000, status: .ready),
            IngestedFile(name: "report.pdf", type: "pdf", size: 3_500_000, status: .ready),
            IngestedFile(name: "logo.png", type: "png", size: 125_000, status: .ready),
        ]
    }
}

struct ConvertedAsset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let sourceFile: String
    let outputFormat: String
    let quality: Double
    let linesOfCode: Int
    let complexity: String
    
    static var samples: [ConvertedAsset] {
        [
            ConvertedAsset(name: "UserModel", sourceFile: "user_data.json", outputFormat: "Swift Model", quality: 0.92, linesOfCode: 145, complexity: "Low"),
            ConvertedAsset(name: "ProductEntity", sourceFile: "products.csv", outputFormat: "Core Data", quality: 0.85, linesOfCode: 280, complexity: "Medium"),
            ConvertedAsset(name: "AppConfig", sourceFile: "config.xml", outputFormat: "Swift Model", quality: 0.78, linesOfCode: 95, complexity: "Low"),
        ]
    }
}

// MARK: - Icon Creator Workstation

struct IconCreatorWorkstation: View {
    @State private var selectedTab = "Design"
    @State private var iconSymbol = "star.fill"
    @State private var backgroundColor = Color.blue
    @State private var symbolColor = Color.white
    @State private var cornerRadius: Double = 22
    @State private var symbolScale: Double = 0.6
    @State private var gradientEnabled = true
    @State private var shadowEnabled = true
    @State private var automationRules: [IconAutomationRule] = IconAutomationRule.samples
    
    let tabs = ["Design", "Batch", "Automation", "Export"]
    
    var body: some View {
        VStack(spacing: 0) {
            CreativeHeader(title: "Icon Creator", icon: "app.fill", color: Color(red: 0.6, green: 0.4, blue: 0.8))
            
            // Tab Bar
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedTab = tab }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: iconTabIcon(tab)).font(.title3)
                            Text(tab).font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case "Design": IconDesignView(symbol: $iconSymbol, bgColor: $backgroundColor, symbolColor: $symbolColor, cornerRadius: $cornerRadius, symbolScale: $symbolScale, gradientEnabled: $gradientEnabled, shadowEnabled: $shadowEnabled)
                case "Batch": IconBatchView(symbol: iconSymbol, bgColor: backgroundColor, symbolColor: symbolColor, cornerRadius: cornerRadius)
                case "Automation": IconAutomationView(rules: $automationRules)
                case "Export": IconExportView(symbol: iconSymbol, bgColor: backgroundColor, symbolColor: symbolColor, cornerRadius: cornerRadius, symbolScale: symbolScale, gradientEnabled: gradientEnabled)
                default: EmptyView()
                }
            }
        }
    }
    
    func iconTabIcon(_ tab: String) -> String {
        switch tab {
        case "Design": return "paintbrush.fill"
        case "Batch": return "square.stack.3d.up.fill"
        case "Automation": return "gearshape.2.fill"
        case "Export": return "square.and.arrow.up.fill"
        default: return "app.fill"
        }
    }
}

// MARK: - Icon Design View

struct IconDesignView: View {
    @Binding var symbol: String
    @Binding var bgColor: Color
    @Binding var symbolColor: Color
    @Binding var cornerRadius: Double
    @Binding var symbolScale: Double
    @Binding var gradientEnabled: Bool
    @Binding var shadowEnabled: Bool
    
    let popularSymbols = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill", "cloud.fill", "moon.fill", "sun.max.fill", "camera.fill", "music.note", "gamecontroller.fill", "cart.fill", "envelope.fill", "phone.fill", "message.fill", "bell.fill"]
    
    var body: some View {
        HSplitView {
            // Symbol Library
            VStack(spacing: 0) {
                HStack { Text("Symbols").font(.headline); Spacer() }.padding()
                Divider()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(popularSymbols, id: \.self) { sym in
                            Button {
                                withAnimation { symbol = sym }
                            } label: {
                                Image(systemName: sym)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(symbol == sym ? Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3) : Color(.controlBackgroundColor)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .frame(minWidth: 180)
            
            // Preview
            VStack(spacing: 24) {
                Text("Preview").font(.headline)
                
                // Large Preview
                IconPreviewView(symbol: symbol, bgColor: bgColor, symbolColor: symbolColor, cornerRadius: cornerRadius, symbolScale: symbolScale, gradientEnabled: gradientEnabled, shadowEnabled: shadowEnabled, size: 256)
                
                // Size Variants
                HStack(spacing: 20) {
                    ForEach([180, 120, 87, 60, 40], id: \.self) { size in
                        VStack(spacing: 4) {
                            IconPreviewView(symbol: symbol, bgColor: bgColor, symbolColor: symbolColor, cornerRadius: cornerRadius * (Double(size) / 256), symbolScale: symbolScale, gradientEnabled: gradientEnabled, shadowEnabled: shadowEnabled, size: CGFloat(size))
                            Text("\(size)px").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            // Properties
            VStack(alignment: .leading, spacing: 16) {
                Text("Properties").font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Background").font(.subheadline)
                    ColorPicker("Color", selection: $bgColor)
                    Toggle("Gradient", isOn: $gradientEnabled)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Symbol").font(.subheadline)
                    ColorPicker("Color", selection: $symbolColor)
                    HStack {
                        Text("Scale")
                        Slider(value: $symbolScale, in: 0.3...0.9)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shape").font(.subheadline)
                    HStack {
                        Text("Corner Radius")
                        Slider(value: $cornerRadius, in: 0...50)
                    }
                    Toggle("Shadow", isOn: $shadowEnabled)
                }
                
                Divider()
                
                Text("Presets").font(.subheadline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                    IconPresetButton(name: "iOS", bg: .blue, sym: .white) { bgColor = .blue; symbolColor = .white; cornerRadius = 22 }
                    IconPresetButton(name: "macOS", bg: .indigo, sym: .white) { bgColor = .indigo; symbolColor = .white; cornerRadius = 18 }
                    IconPresetButton(name: "Flat", bg: .orange, sym: .white) { bgColor = .orange; symbolColor = .white; cornerRadius = 0; gradientEnabled = false }
                    IconPresetButton(name: "Dark", bg: .black, sym: .white) { bgColor = .black; symbolColor = .white }
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 220)
        }
    }
}

struct IconPreviewView: View {
    let symbol: String
    let bgColor: Color
    let symbolColor: Color
    let cornerRadius: Double
    let symbolScale: Double
    let gradientEnabled: Bool
    let shadowEnabled: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius * (size / 256))
                .fill(gradientEnabled ? AnyShapeStyle(LinearGradient(colors: [bgColor, bgColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(bgColor))
                .frame(width: size, height: size)
                .shadow(color: shadowEnabled ? .black.opacity(0.3) : .clear, radius: size * 0.05, y: size * 0.02)
            
            Image(systemName: symbol)
                .font(.system(size: size * symbolScale))
                .foregroundStyle(symbolColor)
        }
    }
}

struct IconPresetButton: View {
    let name: String
    let bg: Color
    let sym: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8).fill(bg).frame(width: 32, height: 32)
                    .overlay(Image(systemName: "star.fill").font(.caption).foregroundStyle(sym))
                Text(name).font(.caption2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon Batch View

struct IconBatchView: View {
    let symbol: String
    let bgColor: Color
    let symbolColor: Color
    let cornerRadius: Double
    
    @State private var variants: [IconVariant] = []
    @State private var isGenerating = false
    
    let colorSchemes: [(String, Color)] = [
        ("Blue", .blue), ("Red", .red), ("Green", .green), ("Orange", .orange),
        ("Purple", .purple), ("Pink", .pink), ("Teal", .teal), ("Indigo", .indigo)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Batch Generation").font(.title2.bold())
                Spacer()
                Button("Generate All Colors") { generateVariants() }.buttonStyle(.borderedProminent).tint(Color(red: 0.6, green: 0.4, blue: 0.8))
            }
            .padding(.horizontal)
            
            if variants.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.stack.3d.up.fill").font(.system(size: 60)).foregroundStyle(.secondary)
                    Text("Generate icon variants").font(.title3)
                    Text("Create multiple color variations of your icon automatically").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(variants) { variant in
                            VStack(spacing: 8) {
                                IconPreviewView(symbol: symbol, bgColor: variant.color, symbolColor: symbolColor, cornerRadius: cornerRadius, symbolScale: 0.6, gradientEnabled: true, shadowEnabled: true, size: 120)
                                Text(variant.name).font(.caption)
                                HStack(spacing: 4) {
                                    Button("PNG") {}.buttonStyle(.bordered).controlSize(.small)
                                    Button("SVG") {}.buttonStyle(.bordered).controlSize(.small)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                        }
                    }
                    .padding()
                }
            }
        }
        .padding(.top)
    }
    
    func generateVariants() {
        variants = colorSchemes.map { IconVariant(name: $0.0, color: $0.1) }
    }
}

struct IconVariant: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

// MARK: - Icon Automation View

struct IconAutomationView: View {
    @Binding var rules: [IconAutomationRule]
    @State private var showingAddRule = false
    
    var body: some View {
        HSplitView {
            // Rules List
            VStack(spacing: 0) {
                HStack {
                    Text("Automation Rules").font(.headline)
                    Spacer()
                    Button { showingAddRule = true } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(rules) { rule in
                        AutomationRuleRow(rule: rule)
                    }
                    .onDelete { rules.remove(atOffsets: $0) }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 350)
            
            // Rule Details / Add New
            VStack(alignment: .leading, spacing: 20) {
                Text("Create Automation").font(.title2.bold())
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trigger").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        AutomationTriggerOption(title: "On File Change", description: "When source file is modified", icon: "doc.badge.arrow.up.fill", isSelected: true)
                        AutomationTriggerOption(title: "On Schedule", description: "Run at specific times", icon: "clock.fill", isSelected: false)
                        AutomationTriggerOption(title: "On Git Push", description: "When code is pushed", icon: "arrow.triangle.branch", isSelected: false)
                        AutomationTriggerOption(title: "Manual", description: "Run on demand", icon: "hand.tap.fill", isSelected: false)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Actions").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Generate all sizes", isOn: .constant(true))
                        Toggle("Export to Assets.xcassets", isOn: .constant(true))
                        Toggle("Create @2x and @3x variants", isOn: .constant(true))
                        Toggle("Optimize for App Store", isOn: .constant(false))
                        Toggle("Send notification on complete", isOn: .constant(true))
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Button {
                    rules.append(IconAutomationRule(name: "New Rule", trigger: "On File Change", actions: ["Generate sizes", "Export"], isEnabled: true, lastRun: nil))
                } label: {
                    Label("Create Rule", systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.6, green: 0.4, blue: 0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

struct AutomationRuleRow: View {
    let rule: IconAutomationRule
    
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(rule.isEnabled ? .green : .secondary).frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name).font(.subheadline)
                Text(rule.trigger).font(.caption2).foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let lastRun = rule.lastRun {
                Text(lastRun).font(.caption2).foregroundStyle(.secondary)
            }
            
            Toggle("", isOn: .constant(rule.isEnabled)).labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

struct AutomationTriggerOption: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color(red: 0.6, green: 0.4, blue: 0.8) : .secondary)
            
            Image(systemName: icon).frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(description).font(.caption2).foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.1) : Color.clear))
    }
}

struct IconAutomationRule: Identifiable {
    let id = UUID()
    let name: String
    let trigger: String
    let actions: [String]
    let isEnabled: Bool
    let lastRun: String?
    
    static var samples: [IconAutomationRule] {
        [
            IconAutomationRule(name: "iOS App Icon", trigger: "On File Change", actions: ["Generate sizes", "Export to xcassets"], isEnabled: true, lastRun: "2 hours ago"),
            IconAutomationRule(name: "macOS Icon Set", trigger: "On Git Push", actions: ["Generate sizes", "Create icns"], isEnabled: true, lastRun: "Yesterday"),
            IconAutomationRule(name: "App Store Screenshots", trigger: "Manual", actions: ["Generate all", "Optimize"], isEnabled: false, lastRun: nil),
        ]
    }
}

// MARK: - Icon Export View

struct IconExportView: View {
    let symbol: String
    let bgColor: Color
    let symbolColor: Color
    let cornerRadius: Double
    let symbolScale: Double
    let gradientEnabled: Bool
    
    @State private var selectedPlatforms: Set<String> = ["iOS"]
    @State private var exportFormat = "PNG"
    @State private var isExporting = false
    
    let platforms = [
        ("iOS", ["1024x1024", "180x180", "120x120", "87x87", "80x80", "60x60", "58x58", "40x40", "29x29", "20x20"]),
        ("macOS", ["1024x1024", "512x512", "256x256", "128x128", "64x64", "32x32", "16x16"]),
        ("watchOS", ["1024x1024", "196x196", "172x172", "100x100", "88x88", "87x87", "80x80"]),
        ("Android", ["512x512", "192x192", "144x144", "96x96", "72x72", "48x48"]),
    ]
    
    var body: some View {
        HSplitView {
            // Platform Selection
            VStack(spacing: 0) {
                HStack { Text("Platforms").font(.headline); Spacer() }.padding()
                Divider()
                
                List {
                    ForEach(platforms, id: \.0) { platform, sizes in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: selectedPlatforms.contains(platform) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedPlatforms.contains(platform) ? Color(red: 0.6, green: 0.4, blue: 0.8) : .secondary)
                                    .onTapGesture {
                                        if selectedPlatforms.contains(platform) {
                                            selectedPlatforms.remove(platform)
                                        } else {
                                            selectedPlatforms.insert(platform)
                                        }
                                    }
                                
                                Text(platform).font(.subheadline.bold())
                                Spacer()
                                Text("\(sizes.count) sizes").font(.caption2).foregroundStyle(.secondary)
                            }
                            
                            if selectedPlatforms.contains(platform) {
                                FlowLayout(spacing: 4) {
                                    ForEach(sizes, id: \.self) { size in
                                        Text(size).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Capsule().fill(Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.2)))
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 280)
            
            // Export Preview & Options
            VStack(spacing: 20) {
                // Preview
                VStack(spacing: 12) {
                    Text("Export Preview").font(.headline)
                    IconPreviewView(symbol: symbol, bgColor: bgColor, symbolColor: symbolColor, cornerRadius: cornerRadius, symbolScale: symbolScale, gradientEnabled: gradientEnabled, shadowEnabled: true, size: 200)
                }
                
                // Format
                VStack(alignment: .leading, spacing: 8) {
                    Text("Format").font(.headline)
                    Picker("", selection: $exportFormat) {
                        Text("PNG").tag("PNG")
                        Text("JPEG").tag("JPEG")
                        Text("SVG").tag("SVG")
                        Text("PDF").tag("PDF")
                        Text("ICNS").tag("ICNS")
                    }
                    .pickerStyle(.segmented)
                }
                
                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export Summary").font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Platforms").font(.caption).foregroundStyle(.secondary)
                            Text("\(selectedPlatforms.count) selected").font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Total Files").font(.caption).foregroundStyle(.secondary)
                            Text("\(totalFiles)").font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Format").font(.caption).foregroundStyle(.secondary)
                            Text(exportFormat).font(.subheadline)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                }
                
                Spacer()
                
                // Export Button
                if isExporting {
                    ProgressView("Exporting...").frame(maxWidth: .infinity)
                } else {
                    Button {
                        isExporting = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isExporting = false }
                    } label: {
                        Label("Export \(totalFiles) Icons", systemImage: "square.and.arrow.up.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.6, green: 0.4, blue: 0.8))
                    .disabled(selectedPlatforms.isEmpty)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    
    var totalFiles: Int {
        platforms.filter { selectedPlatforms.contains($0.0) }.reduce(0) { $0 + $1.1.count }
    }
}

struct CrFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Preview

#Preview("Creative Workstations") {
    CreativeWorkstationsHub()
        .frame(width: 1400, height: 900)
}
